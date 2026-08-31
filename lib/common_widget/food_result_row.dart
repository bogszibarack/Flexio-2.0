import 'package:flutter/material.dart';

import '../common/colo_extension.dart';
import '../data/models/food_item.dart';

/// Egy találat az ételkeresőben: név, márka, 100 g-ra vetített kalória és a
/// forrás jelölése.
class FoodResultRow extends StatelessWidget {
  final FoodItem food;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final String? trailingLabel;

  const FoodResultRow({
    super.key,
    required this.food,
    required this.onTap,
    this.onFavoriteToggle,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: TColor.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _thumbnail(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    trailingLabel ?? food.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: TColor.gray, fontSize: 11),
                  ),
                  const SizedBox(height: 5),
                  _macroLine(),
                ],
              ),
            ),
            if (onFavoriteToggle != null)
              IconButton(
                onPressed: onFavoriteToggle,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  food.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                  color: food.isFavorite ? TColor.secondaryColor1 : TColor.gray,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail() {
    final imageUrl = food.imageUrl;

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: food.source == FoodSource.curated
              ? TColor.primaryG
              : TColor.secondaryG,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? Text(
              _initials(food.name),
              style: TextStyle(
                color: TColor.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                imageUrl,
                width: 46,
                height: 46,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Text(
                  _initials(food.name),
                  style: TextStyle(
                    color: TColor.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
    );
  }

  Widget _macroLine() {
    final macros = food.per100g;
    return Wrap(
      spacing: 10,
      children: [
        _macroChip("F", macros.protein, TColor.primaryColor1),
        _macroChip("Sz", macros.carbs, TColor.secondaryColor1),
        _macroChip("Zs", macros.fat, TColor.secondaryColor2),
      ],
    );
  }

  Widget _macroChip(String label, double value, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "$label ${value.round()} g",
            style: TextStyle(color: TColor.gray, fontSize: 10),
          ),
        ],
      );

  static String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return "?";
    }
    final parts = trimmed.split(RegExp(r"\s+"));
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}
