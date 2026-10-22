// M17 Profil (FR-PRO-03)
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/models/user.dart';

/// Avatar pengguna. Bila [onPicked] diberikan muncul tombol kamera untuk
/// memilih foto dari galeri; foto dikecilkan sebelum dikirim.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.user,
    this.radius = 44,
    this.onPicked,
    this.busy = false,
  });

  final AppUser user;
  final double radius;
  final bool busy;
  final Future<void> Function(Uint8List bytes, String filename)? onPicked;

  Future<void> _pick(BuildContext context) async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (file == null) return;
    await onPicked!(await file.readAsBytes(), file.name);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = user.avatarUrl;
    return Semantics(
      label: 'Foto profil ${user.name}',
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: scheme.primaryContainer,
            foregroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
            child: Text(
              user.initials,
              style: TextStyle(fontSize: radius * 0.6, color: scheme.onPrimaryContainer),
            ),
          ),
          if (busy)
            Positioned.fill(
              child: Center(child: CircularProgressIndicator(color: scheme.primary)),
            ),
          if (onPicked != null)
            IconButton.filled(
              tooltip: 'Ganti foto',
              iconSize: 18,
              onPressed: busy ? null : () => _pick(context),
              icon: const Icon(Icons.photo_camera_outlined),
            ),
        ],
      ),
    );
  }
}
