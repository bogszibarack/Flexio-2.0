import 'package:flutter/material.dart';

import '../common/app_haptics.dart';
import '../common/colo_extension.dart';
import '../common/common.dart';
import '../view/workout_tracker/completed_workout_detail_view.dart';
import '../view/workout_tracker/workout_store.dart';

/// A főoldal befejezett edzés kártyája. Koppintásra helyben lenyílik, és
/// gyakorlatonként mutatja a köröket, ismétléseket és súlyokat.
class LatestWorkoutCard extends StatefulWidget {
  final Map<String, dynamic> entry;

  const LatestWorkoutCard({super.key, required this.entry});

  @override
  State<LatestWorkoutCard> createState() => _LatestWorkoutCardState();
}

class _LatestWorkoutCardState extends State<LatestWorkoutCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final date = entry["date"] as DateTime?;
    final image = "${entry["image"] ?? ""}";
    final completedSets = (entry["completedSets"] as num?)?.toInt() ?? 0;
    final totalSets = (entry["totalSets"] as num?)?.toInt() ?? 0;

    final subtitle = [
      if (date != null) "${dateToDayTitle(date)}, ${dateToTimeLabel(date)}",
      "${entry["minutes"] ?? 0} perc",
      "${entry["calories"] ?? 0} kcal",
    ].join(" · ");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Material(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black12,
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            AppHaptics.selection();
            setState(() => _expanded = !_expanded);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        image.startsWith("assets/")
                            ? image
                            : "assets/img/Workout1.png",
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${entry["title"] ?? "Edzés"}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            style: TextStyle(color: TColor.gray, fontSize: 11),
                          ),
                          if (totalSets > 0) ...[
                            const SizedBox(height: 3),
                            Text(
                              "$completedSets/$totalSets kör teljesítve",
                              style: TextStyle(
                                color: TColor.primaryColor1,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: TColor.gray,
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: _expanded
                      ? _buildDetails(context)
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final entry = widget.entry;
    final exercises = WorkoutStore.exercisesOfCompleted(entry);
    final volume = (entry["volume"] as num?)?.toDouble() ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Divider(height: 1, color: TColor.lightGray),
        const SizedBox(height: 10),
        if (volume > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              "Megmozgatott súly: ${volume.round()} kg",
              style: TextStyle(
                color: TColor.black,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (exercises.isEmpty)
          Text(
            "Ehhez az edzéshez nem maradt meg a gyakorlatlista.",
            style: TextStyle(color: TColor.gray, fontSize: 12),
          )
        else
          ...exercises.map(_exerciseBlock),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => openCompletedWorkoutDetail(context, entry),
            child: Text(
              "Részletek",
              style: TextStyle(
                color: TColor.primaryColor1,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _exerciseBlock(Map<String, dynamic> exercise) {
    final rounds = (exercise["rounds"] as num?)?.toInt() ?? 1;
    final repetitions = (exercise["repetitions"] as num?)?.toInt() ?? 0;
    final rawWeights = exercise["roundWeights"];
    final fallbackWeight = (exercise["weight"] as num?)?.toInt() ?? 0;
    final weights = List<int>.generate(rounds, (index) {
      if (rawWeights is List && index < rawWeights.length) {
        return (rawWeights[index] as num?)?.toInt() ?? fallbackWeight;
      }
      return fallbackWeight;
    });

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${exercise["name"] ?? "Gyakorlat"}",
            style: TextStyle(
              color: TColor.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          for (var index = 0; index < rounds; index++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      "${index + 1}. kör",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  ),
                  Text(
                    weights[index] > 0
                        ? "${weights[index]} kg × $repetitions"
                        : "$repetitions ismétlés",
                    style: TextStyle(color: TColor.black, fontSize: 12),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
