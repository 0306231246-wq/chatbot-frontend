import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import '../services/auth_service.dart';
import '../services/auth_session_service.dart';
import 'main_store_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  DateTime? _lastForgotPasswordTime;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isLoginMode = true;

  void _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final result = await _authService.signInWithGoogle();
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      final sessionReady = await _activateSingleSession(result.user);
      if (!sessionReady || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thành công! Chào mừng ${result.user?.displayName ?? result.user?.email}.')),
      );
      
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainStorePage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Đăng nhập thất bại.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  void _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ Email và Mật khẩu!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final result = _isLoginMode 
        ? await _authService.signInWithEmail(email, password)
        : await _authService.signUpWithEmail(email, password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      final user = result.user;

      // KIỂM TRA XÁC THỰC EMAIL (BẮT BUỘC)
      if (user != null && !user.emailVerified) {
        if (_isLoginMode) {
          try {
            await user.sendEmailVerification();
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Tài khoản chưa xác thực! Đã gửi lại link xác thực mới vào Email của bạn.'),
                backgroundColor: Colors.orange.shade800,
                duration: const Duration(seconds: 4),
              ),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Vui lòng kiểm tra Hộp thư Email để xác thực tài khoản trước khi đăng nhập!'),
                backgroundColor: Colors.orange.shade800,
              ),
            );
          }
        } else {
          // Vừa mới đăng ký xong
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng kiểm tra hộp thư email để xác thực tài khoản.'),
              backgroundColor: Color(0xFF1B9E5A),
              duration: Duration(seconds: 4),
            ),
          );
          setState(() {
            _isLoginMode = true; // Đổi lại thành form Đăng nhập
          });
        }
        
        // Đăng xuất ra ngay lập tức và chặn không cho vào Main Page
        await _authService.signOut();
        return;
      }

      // NẾU ĐÃ XÁC THỰC (Hoặc đăng nhập bằng Google)
      final sessionReady = await _activateSingleSession(user);
      if (!sessionReady || !mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng nhập thành công! Chào mừng ${user?.email}.'),
          backgroundColor: const Color(0xFF1B9E5A),
        ),
      );
      
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainStorePage()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Đã có lỗi xảy ra.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  Future<bool> _activateSingleSession(User? user) async {
    if (user == null) {
      return false;
    }

    try {
      await AuthSessionService.instance.registerActiveSession(user);
      return true;
    } catch (_) {
      await _authService.signOut();
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Không thể kích hoạt phiên đăng nhập. Vui lòng thử lại.',
          ),
          backgroundColor: Colors.red.shade800,
        ),
      );
      return false;
    }
  }

  void _handleForgotPassword() async {
    if (_lastForgotPasswordTime != null) {
      final difference = DateTime.now().difference(_lastForgotPasswordTime!);
      if (difference.inSeconds < 60) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Vui lòng đợi ${60 - difference.inSeconds} giây trước khi gửi lại yêu cầu!'),
            backgroundColor: Colors.orange.shade800,
          ),
        );
        return;
      }
    }

    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Email để khôi phục mật khẩu!')),
      );
      return;
    }

    _lastForgotPasswordTime = DateTime.now();

    setState(() => _isLoading = true);
    final result = await _authService.resetPassword(email);
    
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi link khôi phục! Vui lòng kiểm tra hộp thư của bạn.'),
          backgroundColor: Color(0xFF1B9E5A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Đã có lỗi xảy ra.'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D12),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF14141B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          primary.withOpacity(0.2),
                          secondary.withOpacity(0.2)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.memory_rounded, size: 48, color: primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TECH-GEAR ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Đăng nhập để lưu cấu hình & hỏi đáp cùng AI',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Email hoặc Tên đăng nhập',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Mật khẩu',
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),
                  const SizedBox(height: 12),
                  if (_isLoginMode)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading ? null : _handleForgotPassword,
                        child: Text(
                          'Quên mật khẩu?',
                          style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 48), // Padding bù lại khoảng trống của nút Quên mật khẩu
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [primary, secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _isLoading ? null : _handleEmailAuth,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                _isLoginMode ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: Colors.white.withOpacity(0.1),
                              thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'HOẶC',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                          child: Divider(
                              color: Colors.white.withOpacity(0.1),
                              thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _isLoading ? null : _handleGoogleLogin,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                'G',
                                style: TextStyle(
                                  color: Color(0xFF4285F4),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Flexible(
                              child: Text(
                                'Đăng nhập bằng Google',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLoginMode ? 'Chưa có tài khoản?' : 'Đã có tài khoản?',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                            // Tùy chọn: Xóa trắng form khi đổi mode
                            _emailController.clear();
                            _passwordController.clear();
                          });
                        },
                        child: Text(
                          _isLoginMode ? 'Đăng ký ngay' : 'Đăng nhập',
                          style: TextStyle(
                              color: secondary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(icon, color: Colors.white.withOpacity(0.4), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword && _obscurePassword,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                    color: Colors.white.withOpacity(0.3), fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: Colors.white.withOpacity(0.4),
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          if (!isPassword) const SizedBox(width: 16),
        ],
      ),
    );
  }
}
