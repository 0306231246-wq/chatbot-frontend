import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/main_store_controller.dart';
import '../../../services/auth_service.dart';

void showProfileSheet(
  BuildContext context,
  User user,
  MainStoreController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProfileSheet(user: user, controller: controller),
  );
}

class ProfileSheet extends StatefulWidget {
  final User user;
  final MainStoreController controller;

  const ProfileSheet({
    super.key,
    required this.user,
    required this.controller,
  });

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  late final TextEditingController nameController;
  late final TextEditingController avatarController;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user.displayName ?? '');
    avatarController = TextEditingController(text: widget.user.photoURL ?? '');

    if (widget.user.photoURL == 'firestore_base64') {
      AuthService.getProfileAvatar(widget.user.uid).then((base64) {
        if (!mounted || base64 == null) return;
        setState(() => avatarController.text = base64);
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    avatarController.dispose();
    super.dispose();
  }

  Widget _buildProfilePreview(String photoUrl) {
    final cleanPhotoUrl = photoUrl.trim();
    ImageProvider? imageProvider;

    if (cleanPhotoUrl.startsWith('data:image')) {
      try {
        imageProvider = MemoryImage(base64Decode(cleanPhotoUrl.split(',').last));
      } catch (_) {}
    } else {
      final uri = Uri.tryParse(cleanPhotoUrl);
      if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
        imageProvider = NetworkImage(cleanPhotoUrl);
      }
    }

    return CircleAvatar(
      radius: 38,
      backgroundColor: Colors.white12,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(Icons.person, size: 40, color: Colors.white38)
          : null,
    );
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 300,
      imageQuality: 50,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    final base64String = base64Encode(bytes);
    setState(() {
      avatarController.text = 'data:image/jpeg;base64,$base64String';
    });
  }

  Future<void> _saveProfile() async {
    setState(() => isSaving = true);
    final result = await AuthService().updateProfile(
      displayName: nameController.text,
      photoUrl: avatarController.text,
    );
    if (!mounted) return;
    setState(() => isSaving = false);
    Navigator.pop(context);
    widget.controller.refresh();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.success
            ? 'Đã cập nhật hồ sơ.'
            : result.errorMessage ?? 'Cập nhật hồ sơ thất bại.'),
        backgroundColor:
            result.success ? const Color(0xFF1B9E5A) : Colors.red.shade800,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF14141B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hồ sơ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      _buildProfilePreview(avatarController.text),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80FF),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF14141B),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tên hiển thị',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2F80FF)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSaving ? null : () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isSaving ? null : _saveProfile,
                    child: isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Lưu'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
