import 'dart:io';

import 'package:flutter/material.dart';

import '../common/colo_extension.dart';

/// Kerek profilgomb a főoldal fejlécében: a saját kép, ha van, különben
/// egységes személy-ikon.
class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({
    super.key,
    required this.avatarPath,
    required this.onTap,
  });

  final String? avatarPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final path = avatarPath;
    final file = path != null && path.startsWith("/") ? File(path) : null;
    final hasImage = file != null && file.existsSync();

    return Semantics(
      button: true,
      label: "Profil",
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: hasImage ? null : LinearGradient(colors: TColor.primaryG),
            image: hasImage
                ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                : null,
          ),
          child: hasImage
              ? null
              : const Icon(Icons.person_rounded, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
