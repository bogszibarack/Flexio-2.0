import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/round_button.dart';
import 'add_schedule_view.dart';
import 'workout_store.dart';

class WorkoutScheduleView extends StatefulWidget {
  final Map<String, dynamic>? workout;
  const WorkoutScheduleView({super.key, this.workout});

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;

  List eventArr = [];

  List selectDayEventArr = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    eventArr = WorkoutStore.scheduledWorkouts;
    setDayEventWorkoutList();
  }

  void setDayEventWorkoutList() {
    var date = dateToStartDate(_selectedDateAppBBar);
    selectDayEventArr = eventArr.map((wObj) {
      return {
        "name": wObj["title"],
        "date": wObj["date"] as DateTime,
        "event": wObj,
      };
    }).where((wObj) {
      return dateToStartDate(wObj["date"] as DateTime) == date;
    }).toList();

    if( mounted  ) {
      setState(() {
        
      });
    }
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
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Edzés ütemezése",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
            appbar: false,
            selectedDayPosition: SelectedDayPosition.center,
            leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowLeft.png",
                  width: 15,
                  height: 15,
                )),
            training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowRight.png",
                  width: 15,
                  height: 15,
                )),
            weekDay: WeekDay.short,
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withValues(alpha: 0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            // fullCalendar: false,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,
            locale: 'hu',

            initialDate: DateTime.now(),
            calendarEventColor: TColor.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),

            onDateSelected: (date) {
              _selectedDateAppBBar = date;
              setDayEventWorkoutList();
              
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: media.width * 1.5,
                child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var availWidth = (media.width * 1.2) - (80 + 40);
                      var slotArr = selectDayEventArr.where((wObj) {
                        return (wObj["date"] as DateTime).hour == index;
                      }).toList();

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                getTime(index * 60),
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            if (slotArr.isNotEmpty)
                              Expanded(
                                  child: Stack(
                                alignment: Alignment.centerLeft,
                                children: slotArr.map((sObj) {
                                  var min = (sObj["date"] as DateTime).minute;
                                  //(0 to 2)
                                  var pos = (min / 60) * 2 - 1;

                                  return Align(
                                    alignment: Alignment(pos, 0),
                                    child: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: Colors.transparent,
                                              contentPadding: EdgeInsets.zero,
                                              content: Container(
                                                padding: const EdgeInsets.symmetric( vertical:15 , horizontal: 20 ),
                                                decoration: BoxDecoration(
                                                  color: TColor.white,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            height: 40,
                                                            width: 40,
                                                            alignment:
                                                                Alignment.center,
                                                            decoration: BoxDecoration(
                                                                color: TColor
                                                                    .lightGray,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Image.asset(
                                                              "assets/img/closed_btn.png",
                                                              width: 15,
                                                              height: 15,
                                                              fit: BoxFit.contain,
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          "Edzés ütemezése",
                                                          style: TextStyle(
                                                              color: TColor.black,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700),
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            WorkoutStore
                                                                .scheduledWorkouts
                                                                .remove(sObj[
                                                                    "event"]);
                                                            Navigator.pop(
                                                                context);
                                                            setDayEventWorkoutList();
                                                          },
                                                          child: Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .all(8),
                                                            height: 40,
                                                            width: 40,
                                                            alignment:
                                                                Alignment.center,
                                                            decoration: BoxDecoration(
                                                                color: TColor
                                                                    .lightGray,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                            child: Icon(
                                                              Icons.delete_outline,
                                                              color: TColor.gray,
                                                              size: 20,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text(
                                                      sObj["name"].toString(),
                                                      style: TextStyle(
                                                          color: TColor.black,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                                    const SizedBox(   
                                                      height: 4,
                                                    ),
                                                    Row(children: [
                                                      Image.asset(
                                                        "assets/img/time_workout.png",
                                                        height: 20,
                                                        width: 20,
                                                      ),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                        _formatScheduleTime(
                                                            sObj["date"] as DateTime),
                                                        style: TextStyle(
                                                            color: TColor.gray,
                                                            fontSize: 12),
                                                      )
                                                    ]),
                                            
                                                     const SizedBox(
                                                      height: 15,
                                                    ),
                                            
                                                    RoundButton(
                                                        title: "Kész",
                                                        onPressed: () {
                                                          _markScheduleDone(
                                                              sObj["event"]
                                                                  as Map<String,
                                                                      dynamic>);
                                                          Navigator.pop(
                                                              context);
                                                        }),
                                            
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Container(
                                        height: 35,
                                        width: availWidth * 0.5,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: TColor.secondaryG),
                                          borderRadius:
                                              BorderRadius.circular(17.5),
                                        ),
                                        child: Text(
                                          "${sObj["name"].toString()}, ${_formatScheduleTime(sObj["date"] as DateTime)}",
                                          maxLines: 1,
                                          style: TextStyle(
                                            color: TColor.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ))
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: TColor.gray.withValues(alpha: 0.2),
                        height: 1,
                      );
                    },
                    itemCount: 24),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddScheduleView(
                        date: _selectedDateAppBBar,
                       workout: widget.workout,
                     ))).then((_) => setDayEventWorkoutList());
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }

  void _markScheduleDone(Map<String, dynamic> event) {
    if (event["completedAt"] != null) {
      return;
    }

    final workout = event["workout"];
    WorkoutStore.logCompletedWorkout(
      title: event["title"].toString(),
      image: event["image"].toString(),
      difficulty: event["difficulty"]?.toString() ?? "Kezdő",
      minutes: WorkoutStore.minutesForLogging(event),
      date: event["date"] as DateTime,
      workout: workout is Map ? Map<String, dynamic>.from(workout) : null,
    );
    event["completedAt"] = DateTime.now();
    WorkoutStore.updateScheduledWorkout(event);
    setDayEventWorkoutList();
  }

  String _formatScheduleTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }
}
