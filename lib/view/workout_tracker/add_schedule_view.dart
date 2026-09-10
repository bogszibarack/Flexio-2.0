import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/sheet_option.dart';
import 'workout_store.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;
  final Map<String, dynamic>? workout;
  const AddScheduleView({super.key, required this.date, this.workout});

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  late DateTime selectedDateTime;
  Map<String, dynamic>? selectedWorkout;

  @override
  void initState() {
    super.initState();
    selectedDateTime = widget.date;
    selectedWorkout = widget.workout;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
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
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Ütemezés Hozzáadása",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Image.asset(
                "assets/img/date.png",
                width: 20,
                height: 20,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                "${_capitalize(dateToWeekday(widget.date))}, ${dateToYearMonthDay(widget.date)}",
                style: TextStyle(color: TColor.gray, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Idő",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(
            height: media.width * 0.35,
            child: CupertinoDatePicker(
              onDateTimeChanged: (newDate) {
                selectedDateTime = DateTime(
                  widget.date.year,
                  widget.date.month,
                  widget.date.day,
                  newDate.hour,
                  newDate.minute,
                );
              },
              initialDateTime: selectedDateTime,
              use24hFormat: true,
              minuteInterval: 1,
              mode: CupertinoDatePickerMode.time,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Edzés részletei",
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 8,
          ),
          IconTitleNextRow(
              icon: "assets/img/choose_workout.png",
              title: "Edzés kiválasztása",
              time: selectedWorkout?["title"]?.toString() ??
                  "Válassz edzést",
              color: TColor.lightGray,
              onPressed: _showWorkoutPicker),
          const SizedBox(
            height: 10,
          ),
          IconTitleNextRow(
              icon: "assets/img/difficulity.png",
              title: "Nehézség",
              time: selectedWorkout?["difficulty"]?.toString() ?? "-",
              color: TColor.lightGray,
              onPressed: () {}),
          Spacer(),
          RoundButton(
            title: "Mentés",
            onPressed: () {
              if (selectedWorkout == null) {
                return;
              }
              WorkoutStore.addScheduledWorkout({
                ...selectedWorkout!,
                "id": null,
                "date": selectedDateTime,
                "workout": selectedWorkout,
              });
              Navigator.pop(context);
            },
          ),
          const SizedBox(
            height: 20,
          ),
        ]),
      ),
    );
  }

  void _showWorkoutPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: WorkoutStore.workouts.isEmpty
            ? Padding(
                padding: const EdgeInsets.all(30),
                child: Text(
                  "Még nincs edzésed. Hozz létre egyet az edzéskövetőben, utána tudod ütemezni.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: WorkoutStore.workouts.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final workout = WorkoutStore.workouts[index];
                  return SheetOption(
                    title: workout["title"].toString(),
                    subtitle:
                        "${workout["exercises"]} · ${workout["difficulty"]}",
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        workout["image"].toString(),
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        selectedWorkout = workout;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
      ),
    );
  }
}

String _capitalize(String value) =>
    value.isEmpty ? value : "${value[0].toUpperCase()}${value.substring(1)}";

