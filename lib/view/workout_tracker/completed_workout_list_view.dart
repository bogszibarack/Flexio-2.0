import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/completed_workout_row.dart';
import 'workout_store.dart';

class CompletedWorkoutListView extends StatelessWidget {
  const CompletedWorkoutListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: WorkoutStore.revision,
      builder: (context, _, __) {
        final entries = WorkoutStore.completedWorkoutsByDateDesc;
    final totalMinutes = entries.fold<int>(
        0, (sum, entry) => sum + (entry["minutes"] as int));
    final totalCalories = entries.fold<int>(
        0, (sum, entry) => sum + (entry["calories"] as int));

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
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
          "Fejlődés",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: entries.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Még nincs befejezett edzésed. Indíts el egyet az edzés részleteinél, és itt látod majd a fejlődésed.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem("${entries.length}", "edzés"),
                        _summaryItem("$totalMinutes", "perc"),
                        _summaryItem("$totalCalories", "kcal"),
                      ],
                    ),
                  );
                }

                final entry = entries[index - 1];
                return CompletedWorkoutRow(
                  entry: entry,
                  progress: WorkoutStore.progressionFor(entry),
                );
              },
            ),
    );
      },
    );
  }

  Widget _summaryItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
      ],
    );
  }
}
