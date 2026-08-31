import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import 'workour_detail_view.dart';
import 'workout_store.dart';

class ScheduledWorkoutListView extends StatefulWidget {
  const ScheduledWorkoutListView({super.key});

  @override
  State<ScheduledWorkoutListView> createState() =>
      _ScheduledWorkoutListViewState();
}

class _ScheduledWorkoutListViewState extends State<ScheduledWorkoutListView> {
  List<Map<String, dynamic>> get scheduledArr =>
      WorkoutStore.scheduledWorkoutsByDate;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

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
          "Ütemezett Edzések",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: scheduledArr.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "Még nincs edzés a tervezőben.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: 20, vertical: media.width * 0.03),
              itemCount: scheduledArr.length,
              itemBuilder: (context, index) {
                final event = scheduledArr[index];
                final date = event["date"] as DateTime;
                final showDayTitle = index == 0 ||
                    dateToStartDate(scheduledArr[index - 1]["date"] as DateTime)
                        != dateToStartDate(date);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDayTitle)
                      Padding(
                        padding: EdgeInsets.only(
                            top: index == 0 ? 0 : 15, bottom: 5),
                        child: Text(
                          dateToDayTitle(date),
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    _scheduleRow(event, date),
                  ],
                );
              },
            ),
    );
  }

  Widget _scheduleRow(Map<String, dynamic> event, DateTime date) {
    return Dismissible(
      key: ValueKey(event),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 24),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          WorkoutStore.removeScheduledWorkout(event);
        });
      },
      child: InkWell(
        onTap: () async {
          final workout = event["workout"];
          if (workout is! Map) {
            return;
          }

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutDetailView(dObj: workout),
            ),
          );
          setState(() {});
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2)
              ]),
          child: Row(
            children: [
              SizedBox(
                width: 55,
                child: Text(
                  dateToTimeLabel(date),
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  event["image"].toString(),
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
                      event["title"].toString(),
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      "${event["exercises"]} · ${event["difficulty"] ?? "Kezdő"}",
                      style: TextStyle(color: TColor.gray, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: TColor.gray, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
