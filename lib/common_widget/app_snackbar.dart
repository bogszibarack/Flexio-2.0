import 'package:flutter/material.dart';

import '../common/app_haptics.dart';
import '../common/colo_extension.dart';

/// Az app stílusához illő értesítés. A Material alapértelmezett sávja helyett
/// lekerekített, gradiens ikonos kártya, opcionális visszavonás gombbal.
void showAppSnack(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_outline,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 4),
}) {
  AppHaptics.success();
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();

  messenger.showSnackBar(
    SnackBar(
      duration: duration,
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: TColor.black.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: TColor.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                child: Text(
                  actionLabel,
                  style: TextStyle(
                    color: TColor.primaryColor1,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
