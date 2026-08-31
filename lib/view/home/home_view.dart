import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/workout_row.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import '../../common/app_haptics.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/today_target_cell.dart';
import '../../data/daily_water_store.dart';
import '../../data/providers.dart';
import '../meal_planner/meal_planner_view.dart';
import '../profile/personal_data_view.dart';
import '../sleep_tracker/sleep_store.dart';
import '../sleep_tracker/sleep_tracker_view.dart';
import '../workout_tracker/completed_workout_list_view.dart';
import '../workout_tracker/workout_store.dart';
import 'activity_tracker_view.dart';
import 'notification_view.dart';

class HomeView extends ConsumerStatefulWidget {
  final String? firstName;

  const HomeView({super.key, this.firstName});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  List<int> showingTooltipOnSpots = [];
  String _progressRange = "Heti";

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
      ref.read(coachServiceProvider).maybeWeeklySummary(
            profile: ref.read(profileControllerProvider).profile,
            store: ref.read(mealStoreProvider),
          );
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

  Future<void> addWaterAmount() async {
    final result = await promptWaterAmount(context);
    if (result == null) {
      return;
    }

    AppHaptics.medium();
    await ref.read(dailyWaterProvider).add(result);
    ref.read(healthSyncProvider).syncWaterMl(result);
  }

  String get safeFirstName {
    final fromWidget = (widget.firstName ?? '').trim();
    if (fromWidget.isNotEmpty) {
      return fromWidget;
    }
    return (ref.read(profileControllerProvider).profile.firstName ?? '').trim();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final profile = ref.watch(profileControllerProvider).profile;
    final water = ref.watch(dailyWaterProvider);
    final waterGoalMl = profile.goals.waterMl <= 0 ? 2500 : profile.goals.waterMl;
    final totalWaterMl = water.totalMl;
    final waterRatio = (totalWaterMl / waterGoalMl).clamp(0.0, 1.0);
    final visibleSips = water.sips.length <= 6
        ? water.sips
        : water.sips.sublist(water.sips.length - 6);
    final waterArr = visibleSips
        .map((sip) => {
              "title": sip.clockLabel,
              "subtitle": "${sip.ml} ml",
            })
        .toList();

    final mealStore = ref.watch(mealStoreProvider);
    final todayTotals =
        mealStore.totalsOf(mealStore.mealsForDay(DateTime.now()));
    final calorieGoal = mealStore.dailyCalorieGoal;
    final consumedCalories = todayTotals.calories;
    final remainingCalories = (calorieGoal - consumedCalories).round();
    final calorieRatio =
        calorieGoal <= 0 ? 0.0 : (consumedCalories / calorieGoal).clamp(0.0, 1.0);

    final lastNight = SleepStore.lastNight;
    final sleepHours = SleepStore.weeklyHours(
      SleepStore.startOfWeek(DateTime.now()),
    );
    final hasSleepWeek = sleepHours.any((hours) => hours > 0);
    final lastWorkouts = WorkoutStore.completedWorkoutsByDateDesc
        .take(3)
        .map(WorkoutStore.asWorkoutRow)
        .toList();

    final isWeekly = _progressRange == "Heti";
    final workoutCalories = isWeekly
        ? WorkoutStore.weeklyTotals(
            WorkoutStore.startOfWeek(DateTime.now()),
            metric: WorkoutMetric.calories,
          )
        : WorkoutStore.lastFourWeeksTotals(metric: WorkoutMetric.calories);
    final workoutMinutes = isWeekly
        ? WorkoutStore.weeklyTotals(
            WorkoutStore.startOfWeek(DateTime.now()),
            metric: WorkoutMetric.minutes,
          )
        : WorkoutStore.lastFourWeeksTotals(metric: WorkoutMetric.minutes);
    final hasWorkoutData = workoutCalories.any((value) => value > 0) ||
        workoutMinutes.any((value) => value > 0);

    final health = ref.watch(healthSyncProvider);
    final heart = health.heartRate;
    final heartSpots = heart.hourly
        .map((point) => FlSpot(point.hour, point.bpm))
        .toList();
    final heartTooltip = showingTooltipOnSpots.isEmpty && heartSpots.isNotEmpty
        ? [heartSpots.length - 1]
        : showingTooltipOnSpots.where((i) => i >= 0 && i < heartSpots.length).toList();

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: heartTooltip,
        spots: heartSpots.isEmpty ? const [FlSpot(0, 0)] : heartSpots,
        isCurved: true,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2.withValues(alpha: 0.4),
            TColor.primaryColor1.withValues(alpha: 0.1),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(
          colors: TColor.primaryG,
        ),
      ),
    ];

    final tooltipsOnBar = lineBarsData[0];

    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Üdv újra,",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                        Text(
                          safeFirstName.isNotEmpty ? safeFirstName : "Barátom",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 20,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          AppHaptics.light();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationView(),
                            ),
                          );
                        },
                        icon: Image.asset(
                          "assets/img/notification_active.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        ))
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  height: media.width * 0.4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primaryG),
                      borderRadius: BorderRadius.circular(media.width * 0.075)),
                  child: Stack(alignment: Alignment.center, children: [
                    Image.asset(
                      "assets/img/bg_dots.png",
                      height: media.width * 0.4,
                      width: double.maxFinite,
                      fit: BoxFit.fitHeight,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "BMI (Testtömegindex)",
                                  style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  profile.bmiLabel,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color:
                                          TColor.white.withValues(alpha: 0.7),
                                      fontSize: 12),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                    width: 120,
                                    height: 35,
                                    child: RoundButton(
                                        title: "Részletek",
                                        type: RoundButtonType.bgSGradient,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const PersonalDataView(),
                                            ),
                                          );
                                        }))
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: media.width * 0.22,
                            height: media.width * 0.22,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (FlTouchEvent event,
                                      pieTouchResponse) {},
                                ),
                                startDegreeOffset: 250,
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 1,
                                centerSpaceRadius: 0,
                                sections: showingSections(profile.bmi),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ]),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor2.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
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
                        width: 70,
                        height: 25,
                        child: RoundButton(
                          title: "Megnézem",
                          type: RoundButtonType.bgGradient,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ActivityTrackerView(),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                if (health.isSupported)
                  Padding(
                    padding: EdgeInsets.only(top: media.width * 0.03),
                    child: TodayTargetCell(
                      icon: "assets/img/foot.png",
                      value: health.todaySteps == null
                          ? "–"
                          : "${health.todaySteps}",
                      title: health.enabled
                          ? "Lépések ma"
                          : "Apple Health nincs összekötve",
                    ),
                  ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "Mai pulzus",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.02,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    height: media.width * 0.4,
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Stack(
                      alignment: Alignment.topLeft,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pulzus",
                                style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                          colors: TColor.primaryG,
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight)
                                      .createShader(Rect.fromLTRB(
                                          0, 0, bounds.width, bounds.height));
                                },
                                child: Text(
                                  heart.latestBpm == null
                                      ? "–"
                                      : "${heart.latestBpm!.round()} BPM",
                                  style: TextStyle(
                                      color: TColor.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18),
                                ),
                              ),
                              if (heart.restingBpm != null)
                                Text(
                                  "Nyugalmi ${heart.restingBpm!.round()} bpm"
                                  "${heart.minBpm != null && heart.maxBpm != null ? " · ${heart.minBpm!.round()}–${heart.maxBpm!.round()}" : ""}",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 10),
                                ),
                            ],
                          ),
                        ),
                        if (!heart.hasData)
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 70, 20, 16),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  health.enabled
                                      ? "Ma még nincs pulzusadat. Apple Watch-csal a napi görbe ide kerül."
                                      : "Kapcsold össze az Apple Health-t a Profilban, és ide jön a valódi pulzusgörbe.",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 11, height: 1.4),
                                ),
                              ),
                            ),
                          )
                        else
                        LineChart(
                          LineChartData(
                            minX: 0,
                            maxX: 24,
                            minY: ((heart.minBpm ?? 60) - 15)
                                .clamp(30, 80)
                                .toDouble(),
                            maxY: ((heart.maxBpm ?? 100) + 15)
                                .clamp(90, 200)
                                .toDouble(),
                            showingTooltipIndicators:
                                heartTooltip.map((index) {
                              return ShowingTooltipIndicators([
                                LineBarSpot(
                                  tooltipsOnBar,
                                  lineBarsData.indexOf(tooltipsOnBar),
                                  tooltipsOnBar.spots[index],
                                ),
                              ]);
                            }).toList(),
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: false,
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return;
                                }
                                if (event is FlTapUpEvent) {
                                  final spotIndex =
                                      response.lineBarSpots!.first.spotIndex;
                                  setState(() {
                                    showingTooltipOnSpots = [spotIndex];
                                  });
                                }
                              },
                              mouseCursorResolver: (FlTouchEvent event,
                                  LineTouchResponse? response) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return SystemMouseCursors.basic;
                                }
                                return SystemMouseCursors.click;
                              },
                              getTouchedSpotIndicator:
                                  (LineChartBarData barData,
                                      List<int> spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: Colors.red,
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                        radius: 3,
                                        color: Colors.white,
                                        strokeWidth: 3,
                                        strokeColor: TColor.secondaryColor1,
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (LineBarSpot touchedSpot) =>
                                    TColor.secondaryColor1,
                                tooltipRoundedRadius: 20,
                                getTooltipItems:
                                    (List<LineBarSpot> lineBarsSpot) {
                                  return lineBarsSpot.map((lineBarSpot) {
                                    final hour = lineBarSpot.x.floor();
                                    return LineTooltipItem(
                                      "${lineBarSpot.y.round()} bpm · $hour:00",
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
                            lineBarsData: lineBarsData,
                            titlesData: FlTitlesData(
                              show: false,
                            ),
                            gridData: FlGridData(show: false),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: media.width * 0.95,
                        padding: const EdgeInsets.symmetric(
                            vertical: 25, horizontal: 20),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ]),
                        child: Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: addWaterAmount,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: TColor.primaryG,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 120,
                                  width: 22,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        width: 22,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeInOut,
                                        width: 22,
                                        height: 120 * waterRatio,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Vízbevitel",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    litersLabel(totalWaterMl),
                                    style: TextStyle(
                                        color: TColor.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  waterArr.isEmpty
                                      ? "Még nincs mai bejegyzés"
                                      : "Cél: ${litersLabel(waterGoalMl)}",
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 12,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: waterArr.map((wObj) {
                                    var isLast = wObj == waterArr.last;
                                    return Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 4),
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: TColor.secondaryColor1
                                                    .withValues(alpha: 0.5),
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                            ),
                                            if (!isLast)
                                              DottedDashedLine(
                                                  height: media.width * 0.078,
                                                  width: 0,
                                                  dashColor: TColor
                                                      .secondaryColor1
                                                      .withValues(alpha: 0.5),
                                                  axis: Axis.vertical)
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                wObj["title"].toString(),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: TColor.gray,
                                                  fontSize: 10,
                                                ),
                                              ),
                                              ShaderMask(
                                                blendMode: BlendMode.srcIn,
                                                shaderCallback: (bounds) {
                                                  return LinearGradient(
                                                          colors:
                                                              TColor.secondaryG,
                                                          begin: Alignment
                                                              .centerLeft,
                                                          end: Alignment
                                                              .centerRight)
                                                      .createShader(Rect.fromLTRB(
                                                          0,
                                                          0,
                                                          bounds.width,
                                                          bounds.height));
                                                },
                                                child: Text(
                                                  wObj["subtitle"].toString(),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: TColor.white
                                                          .withValues(alpha: 0.7),
                                                      fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  }).toList(),
                                )
                              ],
                            ))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: media.width * 0.05,
                    ),
                    Expanded(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const SleepTrackerView(),
                              ),
                            );
                          },
                          child: Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Alvás",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    lastNight?.durationLabel ?? "–",
                                    style: TextStyle(
                                        color: TColor.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: hasSleepWeek
                                      ? _homeSleepChart(sleepHours)
                                      : Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Nincs alvásadat ezen a héten.",
                                            style: TextStyle(
                                              color: TColor.gray,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                ),
                              ]),
                        ),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const MealPlannerView(),
                              ),
                            );
                          },
                          child: Container(
                          width: double.maxFinite,
                          height: media.width * 0.45,
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Kalóriák",
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700),
                                ),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                            colors: TColor.primaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight)
                                        .createShader(Rect.fromLTRB(
                                            0, 0, bounds.width, bounds.height));
                                  },
                                  child: Text(
                                    "${consumedCalories.round()} / ${calorieGoal.round()} kCal",
                                    style: TextStyle(
                                        color: TColor.white.withValues(alpha: 0.7),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: media.width * 0.2,
                                    height: media.width * 0.2,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          width: media.width * 0.15,
                                          height: media.width * 0.15,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: TColor.primaryG),
                                            borderRadius: BorderRadius.circular(
                                                media.width * 0.075),
                                          ),
                                          child: FittedBox(
                                            child: Text(
                                              remainingCalories >= 0
                                                  ? "${remainingCalories}kCal\nmaradt"
                                                  : "${remainingCalories.abs()}kCal\ntúllépve",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: TColor.white,
                                                  fontSize: 11),
                                            ),
                                          ),
                                        ),
                                        SimpleCircularProgressBar(
                                          progressStrokeWidth: 10,
                                          backStrokeWidth: 10,
                                          progressColors: TColor.primaryG,
                                          backColor: Colors.grey.shade100,
                                          valueNotifier: ValueNotifier(
                                              calorieRatio * 100),
                                          startAngle: -180,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ]),
                        ),
                        ),
                      ],
                    ))
                  ],
                ),
                SizedBox(
                  height: media.width * 0.1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Edzés előrehaladás",
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
                            value: _progressRange,
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
                              setState(() => _progressRange = value);
                            },
                            icon: Icon(Icons.expand_more, color: TColor.white),
                            dropdownColor: TColor.white,
                            style: TextStyle(
                                color: TColor.white, fontSize: 12),
                          ),
                        )),
                        ),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Container(
                    padding: const EdgeInsets.only(left: 15),
                    height: media.width * 0.5,
                    width: double.maxFinite,
                    child: hasWorkoutData
                        ? LineChart(
                            _workoutChartData(
                              calories: workoutCalories,
                              minutes: workoutMinutes,
                              weekly: isWeekly,
                            ),
                          )
                        : Center(
                            child: Text(
                              isWeekly
                                  ? "Ezen a héten még nincs befejezett edzésed."
                                  : "Az elmúlt négy hétben még nincs befejezett edzésed.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: TColor.gray, fontSize: 12),
                            ),
                          )),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Legutóbbi edzés",
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
                        "Összes megtekintése",
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                ),
                if (lastWorkouts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      "Még nincs befejezett edzésed.",
                      style: TextStyle(color: TColor.gray, fontSize: 12),
                    ),
                  )
                else
                  ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: lastWorkouts.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CompletedWorkoutListView(),
                                ),
                              );
                            },
                            child: WorkoutRow(wObj: lastWorkouts[index]));
                      }),
                SizedBox(
                  height: media.width * 0.1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(double? bmi) {
    final fill = bmi == null ? 0.08 : (bmi / 40).clamp(0.08, 1.0);
    return [
      PieChartSectionData(
        color: TColor.secondaryColor1,
        value: fill * 100,
        title: '',
        radius: 55,
        titlePositionPercentageOffset: 0.55,
        badgeWidget: Text(
          bmi == null ? "–" : bmi.toStringAsFixed(1).replaceAll(".", ","),
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      PieChartSectionData(
        color: Colors.white,
        value: (1 - fill) * 100,
        title: '',
        radius: 45,
        titlePositionPercentageOffset: 0.55,
      ),
    ];
  }

  Widget _homeSleepChart(List<double> hours) {
    final peak = hours.fold<double>(0, (max, value) => value > max ? value : max);
    final spots = [
      for (var index = 0; index < hours.length; index++)
        FlSpot(index.toDouble(), hours[index]),
    ];
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: 6,
        minY: 0,
        maxY: (peak < 8 ? 8.0 : peak + 1).clamp(8.0, 14.0).toDouble(),
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            gradient: LinearGradient(
              colors: [TColor.primaryColor2, TColor.primaryColor1],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  TColor.primaryColor2.withValues(alpha: 0.35),
                  TColor.white.withValues(alpha: 0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _workoutChartData({
    required List<double> calories,
    required List<double> minutes,
    required bool weekly,
  }) {
    final calMax = calories.fold<double>(0, (max, value) => value > max ? value : max);
    final minMax = minutes.fold<double>(0, (max, value) => value > max ? value : max);

    List<FlSpot> scaled(List<double> values, double peak) {
      return [
        for (var i = 0; i < values.length; i++)
          FlSpot(i + 1.0, peak <= 0 ? 0 : (values[i] / peak) * 100),
      ];
    }

    final labels = weekly
        ? _weekDayLabels
        : const ["1. hét", "2. hét", "3. hét", "4. hét"];

    return LineChartData(
      minX: 1,
      maxX: calories.length.toDouble(),
      minY: 0,
      maxY: 100,
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => TColor.secondaryColor1,
          tooltipRoundedRadius: 16,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = (spot.x.round() - 1).clamp(0, labels.length - 1);
              final raw = spot.barIndex == 0
                  ? "${calories[index].round()} kcal"
                  : "${minutes[index].round()} perc";
              return LineTooltipItem(
                "${labels[index]} · $raw",
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
        LineChartBarData(
          isCurved: true,
          preventCurveOverShooting: true,
          gradient: LinearGradient(colors: [
            TColor.primaryColor2.withValues(alpha: 0.8),
            TColor.primaryColor1.withValues(alpha: 0.8),
          ]),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          spots: scaled(calories, calMax),
        ),
        LineChartBarData(
          isCurved: true,
          preventCurveOverShooting: true,
          gradient: LinearGradient(colors: [
            TColor.secondaryColor2.withValues(alpha: 0.8),
            TColor.secondaryColor1.withValues(alpha: 0.8),
          ]),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(show: false),
          spots: scaled(minutes, minMax),
        ),
      ],
      titlesData: FlTitlesData(
        show: true,
        leftTitles: const AxisTitles(),
        topTitles: const AxisTitles(),
        bottomTitles: AxisTitles(sideTitles: bottomTitles),
        rightTitles: AxisTitles(sideTitles: rightTitles),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: 25,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: TColor.gray.withValues(alpha: 0.15),
            strokeWidth: 2,
          );
        },
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.transparent),
      ),
    );
  }

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;
    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(text,
        style: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        textAlign: TextAlign.center);
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.gray,
      fontSize: 12,
    );
    final index = value.toInt() - 1;
    final labels = _progressRange == "Heti"
        ? _weekDayLabels
        : const ["1.hét", "2.hét", "3.hét", "4.hét"];
    final text = index >= 0 && index < labels.length
        ? Text(labels[index], style: style)
        : const Text('');

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }
}