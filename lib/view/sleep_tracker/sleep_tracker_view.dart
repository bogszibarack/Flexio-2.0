import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/round_button.dart';
import '../../data/coach/coach_rules.dart';
import '../../data/coach/coach_sheets.dart';
import '../../data/providers.dart';
import '../../data/repositories/sleep_repository.dart';
import 'sleep_schedule_view.dart';
import 'sleep_store.dart';

class SleepTrackerView extends ConsumerStatefulWidget {
  const SleepTrackerView({super.key});

  @override
  ConsumerState<SleepTrackerView> createState() => _SleepTrackerViewState();
}

class _SleepTrackerViewState extends ConsumerState<SleepTrackerView> {
  int _weekOffset = 0;
  int? _touchedIndex;

  static const List<String> _dayLabels = ["V", "H", "K", "Sze", "Cs", "P", "Szo"];

  DateTime get _weekStart => SleepStore.startOfWeek(DateTime.now())
      .add(Duration(days: 7 * _weekOffset));

  List<double> get _hours => SleepStore.weeklyHours(_weekStart);

  @override
  void initState() {
    super.initState();
    SleepStore.revision.addListener(_onStoreChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthSyncProvider).pullFromApple();
    });
  }

  @override
  void dispose() {
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

  String _formatHours(double hours) {
    if (hours <= 0) {
      return "–";
    }
    final minutes = (hours * 60).round();
    return "${minutes ~/ 60}ó ${(minutes % 60).toString().padLeft(2, '0')}p";
  }

  String get _weekLabel {
    final end = _weekStart.add(const Duration(days: 6));
    if (_weekOffset == 0) {
      return "Ez a hét";
    }
    return "${dateToShortMonthDay(_weekStart)} – ${dateToShortMonthDay(end)}";
  }

  Future<void> _logSleep() async {
    if (!SleepStore.isBound) {
      showAppSnack(context,
          message: "Jelentkezz be az alvás naplózásához.",
          icon: Icons.lock_outline);
      return;
    }

    final now = DateTime.now();
    final typical = SleepStore.typicalSchedule();

    final bedtime = await showTimePicker(
      context: context,
      helpText: "Mikor feküdtél le?",
      initialTime: TimeOfDay(
        hour: typical?.bedHour ?? 22,
        minute: typical?.bedMinute ?? 30,
      ),
    );

    if (bedtime == null || !mounted) {
      return;
    }

    final wakeTime = await showTimePicker(
      context: context,
      helpText: "Mikor keltél fel?",
      initialTime: TimeOfDay(
        hour: typical?.wakeHour ?? 6,
        minute: typical?.wakeMinute ?? 30,
      ),
    );

    if (wakeTime == null || !mounted) {
      return;
    }

    // A felkelés a mai nap, a lefekvés pedig az azt megelőző éjszaka.
    var wake = DateTime(
        now.year, now.month, now.day, wakeTime.hour, wakeTime.minute);
    if (wake.isAfter(now)) {
      wake = wake.subtract(const Duration(days: 1));
    }

    var bed = DateTime(
        wake.year, wake.month, wake.day, bedtime.hour, bedtime.minute);
    if (!bed.isBefore(wake)) {
      bed = bed.subtract(const Duration(days: 1));
    }

    final entry = await SleepStore.log(bedtime: bed, wakeTime: wake);

    if (!mounted || entry == null) {
      return;
    }

    setState(() => _weekOffset = 0);
    await CoachSheets.maybeSleepTip(context: context, ref: ref);
    if (!mounted) {
      return;
    }
    showAppSnack(
      context,
      message: "Alvás naplózva: ${entry.durationLabel}.",
      icon: Icons.nightlight_round,
    );
  }

  Future<void> _removeEntry(SleepEntry entry) async {
    await SleepStore.remove(entry);
    if (mounted) {
      showAppSnack(context,
          message: "Bejegyzés törölve.", icon: Icons.delete_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final hours = _hours;
    final lastNight = SleepStore.lastNight;
    final recent = SleepStore.entries.reversed.take(7).toList();
    final maxHours = hours.fold<double>(0, (max, value) => value > max ? value : max);

    return Scaffold(
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
          "Alváskövető",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _logSleep,
            tooltip: "Alvás naplózása",
            icon: Icon(Icons.add, color: TColor.black, size: 22),
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _weekOffset -= 1),
                    icon: Icon(Icons.chevron_left, color: TColor.gray),
                  ),
                  Expanded(
                    child: Text(
                      _weekLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    onPressed: _weekOffset >= 0
                        ? null
                        : () => setState(() => _weekOffset += 1),
                    icon: Icon(Icons.chevron_right,
                        color: _weekOffset >= 0 ? TColor.lightGray : TColor.gray),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(left: 10, top: 10),
                height: media.width * 0.5,
                width: double.maxFinite,
                child: maxHours <= 0
                    ? Center(
                        child: Text(
                          "Még nincs alvásadat ezen a héten.\nKoppints a plusz jelre a naplózáshoz.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      )
                    : _buildChart(hours),
              ),
              SizedBox(height: media.width * 0.05),
              Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lastNight == null ? "Múlt éjszaka" : "Legutóbbi alvás",
                      style: TextStyle(color: TColor.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lastNight?.durationLabel ?? "Nincs adat",
                      style: TextStyle(
                          color: TColor.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lastNight == null
                          ? "Naplózd az első éjszakát, és itt látod majd az összefoglalót."
                          : "${dateToShortMonthDay(lastNight.bedtime)} ${dateToTimeLabel(lastNight.bedtime)} – "
                              "${dateToTimeLabel(lastNight.wakeTime)} · "
                              "átlag ${_formatHours(SleepStore.averageHours)}",
                      style: TextStyle(
                          color: TColor.white.withValues(alpha: 0.85),
                          fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (ref.watch(coachSettingsProvider).sleep) ...[
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final tip = CoachRules.sleepFromHistory();
                    return Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 15),
                      decoration: BoxDecoration(
                        color: TColor.primaryColor2.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.headline,
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip.detail,
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                          if (CoachRules.lastNightWasShort()) ...[
                            const SizedBox(height: 6),
                            Text(
                              "A következő edzésen a szabály nem ajánl emelést.",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
              SizedBox(height: media.width * 0.05),
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
                    Expanded(
                      child: Text(
                        "Napi alvásütemezés",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      height: 25,
                      child: RoundButton(
                        title: "Megnézem",
                        type: RoundButtonType.bgGradient,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SleepScheduleView(),
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: media.width * 0.05),
              Text(
                "Legutóbbi éjszakák",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(height: media.width * 0.03),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "Nincs még naplózott alvás.",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                )
              else
                ...recent.map(_buildEntryRow),
              SizedBox(height: media.width * 0.05),
              SizedBox(
                width: double.maxFinite,
                height: 50,
                child: RoundButton(
                  title: "Alvás naplózása",
                  onPressed: _logSleep,
                ),
              ),
              SizedBox(height: media.width * 0.1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEntryRow(SleepEntry entry) => Dismissible(
        key: ValueKey(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          padding: const EdgeInsets.only(right: 24),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        onDismissed: (direction) => _removeEntry(entry),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 2)
              ]),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.secondaryG),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.bedtime_outlined,
                    color: TColor.white, size: 18),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${dateToWeekday(entry.wakeTime)}, ${dateToShortMonthDay(entry.wakeTime)}",
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                    Text(
                      "${dateToTimeLabel(entry.bedtime)} – "
                      "${dateToTimeLabel(entry.wakeTime)}",
                      style: TextStyle(color: TColor.gray, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Text(
                entry.durationLabel,
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      );

  Widget _buildChart(List<double> hours) {
    final spots = <FlSpot>[
      for (var index = 0; index < hours.length; index++)
        FlSpot(index.toDouble(), hours[index]),
    ];

    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      gradient: LinearGradient(
          colors: [TColor.primaryColor2, TColor.primaryColor1]),
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [
            TColor.primaryColor2.withValues(alpha: 0.4),
            TColor.white,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );

    return LineChart(
      LineChartData(
        showingTooltipIndicators: _touchedIndex == null
            ? const []
            : [
                ShowingTooltipIndicators([
                  LineBarSpot(barData, 0, spots[_touchedIndex!]),
                ]),
              ],
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: false,
          touchCallback: (event, response) {
            if (response?.lineBarSpots == null || event is! FlTapUpEvent) {
              return;
            }
            setState(() {
              _touchedIndex = response!.lineBarSpots!.first.spotIndex;
            });
          },
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes
                .map((index) => TouchedSpotIndicatorData(
                      FlLine(color: Colors.transparent),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: TColor.primaryColor2,
                        ),
                      ),
                    ))
                .toList();
          },
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => TColor.secondaryColor1,
            tooltipRoundedRadius: 8,
            getTooltipItems: (spots) => spots
                .map((spot) => LineTooltipItem(
                      _formatHours(spot.y),
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                .toList(),
          ),
        ),
        lineBarsData: [barData],
        minY: 0,
        maxY: 12,
        titlesData: FlTitlesData(
          show: true,
          leftTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index > 6) {
                  return const SizedBox();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8,
                  child: Text(
                    _dayLabels[index],
                    style: TextStyle(color: TColor.gray, fontSize: 11),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                "${value.toInt()}ó",
                style: TextStyle(color: TColor.gray, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 3,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: TColor.gray.withValues(alpha: 0.15),
            strokeWidth: 2,
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.transparent),
        ),
      ),
    );
  }
}
