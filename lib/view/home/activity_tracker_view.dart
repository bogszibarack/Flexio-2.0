import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/app_haptics.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/latest_activity_row.dart';
import '../../common_widget/today_target_cell.dart';
import '../../data/daily_water_store.dart';
import '../../data/models/diary_entry.dart';
import '../../data/providers.dart';
import '../sleep_tracker/sleep_store.dart';
import '../workout_tracker/completed_workout_list_view.dart';
import '../workout_tracker/workout_store.dart';

class ActivityTrackerView extends ConsumerStatefulWidget {
  const ActivityTrackerView({super.key});

  @override
  ConsumerState<ActivityTrackerView> createState() =>
      _ActivityTrackerViewState();
}

class _ActivityTrackerViewState extends ConsumerState<ActivityTrackerView> {
  int touchedIndex = -1;
  String _range = "Heti";

  static const List<String> _weekDayLabels = [
    "Vas",
    "Hét",
    "Kedd",
    "Sze",
    "Csü",
    "Pén",
    "Szo",
  ];

  @override
  void initState() {
    super.initState();
    WorkoutStore.revision.addListener(_onStoreChanged);
    SleepStore.revision.addListener(_onStoreChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthSyncProvider).pullFromApple();
    });
  }

  @override
  void dispose() {
    WorkoutStore.revision.removeListener(_onStoreChanged);
    SleepStore.revision.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _addWater() async {
    final result = await promptWaterAmount(context);
    if (result == null) {
      return;
    }
    AppHaptics.medium();
    await ref.read(dailyWaterProvider).add(result);
    ref.read(healthSyncProvider).syncWaterMl(result);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final water = ref.watch(dailyWaterProvider);
    final health = ref.watch(healthSyncProvider);
    final meals = ref.watch(mealStoreProvider).entries;
    final latest = _latestActivities(water.sips, meals);

    final isWeekly = _range == "Heti";
    final values = isWeekly
        ? WorkoutStore.weeklyTotals(
            WorkoutStore.startOfWeek(DateTime.now()),
            metric: WorkoutMetric.calories,
          )
        : WorkoutStore.lastFourWeeksTotals(metric: WorkoutMetric.calories);
    final hasChartData = values.any((value) => value > 0);
    final maxValue = values.fold<double>(0, (max, value) => value > max ? value : max);
    final backgroundY = maxValue <= 0 ? 1.0 : maxValue * 1.2;

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
          "Aktivitás",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    TColor.primaryColor2.withValues(alpha: 0.3),
                    TColor.primaryColor1.withValues(alpha: 0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Mai cél",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.primaryG,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: _addWater,
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: TColor.primaryColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/water.png",
                            value: litersLabel(water.totalMl),
                            title: "Vízbevitel",
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/foot.png",
                            value: health.todaySteps == null
                                ? "–"
                                : "${health.todaySteps}",
                            title: health.enabled
                                ? "Lépések"
                                : "Apple Health ki",
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Aktivitás előrehaladás",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.primaryG),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Material(
                      type: MaterialType.transparency,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _range,
                          items: ["Heti", "Havi"]
                              .map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: TColor.gray, fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() => _range = value);
                          },
                          icon: Icon(Icons.expand_more, color: TColor.white),
                          dropdownColor: TColor.white,
                          style: TextStyle(color: TColor.white, fontSize: 12),
                        ),
                      )),
                      ),
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ]),
                child: hasChartData
                    ? BarChart(
                        BarChartData(
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (group) => Colors.grey,
                              tooltipHorizontalAlignment:
                                  FLHorizontalAlignment.right,
                              tooltipMargin: 10,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                final label = isWeekly
                                    ? _weekDayLabels[group.x.toInt()]
                                    : "${group.x.toInt() + 1}. hét";
                                return BarTooltipItem(
                                  "$label\n",
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: "${rod.toY.round()} kcal",
                                      style: TextStyle(
                                        color: TColor.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            touchCallback: (FlTouchEvent event, barTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    barTouchResponse == null ||
                                    barTouchResponse.spot == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex =
                                    barTouchResponse.spot!.touchedBarGroupIndex;
                              });
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) =>
                                    getTitles(value, meta, isWeekly),
                                reservedSize: 38,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          barGroups: [
                            for (var i = 0; i < values.length; i++)
                              makeGroupData(
                                i,
                                values[i],
                                i.isEven ? TColor.primaryG : TColor.secondaryG,
                                backgroundY: backgroundY,
                                isTouched: i == touchedIndex,
                              ),
                          ],
                          gridData: const FlGridData(show: false),
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            isWeekly
                                ? "Ezen a héten még nincs befejezett edzésed."
                                : "Az elmúlt négy hétben még nincs befejezett edzésed.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: TColor.gray, fontSize: 12),
                          ),
                        ),
                      ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Legutóbbi aktivitás",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const CompletedWorkoutListView(),
                        ),
                      );
                    },
                    child: Text(
                      "Több",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              if (latest.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Még nincs naplózott aktivitásod.",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  ),
                )
              else
                ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: latest.length,
                    itemBuilder: (context, index) {
                      return LatestActivityRow(wObj: latest[index]);
                    }),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _latestActivities(
    List<WaterSip> sips,
    List<DiaryEntry> meals,
  ) {
    final items = <({DateTime at, Map<String, String> row})>[];

    for (final entry in WorkoutStore.completedWorkoutsByDateDesc.take(5)) {
      final date = entry["date"];
      if (date is! DateTime) {
        continue;
      }
      final image = "${entry["image"] ?? ""}";
      items.add((
        at: date,
        row: {
          "image": image.startsWith("assets/")
              ? image
              : "assets/img/Workout1.png",
          "title": "${entry["title"] ?? "Edzés"} · ${entry["calories"] ?? 0} kcal",
          "time": relativeTimeHu(date),
        },
      ));
    }

    final recentMeals = List<DiaryEntry>.from(meals)
      ..sort((a, b) => b.loggedAt.compareTo(a.loggedAt));
    for (final meal in recentMeals.take(8)) {
      items.add((
        at: meal.loggedAt,
        row: {
          "image": "assets/img/pic_5.png",
          "title": "${meal.mealType}: ${meal.foodName}",
          "time": relativeTimeHu(meal.loggedAt),
        },
      ));
    }

    for (final sip in sips) {
      items.add((
        at: sip.at,
        row: {
          "image": "assets/img/pic_4.png",
          "title": "${sip.ml} ml víz",
          "time": relativeTimeHu(sip.at),
        },
      ));
    }

    final lastNight = SleepStore.lastNight;
    if (lastNight != null) {
      items.add((
        at: lastNight.wakeTime,
        row: {
          "image": "assets/img/sleep_schedule.png",
          "title": "Alvás · ${lastNight.durationLabel}",
          "time": relativeTimeHu(lastNight.wakeTime),
        },
      ));
    }

    items.sort((a, b) => b.at.compareTo(a.at));
    return items.take(8).map((item) => item.row).toList();
  }

  Widget getTitles(double value, TitleMeta meta, bool weekly) {
    var style = TextStyle(
      color: TColor.gray,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    );
    final index = value.toInt();
    final label = weekly
        ? (index >= 0 && index < _weekDayLabels.length
            ? _weekDayLabels[index]
            : "")
        : "${index + 1}.hét";
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: Text(label, style: style),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y,
    List<Color> barColor, {
    required double backgroundY,
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y <= 0 ? 0.01 : y,
          gradient: LinearGradient(
              colors: barColor,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: backgroundY,
            color: TColor.lightGray,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}
