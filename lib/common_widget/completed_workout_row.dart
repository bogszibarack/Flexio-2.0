import 'package:flutter/material.dart';

import '../common/colo_extension.dart';
import '../common/common.dart';
import '../view/workout_tracker/completed_workout_detail_view.dart';
import '../view/workout_tracker/workout_store.dart';

class CompletedWorkoutRow extends StatelessWidget {
  final Map<String, dynamic> entry;
  final WorkoutProgress? progress;
  final VoidCallback? onTap;

  const CompletedWorkoutRow({
    super.key,
    required this.entry,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = entry["date"] as DateTime;
    final volume = (entry["volume"] as num).toDouble();

    return InkWell(
      onTap: onTap ??
          () => openCompletedWorkoutDetail(context, entry),
      borderRadius: BorderRadius.circular(15),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                entry["image"].toString(),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry["title"].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${dateToDayTitle(date)}, ${dateToTimeLabel(date)} | ${entry["minutes"]} perc | ${entry["calories"]} kcal",
                    style: TextStyle(color: TColor.gray, fontSize: 10),
                  ),
                  if (volume > 0)
                    Text(
                      "${volume.round()} kg terhelés (${entry["completedSets"]}/${entry["totalSets"]} kör)",
                      style: TextStyle(color: TColor.gray, fontSize: 10),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _progressChip(),
            Icon(Icons.chevron_right, color: TColor.gray, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _progressChip() {
    if (progress == null) {
      return _chip("Első", TColor.gray, Icons.flag_outlined);
    }

    final percent = progress!.volumeDeltaPercent;
    final String label;
    final double reference;

    if (percent != null && percent.abs() >= 1) {
      label = "${percent > 0 ? "+" : ""}${percent.round()}%";
      reference = percent;
    } else if (progress!.caloriesDelta != 0) {
      label =
          "${progress!.caloriesDelta > 0 ? "+" : ""}${progress!.caloriesDelta} kcal";
      reference = progress!.caloriesDelta.toDouble();
    } else {
      return _chip("Azonos", TColor.gray, Icons.remove);
    }

    final isUp = reference > 0;
    return _chip(
      label,
      isUp ? const Color(0xff2FA96B) : const Color(0xffE0687A),
      isUp ? Icons.arrow_upward : Icons.arrow_downward,
    );
  }

  Widget _chip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
