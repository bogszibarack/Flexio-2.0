import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';
import '../data/models/diary_entry.dart';

class MealFoodScheduleRow extends StatelessWidget {
  final DiaryEntry entry;
  final int index;
  final VoidCallback? onTap;

  const MealFoodScheduleRow({
    super.key,
    required this.entry,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final totals = entry.totals;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Row(
            children: [
              Container(
                height: 55,
                width: 55,
                decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? TColor.primaryColor2.withValues(alpha: 0.4)
                        : TColor.secondaryColor2.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text(
                  entry.foodName.trim().isEmpty
                      ? "?"
                      : entry.foodName.trim().substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.foodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "${dateToTimeLabel(entry.loggedAt)} · ${entry.amountLabel}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      "F ${totals.protein.round()} g · Sz ${totals.carbs.round()} g · Zs ${totals.fat.round()} g",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${totals.kcal.round()} kcal",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
              )
            ],
          )),
    );
  }
}
