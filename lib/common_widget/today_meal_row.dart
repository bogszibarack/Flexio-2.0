import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

import '../common/common.dart';
import '../data/models/diary_entry.dart';

class TodayMealRow extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;

  const TodayMealRow({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final date = entry.loggedAt;
    final totals = entry.totals;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2)
              ]),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.primaryG),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  entry.foodName.trim().isEmpty
                      ? "?"
                      : entry.foodName.trim().substring(0, 1).toUpperCase(),
                  style: TextStyle(
                      color: TColor.white,
                      fontSize: 14,
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
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${dateToDayTitle(date)}, ${dateToTimeLabel(date)} | ${entry.mealType} · ${entry.amountLabel}",
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
                    fontWeight: FontWeight.w700),
              ),
            ],
          )),
    );
  }
}
