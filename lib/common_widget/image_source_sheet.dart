import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../common/colo_extension.dart';
import 'sheet_option.dart';

/// Közös kamera / galéria választó a profilképhez és a haladási fotókhoz.
class ImageSourceSheet {
  ImageSourceSheet._();

  static Future<XFile?> pick(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: TColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Material(
          color: TColor.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TColor.lightGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Fotó forrása",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                SheetOption(
                  leading: Icon(Icons.photo_camera_outlined,
                      color: TColor.primaryColor1),
                  title: "Kamera",
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                SheetOption(
                  leading: Icon(Icons.photo_library_outlined,
                      color: TColor.primaryColor1),
                  title: "Galéria",
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (source == null) {
      return null;
    }

    return ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );
  }
}
