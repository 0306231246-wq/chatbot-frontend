import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pc_builder_chatbot/screens/login_page.dart';
import 'screens/main_store_page.dart';
import 'config/firebase_options.dart';
import 'services/auth_session_service.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (kIsWeb) {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    }
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TECH-GEAR PCSTORE',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0D0D12),
        appBarTheme:
            const AppBarTheme(backgroundColor: Color(0xFF0D0D12), elevation: 0),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF2F80FF),
          secondary: Color(0xFFFF2D78),
          surface: Color(0xFF1E1E24),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            return SessionGuard(
              user: snapshot.data!,
              child: const MainStorePage(),
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}

class SessionGuard extends StatefulWidget {
  final User user;
  final Widget child;

  const SessionGuard({
    super.key,
    required this.user,
    required this.child,
  });

  @override
  State<SessionGuard> createState() => _SessionGuardState();
}

class _SessionGuardState extends State<SessionGuard> {
  @override
  void initState() {
    super.initState();
    _startSessionWatch();
  }

  @override
  void didUpdateWidget(covariant SessionGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user.uid != widget.user.uid) {
      _startSessionWatch();
    }
  }

  @override
  void dispose() {
    AuthSessionService.instance.stopWatching();
    super.dispose();
  }

  Future<void> _startSessionWatch() async {
    await AuthSessionService.instance.startWatching(
      user: widget.user,
      onKicked: _showKickedMessage,
    );
  }

  void _showKickedMessage() {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: const Text(
          'Tài khoản của bạn đã được đăng nhập từ thiết bị khác. Bạn đã bị đăng xuất.',
        ),
        backgroundColor: Colors.orange.shade800,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
