import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import 'sleep_store.dart';

class SleepScheduleView extends StatefulWidget {
  const SleepScheduleView({super.key});

  @override
  State<SleepScheduleView> createState() => _SleepScheduleViewState();
}

class _SleepScheduleViewState extends State<SleepScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();
  late DateTime _selectedDateAppBBar;

  /// Felnőttekre javasolt alvás. Ehhez mérjük a napi teljesítést.
  static const double _idealHours = 8.5;

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    SleepStore.revision.addListener(_onStoreChanged);
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
    final minutes = (hours * 60).round().clamp(0, 24 * 60);
    return "${minutes ~/ 60} óra ${(minutes % 60).toString().padLeft(2, '0')} perc";
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final entry = SleepStore.entryForWakeDay(_selectedDateAppBBar);
    final typical = SleepStore.typicalSchedule();
    final ratio = entry == null
        ? 0.0
        : (entry.hours / _idealHours).clamp(0.0, 1.0).toDouble();

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
          "Alvásütemezés",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(20),
                height: media.width * 0.4,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      TColor.primaryColor2.withValues(alpha: 0.4),
                      TColor.primaryColor1.withValues(alpha: 0.4)
                    ]),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "Ideális alvásmennyiség",
                              style:
                                  TextStyle(color: TColor.black, fontSize: 13),
                            ),
                            Text(
                              _formatHours(_idealHours),
                              style: TextStyle(
                                  color: TColor.primaryColor2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              typical == null
                                  ? "Naplózz néhány éjszakát, és itt látod a szokásos ritmusodat."
                                  : "Szokásos ritmusod: "
                                      "${typical.bedHour.toString().padLeft(2, '0')}:"
                                      "${typical.bedMinute.toString().padLeft(2, '0')} – "
                                      "${typical.wakeHour.toString().padLeft(2, '0')}:"
                                      "${typical.wakeMinute.toString().padLeft(2, '0')}",
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 11),
                            ),
                          ]),
                    ),
                    Image.asset(
                      "assets/img/sleep_schedule.png",
                      width: media.width * 0.3,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: media.width * 0.03),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                "Az ütemezésed",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
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
                setState(() => _selectedDateAppBBar = date);
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
            SizedBox(height: media.width * 0.03),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: entry == null
                  ? Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "Ezen a napon nincs naplózott alvás.",
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    )
                  : Column(
                      children: [
                        _scheduleRow(
                          label: "Lefekvés",
                          icon: Icons.bedtime_outlined,
                          time: entry.bedtime,
                          detail:
                              "${dateToWeekday(entry.bedtime)} este",
                        ),
                        _scheduleRow(
                          label: "Felkelés",
                          icon: Icons.wb_sunny_outlined,
                          time: entry.wakeTime,
                          detail: "Összesen ${entry.durationLabel}",
                        ),
                      ],
                    ),
            ),
            Container(
                width: double.maxFinite,
                margin:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      TColor.secondaryColor2.withValues(alpha: 0.4),
                      TColor.secondaryColor1.withValues(alpha: 0.4)
                    ]),
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry == null
                          ? "Az ideális ${_formatHours(_idealHours)} a cél."
                          : "Ezen a napon ${entry.durationLabel} alvás jött össze\n"
                              "az ideális ${_formatHours(_idealHours)} helyett.",
                      style: TextStyle(color: TColor.black, fontSize: 12),
                    ),
                    const SizedBox(height: 15),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SimpleAnimationProgressBar(
                          height: 15,
                          width: media.width - 80,
                          backgroundColor: Colors.grey.shade100,
                          foregrondColor: Colors.purple,
                          ratio: ratio,
                          direction: Axis.horizontal,
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: const Duration(seconds: 2),
                          borderRadius: BorderRadius.circular(7.5),
                          gradientColor: LinearGradient(
                              colors: TColor.secondaryG,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                        ),
                        Text(
                          "${(ratio * 100).round()}%",
                          style: TextStyle(color: TColor.black, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                )),
            SizedBox(height: media.width * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _scheduleRow({
    required String label,
    required IconData icon,
    required DateTime time,
    required String detail,
  }) =>
      Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: TColor.white, size: 18),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$label, ${dateToTimeLabel(time)}",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: TextStyle(color: TColor.gray, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
