import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common/common.dart';
import 'package:fitness/view/workout_tracker/completed_workout_list_view.dart';
import 'package:fitness/view/workout_tracker/create_workout_view.dart';
import 'package:fitness/view/workout_tracker/scheduled_workout_list_view.dart';
import 'package:fitness/view/workout_tracker/workour_detail_view.dart';
import 'package:fitness/view/workout_tracker/workout_schedule_view.dart';
import 'package:fitness/view/workout_tracker/workout_store.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers.dart';

import '../../common_widget/completed_workout_row.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/upcoming_workout_row.dart';
import '../../common_widget/what_train_row.dart';

class WorkoutTrackerView extends ConsumerStatefulWidget {
  const WorkoutTrackerView({super.key});

  @override
  ConsumerState<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends ConsumerState<WorkoutTrackerView> {
  WorkoutMetric _metric = WorkoutMetric.calories;

  @override
  void initState() {
    super.initState();
    WorkoutStore.revision.addListener(_onStoreChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthSyncProvider).pullFromApple();
    });
  }

  @override
  void dispose() {
    WorkoutStore.revision.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  List<Map<String, dynamic>> get upcomingArr =>
      WorkoutStore.upcomingScheduledWorkouts.take(2).toList();

  List<Map<String, dynamic>> get whatArr => WorkoutStore.workouts;

  List<Map<String, dynamic>> get completedArr =>
      WorkoutStore.completedWorkoutsByDateDesc.take(3).toList();

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              // pinned: true,
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
                "Edzéskövető",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: const SizedBox(),
              expandedHeight: media.width * 0.5 + 40,
              flexibleSpace: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                height: media.width * 0.5 + 40,
                width: double.maxFinite,
                child: Column(
                  children: [
                    _buildChartHeader(),
                    Expanded(
                      child: WorkoutStore.completedWorkouts.isEmpty
                          ? Center(
                              child: Text(
                                "Fejezz be egy edzést, és itt jelenik meg a heti kalória- és időadatod.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: TColor.white.withValues(alpha: 0.9),
                                    fontSize: 12),
                              ),
                            )
                          : LineChart(_buildChartData()),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: Material(
          color: TColor.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                        color: TColor.gray.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Napi Edzés Tervező",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 70,
                          height: 25,
                          child: RoundButton(
                            title: "Megtekintés",
                            type: RoundButtonType.bgGradient,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const WorkoutScheduleView(),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Következő Edzés",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ScheduledWorkoutListView(),
                            ),
                          );
                          setState(() {});
                        },
                        child: Text(
                          "Összes megtekintése",
                          style: TextStyle(
                              color: TColor.gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                  if (upcomingArr.isEmpty)
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Még nincs ütemezett edzésed. Válassz egy edzést, és add hozzá a tervezőhöz.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    )
                  else
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: upcomingArr.length,
                        itemBuilder: (context, index) {
                          final event = upcomingArr[index];
                          final date = event["date"] as DateTime;
                          return UpcomingWorkoutRow(
                            wObj: event,
                            subtitle:
                                "${dateToDayTitle(date)}, ${dateToTimeLabel(date)} | ${event["exercises"]}",
                            isPlannedToday: true,
                            onPlannedTodayChanged: (isPlanned) {
                              if (!isPlanned) {
                                _removeScheduledWorkout(event);
                              }
                            },
                          );
                        }),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Fejlődés",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CompletedWorkoutListView(),
                            ),
                          );
                          setState(() {});
                        },
                        child: Text(
                          "Összes megtekintése",
                          style: TextStyle(
                              color: TColor.gray,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      )
                    ],
                  ),
                  if (completedArr.isEmpty)
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Nyisd meg egy edzést, indítsd el, és a befejezés után itt látod, mennyivel volt nehezebb az előzőnél.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    )
                  else
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: completedArr.length,
                        itemBuilder: (context, index) {
                          final entry = completedArr[index];
                          return CompletedWorkoutRow(
                            entry: entry,
                            progress: WorkoutStore.progressionFor(entry),
                          );
                        }),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Mire Szeretnél Edzeni?",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  if (whatArr.isEmpty)
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Még nincs edzésed. Hozz létre egyet lentebb, add hozzá a gyakorlatokat, és már ütemezhető is.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    )
                  else
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: whatArr.length,
                      itemBuilder: (context, index) {
                        final wObj = whatArr[index];
                        return Dismissible(
                          key: ValueKey(wObj),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 2),
                            padding: const EdgeInsets.only(right: 24),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.delete_outline,
                                color: Colors.white),
                          ),
                          confirmDismiss: (direction) =>
                              _confirmDeleteWorkout(wObj),
                          onDismissed: (direction) {
                            setState(() => WorkoutStore.removeWorkout(wObj));
                          },
                          child: InkWell(
                            onTap: () => _openWorkoutDetail(wObj),
                            child: WhatTrainRow(
                              wObj: wObj,
                              onDetailsPressed: () => _openWorkoutDetail(wObj),
                            ),
                          ),
                        );
                      },
                    ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  SizedBox(
                    width: double.maxFinite,
                    height: 50,
                    child: RoundButton(
                      title: "Új Edzés Létrehozása",
                      type: RoundButtonType.bgGradient,
                      onPressed: () async {
                        var result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateWorkoutView(),
                          ),
                        );
                        if (result != null && result is Map) {
                          setState(() {
                            WorkoutStore.addWorkout(
                                Map<String, dynamic>.from(result));
                          });
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }

  Future<void> _openWorkoutDetail(Map<String, dynamic> workout) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutDetailView(dObj: workout),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<bool> _confirmDeleteWorkout(Map<String, dynamic> workout) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Edzés törlése"),
            content: Text(
                "Biztosan törlöd a(z) „${workout["title"]}” edzést és minden ütemezését?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Mégse"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Törlés"),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _removeScheduledWorkout(Map<String, dynamic> event) {
    final index = WorkoutStore.scheduledWorkouts.indexOf(event);
    if (index < 0) {
      return;
    }

    setState(() {
      WorkoutStore.removeScheduledWorkout(event);
    });

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      duration: const Duration(seconds: 4),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.secondaryG),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.delete_outline, color: TColor.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["title"].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Eltávolítva a tervezőből",
                    style: TextStyle(color: TColor.gray, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                messenger.hideCurrentSnackBar();
                setState(() {
                  WorkoutStore.restoreScheduledWorkout(event, at: index);
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  "Visszavonás",
                  style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 12,
                      fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }


  String get _metricUnit =>
      _metric == WorkoutMetric.calories ? "kcal" : "perc";

  List<double> get _thisWeekTotals => WorkoutStore.weeklyTotals(
      WorkoutStore.startOfWeek(DateTime.now()),
      metric: _metric);

  List<double> get _lastWeekTotals => WorkoutStore.weeklyTotals(
      WorkoutStore.startOfWeek(DateTime.now())
          .subtract(const Duration(days: 7)),
      metric: _metric);

  double get _chartMaxY {
    final highest = [..._thisWeekTotals, ..._lastWeekTotals]
        .fold<double>(0, (max, value) => value > max ? value : max);
    final fallback = _metric == WorkoutMetric.calories ? 400.0 : 60.0;
    if (highest <= 0) {
      return fallback;
    }
    final step = _metric == WorkoutMetric.calories ? 100.0 : 15.0;
    return ((highest * 1.25) / step).ceil() * step;
  }

  Widget _buildChartHeader() {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          _metricChip("Kalória", WorkoutMetric.calories),
          const SizedBox(width: 6),
          _metricChip("Perc", WorkoutMetric.minutes),
          const Spacer(),
          _legendItem("Ez a hét", TColor.white, 3),
          const SizedBox(width: 8),
          _legendItem("Előző hét", TColor.white.withValues(alpha: 0.5), 2),
        ],
      ),
    );
  }

  Widget _metricChip(String label, WorkoutMetric metric) {
    final isSelected = _metric == metric;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _metric = metric;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? TColor.white : TColor.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? TColor.primaryColor1 : TColor.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _legendItem(String label, Color color, double thickness) {
    return Row(
      children: [
        Container(width: 12, height: thickness, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: TColor.white, fontSize: 9),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    final maxY = _chartMaxY;

    return LineChartData(
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (spot) => TColor.secondaryColor1,
          tooltipRoundedRadius: 20,
          getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
            return lineBarsSpot.map((lineBarSpot) {
              final isThisWeek = lineBarSpot.barIndex == 0;
              return LineTooltipItem(
                "${isThisWeek ? "Ez a hét" : "Előző hét"}: ${lineBarSpot.y.round()} $_metricUnit",
                const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        _weekLineData(_thisWeekTotals, TColor.white, 4),
        _weekLineData(_lastWeekTotals, TColor.white.withValues(alpha: 0.5), 2),
      ],
      minY: 0,
      maxY: maxY,
      titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(),
          topTitles: AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: bottomTitles,
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: maxY / 4,
              reservedSize: 42,
              getTitlesWidget: (value, meta) => Text(
                value.round().toString(),
                style: TextStyle(color: TColor.white, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          )),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: maxY / 4,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: TColor.white.withValues(alpha: 0.15),
            strokeWidth: 2,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: Colors.transparent,
        ),
      ),
    );
  }

  LineChartBarData _weekLineData(
      List<double> totals, Color color, double barWidth) {
    return LineChartBarData(
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: barWidth,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: List.generate(
          7, (index) => FlSpot((index + 1).toDouble(), totals[index])),
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.white,
      fontSize: 12,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = Text('Vas', style: style);
        break;
      case 2:
        text = Text('Hét', style: style);
        break;
      case 3:
        text = Text('Ked', style: style);
        break;
      case 4:
        text = Text('Sze', style: style);
        break;
      case 5:
        text = Text('Csü', style: style);
        break;
      case 6:
        text = Text('Pén', style: style);
        break;
      case 7:
        text = Text('Szo', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}
