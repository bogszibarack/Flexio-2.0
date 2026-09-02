import 'package:flutter/material.dart';

/// Flexio márka logó — splash, onboarding, betöltő képernyő.
class FlexioLogo extends StatelessWidget {
  const FlexioLogo({
    super.key,
    this.width = 200,
    this.semanticLabel = 'Flexio',
  });

  final double width;
  final String semanticLabel;

  static const String assetPath = 'assets/img/flexio_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      fit: BoxFit.contain,
      semanticLabel: semanticLabel,
    );
  }
}
