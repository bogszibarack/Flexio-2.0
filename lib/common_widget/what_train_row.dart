import 'package:fitness/common_widget/round_button.dart';
import 'package:flutter/material.dart';

import '../common/colo_extension.dart';
import '../view/workout_tracker/workout_store.dart';

class WhatTrainRow extends StatelessWidget {
  final Map wObj;
  final VoidCallback? onDetailsPressed;

  const WhatTrainRow({super.key, required this.wObj, this.onDetailsPressed});

  String _subtitle() {
    final parts = <String>[
      wObj["exercises"].toString(),
      wObj["difficulty"]?.toString() ?? "Kezdő",
    ];

    final averageMinutes =
        WorkoutStore.averageMinutesFor(wObj["title"].toString());
    if (averageMinutes != null) {
      parts.add("~$averageMinutes perc");
    }

    return parts.join(" | ");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              TColor.primaryColor2.withValues(alpha: 0.3),
              TColor.primaryColor1.withValues(alpha: 0.3)
            ]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wObj["title"].toString(),
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      _subtitle(),
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: 100,
                      height: 30,
                      child: RoundButton(
                          title: "Részletek",
                          fontSize: 10,
                          height: 30,
                          type: RoundButtonType.textGradient,
                          elevation:0.05,
                          fontWeight: FontWeight.w400,
                          onPressed: onDetailsPressed ?? () {}),
                    )
                  ],
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      wObj["image"].toString(),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
