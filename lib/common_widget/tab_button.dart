import 'package:fitness/common/app_haptics.dart';
import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

/// Az alsó sáv egy füle. Minden fül ugyanabból az ikoncsaládból jön
/// (körvonalas, aktívan kitöltött), az aktív az app gradiensével színeződik.
class TabButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const TabButton({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isActive,
      label: label,
      child: InkResponse(
        onTap: () {
          if (!isActive) {
            AppHaptics.selection();
          }
          onTap();
        },
        radius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isActive ? 1.12 : 1,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutBack,
              child: isActive
                  ? ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: TColor.primaryG,
                      ).createShader(bounds),
                      child: Icon(activeIcon, size: 26, color: Colors.white),
                    )
                  : Icon(icon, size: 26, color: TColor.gray),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? TColor.primaryColor1 : TColor.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
