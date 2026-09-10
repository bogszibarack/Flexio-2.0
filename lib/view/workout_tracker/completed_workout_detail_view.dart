import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import 'workout_store.dart';

/// Befejezett edzés visszanézése: mikor, mennyi, milyen gyakorlatokkal.
class CompletedWorkoutDetailView extends StatelessWidget {
  const CompletedWorkoutDetailView({super.key, required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final date = entry["date"] as DateTime?;
    final volume = (entry["volume"] as num?)?.toDouble() ?? 0;
    final exercises = WorkoutStore.exercisesOfCompleted(entry);
    final progress = WorkoutStore.progressionFor(entry);
    final rpe = entry["rpe"];

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Edzés részletei",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "${entry["image"] ?? "assets/img/Workout1.png"}",
                  width: 72,
                  height: 72,
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
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date == null
                          ? "${entry["difficulty"] ?? ""}"
                          : "${dateToDayTitle(date)}, ${dateToTimeLabel(date)}",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                    if (entry["difficulty"] != null)
                      Text(
                        "${entry["difficulty"]}",
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statTile("${entry["minutes"] ?? 0}", "perc"),
              const SizedBox(width: 8),
              _statTile("${entry["calories"] ?? 0}", "kcal"),
              const SizedBox(width: 8),
              _statTile(
                volume > 0 ? "${volume.round()}" : "–",
                volume > 0 ? "kg" : "terhelés",
              ),
            ],
          ),
          if (rpe != null || progress != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (rpe != null)
                  _infoChip("RPE $rpe", TColor.primaryColor1),
                if (progress != null)
                  _infoChip(
                    _progressLabel(progress),
                    progress.volumeDeltaPercent != null &&
                            progress.volumeDeltaPercent! > 0
                        ? const Color(0xff2FA96B)
                        : TColor.gray,
                  ),
                _infoChip(
                  "${entry["completedSets"] ?? 0}/${entry["totalSets"] ?? 0} kör",
                  TColor.gray,
                ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          Text(
            "Gyakorlatok",
            style: TextStyle(
                color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (exercises.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                "Ehhez az edzéshez nem maradt meg a gyakorlatlista. Az újabb befejezett edzéseknél már látszik a részletes napló.",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
            )
          else
            ...exercises.map(_exerciseCard),
        ],
      ),
    );
  }

  String _progressLabel(WorkoutProgress progress) {
    final percent = progress.volumeDeltaPercent;
    if (percent != null && percent.abs() >= 1) {
      return "${percent > 0 ? "+" : ""}${percent.round()}% az előzőhöz képest";
    }
    if (progress.caloriesDelta != 0) {
      return "${progress.caloriesDelta > 0 ? "+" : ""}${progress.caloriesDelta} kcal az előzőhöz képest";
    }
    return "Hasonló az előzőhöz";
  }

  Widget _statTile(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: TColor.lightGray,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _exerciseCard(Map<String, dynamic> exercise) {
    final rounds = (exercise["rounds"] as num?)?.toInt() ?? 1;
    final repetitions = exercise["repetitions"] ?? 0;
    final weights = exercise["roundWeights"];
    final weightLabel = weights is List && weights.isNotEmpty
        ? weights.map((w) => "${w}kg").join(" · ")
        : "${exercise["weight"] ?? 0} kg";

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "${exercise["image"] ?? "assets/img/Workout1.png"}",
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${exercise["name"] ?? "Gyakorlat"}",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  "$repetitions ismétlés · $rounds kör",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                Text(
                  weightLabel,
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigáció a befejezett edzés részleteire – a sorok ezt hívják.
void openCompletedWorkoutDetail(
  BuildContext context,
  Map<String, dynamic> entry,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CompletedWorkoutDetailView(entry: entry),
    ),
  );
}
