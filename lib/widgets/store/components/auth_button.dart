import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../screens/login_page.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/main_store_controller.dart';
import '../user/profile_sheet.dart';

/// Avatar image widget: handles network URL, base64, and firestore_base64 flag.
class AvatarImage extends StatelessWidget {
  final String? photoUrl;
  final Color primary;
  final double size;

  const AvatarImage({
    super.key,
    required this.photoUrl,
    required this.primary,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return Icon(Icons.account_circle, size: size, color: primary);
    }

    final clean = photoUrl!.trim();

    if (clean == 'firestore_base64') {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        return FutureBuilder<String?>(
          future: AuthService.getProfileAvatar(user.uid),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              try {
                final bytes = base64Decode(snapshot.data!.split(',').last);
                return Image.memory(bytes,
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                    gaplessPlayback: true);
              } catch (_) {}
            }
            return Icon(Icons.account_circle, size: size, color: primary);
          },
        );
      }
      return Icon(Icons.account_circle, size: size, color: primary);
    }

    if (clean.startsWith('data:image')) {
      try {
        return Image.memory(
          base64Decode(clean.split(',').last),
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
        );
      } catch (_) {
        return Icon(Icons.account_circle, size: size, color: primary);
      }
    }

    return Image.network(
      clean,
      width: size,
      height: size,
      fit: BoxFit.cover,
      cacheWidth: (size * 2).toInt(),
      errorBuilder: (_, __, ___) =>
          Icon(Icons.account_circle, size: size, color: primary),
    );
  }
}

/// Auth button: shows avatar popup menu if logged in, or login button.
class AuthButton extends StatelessWidget {
  final MainStoreController controller;

  const AuthButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: user != null
          ? PopupMenuButton<String>(
              offset: const Offset(0, 48),
              color: const Color(0xFF1A1A22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (val) async {
                if (val == 'profile') {
                  showProfileSheet(context, user, controller);
                  return;
                }
                if (val == 'signout') {
                  await AuthService().signOut();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đăng xuất thành công')),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(children: [
                    Icon(Icons.manage_accounts_rounded,
                        color: primary, size: 18),
                    const SizedBox(width: 10),
                    const Text('Hồ sơ',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ]),
                ),
                PopupMenuItem(
                  value: 'signout',
                  child: Row(children: [
                    Icon(Icons.logout_rounded,
                        color: Colors.redAccent.shade400, size: 18),
                    const SizedBox(width: 10),
                    const Text('Đăng xuất',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                  ]),
                ),
              ],
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AvatarImage(photoUrl: user.photoURL, primary: primary),
              ),
            )
          : TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: primary.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              icon:
                  Icon(Icons.person_outline_rounded, size: 16, color: primary),
              label: Text('Đăng nhập',
                  style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              onPressed: () async {
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
              },
            ),
    );
  }
}
