import 'package:flutter/material.dart';

import '../common/colo_extension.dart';

/// Lista-sor bottom sheethez. Nem ListTile, így a fehér kártya nem takarja az
/// ink splash-t, és nincs DecoratedBox figyelmeztetés.
class SheetOption extends StatelessWidget {
  const SheetOption({
    super.key,
    required this.title,
    required this.onTap,
    this.leading,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final VoidCallback onTap;
  final Widget? leading;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: TColor.black, fontSize: 14),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
