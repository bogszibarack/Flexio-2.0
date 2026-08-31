import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../data/coach/coach_rules.dart';
import '../../data/coach/coach_service.dart';
import '../../data/providers.dart';
import 'workout_store.dart';

/// Edzés utáni összefoglaló: RPE, szabályos progresszió-csúszka, next_plan.
class WorkoutSummarySheet extends ConsumerStatefulWidget {
  const WorkoutSummarySheet({
    super.key,
    required this.entry,
    required this.progress,
    required this.sessionExercises,
    required this.template,
    required this.progressText,
  });

  final Map<String, dynamic> entry;
  final WorkoutProgress? progress;
  final List<Map<String, dynamic>> sessionExercises;
  final Map template;
  final String progressText;

  static Future<void> show({
    required BuildContext context,
    required Map<String, dynamic> entry,
    required WorkoutProgress? progress,
    required List<Map<String, dynamic>> sessionExercises,
    required Map template,
    required String progressText,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WorkoutSummarySheet(
        entry: entry,
        progress: progress,
        sessionExercises: sessionExercises,
        template: template,
        progressText: progressText,
      ),
    );
  }

  @override
  ConsumerState<WorkoutSummarySheet> createState() =>
      _WorkoutSummarySheetState();
}

class _WorkoutSummarySheetState extends ConsumerState<WorkoutSummarySheet> {
  late int _rpe;
  late double _percent;
  late ProgressionAdvice _advice;
  CoachCopy _copy = const CoachCopy(prose: "", pros: "", cons: "");
  bool _loadingCopy = false;
  int _copyToken = 0;

  @override
  void initState() {
    super.initState();
    _rpe = 7;
    _advice = CoachRules.adviceFor(
      rpe: _rpe,
      entry: widget.entry,
      progress: widget.progress,
    );
    _percent = _advice.suggestedPercent;
    _copy = CoachRules.localWorkoutCopy(percent: _percent, advice: _advice);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshCopy());
  }

  void _recompute({required int rpe, required bool resetPercent}) {
    _rpe = rpe;
    _advice = CoachRules.adviceFor(
      rpe: rpe,
      entry: widget.entry,
      progress: widget.progress,
    );
    if (resetPercent) {
      _percent = _advice.suggestedPercent;
    }
    _copy = CoachRules.localWorkoutCopy(percent: _percent, advice: _advice);
  }

  Future<void> _refreshCopy() async {
    final settings = ref.read(coachSettingsProvider);
    if (!settings.workout) {
      return;
    }
    final token = ++_copyToken;
    setState(() => _loadingCopy = true);
    final copy = await ref.read(coachServiceProvider).copyFor(
          snapshot: CoachService.workoutSnapshot(
            profile: ref.read(profileControllerProvider).profile,
            rpe: _rpe,
            percent: _percent,
            entry: widget.entry,
          ),
          advice: _advice,
          percent: _percent,
        );
    if (!mounted || token != _copyToken) {
      return;
    }
    setState(() {
      _copy = copy;
      _loadingCopy = false;
    });
  }

  String _signed(double percent) {
    if (percent == 0) {
      return "0%";
    }
    final neat = percent.abs() == percent.abs().roundToDouble();
    return "${percent > 0 ? "+" : ""}${percent.toStringAsFixed(neat ? 0 : 1)}%";
  }

  Future<void> _savePlan() async {
    WorkoutStore.setEntryRpe(widget.entry, _rpe);
    widget.template["exerciseList"] =
        CoachRules.scaleExercises(widget.sessionExercises, _percent);
    widget.template["nextPlan"] = {
      "percent": _percent,
      "rpe": _rpe,
      "at": DateTime.now().toIso8601String(),
    };
    WorkoutStore.updateWorkout(Map<String, dynamic>.from(widget.template));

    final settings = ref.read(coachSettingsProvider);
    if (settings.workout) {
      await ref.read(coachServiceProvider).remember(
            title: "Következő ${widget.entry["title"]}",
            body:
                "${_signed(_percent)} ${ _advice.hasLoad ? "súly" : "ismétlés"}. ${_copy.prose}",
            kind: "coach_workout",
            image: "${widget.entry["image"] ?? "assets/img/Workout1.png"}",
          );
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _skipPlan() async {
    WorkoutStore.setEntryRpe(widget.entry, _rpe);
    widget.template.remove("nextPlan");
    widget.template["exerciseList"] = widget.sessionExercises
        .map((exercise) =>
            Map<String, dynamic>.from(exercise)..remove("completedRounds"))
        .toList();
    WorkoutStore.updateWorkout(Map<String, dynamic>.from(widget.template));
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coachOn = ref.watch(coachSettingsProvider).workout;
    final media = MediaQuery.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TColor.gray.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    "Edzés kész!",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    widget.entry["title"].toString(),
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _tile("Idő", "${widget.entry["minutes"]} perc"),
                    const SizedBox(width: 10),
                    _tile("Kalória", "${widget.entry["calories"]} kcal"),
                    const SizedBox(width: 10),
                    _tile(
                      "Terhelés",
                      "${(widget.entry["volume"] as num).round()} kg",
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.progressText,
                  style: TextStyle(color: TColor.black, fontSize: 12),
                ),
                if (coachOn) ...[
                  const SizedBox(height: 18),
                  Text(
                    "Milyen nehéz volt? (RPE $_rpe)",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: _rpe.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: "$_rpe",
                    activeColor: TColor.primaryColor1,
                    onChanged: (value) {
                      setState(() => _recompute(
                            rpe: value.round(),
                            resetPercent: true,
                          ));
                    },
                    onChangeEnd: (_) => _refreshCopy(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _advice.hasLoad
                        ? "Következő azonos edzés terhelése: ${_signed(_percent)}"
                        : "Következő azonos edzés ismétlése: ${_signed(_percent)}",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Slider(
                    value: _percent,
                    min: -10,
                    max: 10,
                    divisions: 20,
                    label: _signed(_percent),
                    activeColor: TColor.primaryColor1,
                    onChanged: (value) {
                      setState(() {
                        _percent = value;
                        _copy = CoachRules.localWorkoutCopy(
                          percent: _percent,
                          advice: _advice,
                        );
                      });
                    },
                    onChangeEnd: (_) => _refreshCopy(),
                  ),
                  Text(
                    _advice.reason,
                    style: TextStyle(color: TColor.gray, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  if (_loadingCopy)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: LinearProgressIndicator(
                        minHeight: 2,
                        color: TColor.primaryColor1,
                      ),
                    ),
                  Text(
                    _copy.prose,
                    style: TextStyle(color: TColor.black, fontSize: 12),
                  ),
                  if (_copy.pros.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Mellette: ${_copy.pros}",
                      style: TextStyle(color: TColor.gray, fontSize: 11),
                    ),
                  ],
                  if (_copy.cons.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Ellene: ${_copy.cons}",
                      style: TextStyle(color: TColor.gray, fontSize: 11),
                    ),
                  ],
                  const SizedBox(height: 16),
                  RoundButton(
                    title: "Mentés a következő edzésre",
                    onPressed: _savePlan,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _skipPlan,
                      child: Text(
                        "Most nem tervezek",
                        style: TextStyle(color: TColor.gray, fontSize: 13),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  RoundButton(
                    title: "Rendben",
                    onPressed: () {
                      widget.template.remove("nextPlan");
                      widget.template["exerciseList"] = widget.sessionExercises
                          .map((exercise) => Map<String, dynamic>.from(exercise)
                            ..remove("completedRounds"))
                          .toList();
                      WorkoutStore.updateWorkout(Map<String, dynamic>.from(widget.template));
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
