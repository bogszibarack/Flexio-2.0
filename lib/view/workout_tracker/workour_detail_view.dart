import 'dart:async';
import 'dart:convert';

import 'package:fitness/common/app_haptics.dart';
import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/app_snackbar.dart';
import 'package:fitness/common_widget/icon_title_next_row.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/sheet_option.dart';
import 'package:fitness/data/coach/coach_rules.dart';
import 'package:fitness/view/workout_tracker/workout_schedule_view.dart';
import 'package:fitness/view/workout_tracker/workout_store.dart';
import 'package:fitness/view/workout_tracker/workout_summary_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class WorkoutDetailView extends ConsumerStatefulWidget {
  final Map dObj;
  const WorkoutDetailView({super.key, required this.dObj});

  @override
  ConsumerState<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends ConsumerState<WorkoutDetailView> {
  final List<Map<String, dynamic>> exercisesArr = [];

  List<Map<String, String>> exerciseCatalog = [];

  DateTime? _startedAt;
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  bool _skipTemplateSync = false;

  @override
  void initState() {
    super.initState();
    final savedExercises = widget.dObj["exerciseList"] as List? ?? [];
    exercisesArr.addAll(savedExercises.whereType<Map>().map((exercise) {
      final rounds = exercise["rounds"] as int? ?? 1;
      final weight = exercise["weight"] as int? ?? 0;
      return {
        ...exercise,
        "rounds": rounds,
        "roundWeights": List<int>.from(
          exercise["roundWeights"] as List? ??
              List<int>.filled(rounds, weight),
        ),
        "completedRounds": List<bool>.filled(rounds, false),
      };
    }));
    _loadExerciseCatalog();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (!_skipTemplateSync) {
      _syncTemplate(notify: false);
    }
    super.dispose();
  }

  /// A gyakorlatlista szerkesztése a sablonba is visszaíródik, hogy legközelebb
  /// ugyanaz jöjjön be. A körökre bontott jelölés csak a mostani menetre szól,
  /// ezért az nem kerül mentésre.
  void _syncTemplate({bool notify = true}) {
    widget.dObj["exerciseList"] = exercisesArr
        .map((exercise) =>
            Map<String, dynamic>.from(exercise)..remove("completedRounds"))
        .toList();
    widget.dObj["exercises"] = "${exercisesArr.length} gyakorlat";
    WorkoutStore.updateWorkout(
      Map<String, dynamic>.from(widget.dObj),
      notify: notify,
    );
  }

  Future<void> _loadExerciseCatalog() async {
    final catalogJson =
        await rootBundle.loadString("assets/exercise_catalog_hu.json");
    final catalog = (jsonDecode(catalogJson) as List)
        .map((item) => Map<String, String>.from(item as Map))
        .toList();
    if (mounted) {
      setState(() {
        exerciseCatalog = catalog;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      color: const Color(0xffD8F1FD),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: const Color(0xffD8F1FD),
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
            ),
            SliverAppBar(
              backgroundColor: const Color(0xffD8F1FD),
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Container(
                color: const Color(0xffD8F1FD),
                child: ClipRect(
                  child: InkWell(
                    onTap: _showImagePicker,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          child: Image.asset(
                            widget.dObj["image"].toString(),
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                        Positioned(
                          right: 16,
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.edit, color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "Kép módosítása",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.dObj["title"].toString(),
                                  style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  _headerSubtitle(),
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Image.asset(
                              "assets/img/fav.png",
                              width: 15,
                              height: 15,
                              fit: BoxFit.contain,
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      if (_plannedLoadBanner() != null) ...[
                        _plannedLoadBanner()!,
                        SizedBox(height: media.width * 0.04),
                      ],
                      IconTitleNextRow(
                          icon: "assets/img/time.png",
                          title: "Edzés ütemezése",
                          time: "Időpont kiválasztása",
                          color: TColor.primaryColor2.withValues(alpha: 0.3),
                          onPressed: () {

                              Navigator.push(context, MaterialPageRoute(builder: (context) => WorkoutScheduleView(workout: Map<String, dynamic>.from(widget.dObj)) )  );
                          }),
                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      IconTitleNextRow(
                          icon: "assets/img/difficulity.png",
                          title: "Nehézségi szint",
                          time: widget.dObj["difficulty"]?.toString() ?? "Kezdő",
                          color: TColor.secondaryColor2.withValues(alpha: 0.3),
                          onPressed: _showDifficultyPicker),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gyakorlatok",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      if (_startedAt == null && exercisesArr.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          "A köröket az edzés indítása után tudod teljesítettnek jelölni.",
                          style: TextStyle(color: TColor.gray, fontSize: 11),
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (exercisesArr.isEmpty)
                        Text(
                          "Még nem adtál hozzá gyakorlatot.",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        )
                      else
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exercisesArr.length,
                          itemBuilder: (context, index) =>
                              _buildExerciseCard(exercisesArr[index]),
                        ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: RoundButton(
                          title: "Gyakorlat hozzáadása",
                          fontSize: 14,
                          onPressed: _showAddExerciseSheet,
                        ),
                      ),
                      SizedBox(
                       height: 90,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_startedAt != null) _buildSessionStatus(),
                      RoundButton(
                        title: _startedAt == null
                            ? "Edzés indítása"
                            : "Edzés befejezése",
                        onPressed:
                            _startedAt == null ? _startWorkout : _finishWorkout,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ),
      ),
    );
  }

  /// A fejléc csak tényleges mérésekből származó átlagot mutat, becsült
  /// időtartamot nem, mert az edzés hossza a stopperből jön.
  String _headerSubtitle() {
    final title = widget.dObj["title"].toString();
    final parts = <String>[
      widget.dObj["exercises"].toString(),
      widget.dObj["difficulty"]?.toString() ?? "Kezdő",
    ];

    final averageMinutes = WorkoutStore.averageMinutesFor(title);
    final averageCalories = WorkoutStore.averageCaloriesFor(title);
    if (averageMinutes != null && averageCalories != null) {
      parts.add("átlag $averageMinutes perc");
      parts.add("$averageCalories kcal");
    }

    return parts.join(" | ");
  }

  Widget _buildSessionStatus() {
    final totals = _sessionTotals();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, color: TColor.primaryColor1, size: 20),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_elapsed),
            style: TextStyle(
                color: TColor.black, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "${totals["completedSets"]}/${totals["totalSets"]} kör · ${(totals["volume"] as double).round()} kg",
              textAlign: TextAlign.right,
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _warnNotStarted() {
    // A lakat ikonos üzenet maga ad figyelmeztető rezgést.
    showAppSnack(
      context,
      message: "Előbb indítsd el az edzést, utána jelölheted a köröket.",
      icon: Icons.lock_outline,
    );
  }

  void _toggleRound(List<bool> completedRounds, int index, bool done) {
    setState(() {
      completedRounds[index] = done;
    });
    if (!done) {
      AppHaptics.selection();
    } else if (completedRounds.every((round) => round)) {
      AppHaptics.exerciseDone();
    } else {
      AppHaptics.roundDone();
    }
  }

  void _startWorkout() {
    AppHaptics.workoutStart();
    setState(() {
      _startedAt = DateTime.now();
      _elapsed = Duration.zero;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _startedAt == null) {
        timer.cancel();
        return;
      }
      setState(() {
        _elapsed = DateTime.now().difference(_startedAt!);
      });
    });
  }

  Map<String, dynamic> _sessionTotals() {
    double volume = 0;
    int completedSets = 0;
    int totalSets = 0;

    for (final exercise in exercisesArr) {
      final rounds = exercise["rounds"] as int;
      final repetitions = exercise["repetitions"] as int? ?? 0;
      final roundWeights = exercise["roundWeights"] as List<int>;
      final completedRounds = exercise["completedRounds"] as List<bool>;

      totalSets += rounds;
      for (var index = 0; index < rounds; index++) {
        if (index < completedRounds.length && completedRounds[index]) {
          completedSets++;
          final weight = index < roundWeights.length ? roundWeights[index] : 0;
          volume += weight * repetitions;
        }
      }
    }

    return {
      "volume": volume,
      "completedSets": completedSets,
      "totalSets": totalSets,
    };
  }

  Future<void> _finishWorkout() async {
    AppHaptics.workoutFinish();
    _timer?.cancel();
    final totals = _sessionTotals();
    final minutes = _elapsed.inSeconds < 60
        ? 1
        : (_elapsed.inSeconds / 60).round();

    // A mostani menet teljes gyakorlatait mentjük a naplóba és a sablonba is.
    // Korábban a sablon üres/régi listája mentődött, ezért utólag nem látszott semmi.
    final sessionExercises = exercisesArr
        .map((exercise) =>
            Map<String, dynamic>.from(exercise)..remove("completedRounds"))
        .toList();
    widget.dObj["exerciseList"] = sessionExercises
        .map((exercise) => Map<String, dynamic>.from(exercise))
        .toList();
    widget.dObj["exercises"] = "${sessionExercises.length} gyakorlat";

    final entry = WorkoutStore.logCompletedWorkout(
      title: widget.dObj["title"].toString(),
      image: widget.dObj["image"].toString(),
      difficulty: widget.dObj["difficulty"]?.toString() ?? "Kezdő",
      minutes: minutes,
      volume: totals["volume"] as double,
      completedSets: totals["completedSets"] as int,
      totalSets: totals["totalSets"] as int,
      workout: {
        ...Map<String, dynamic>.from(widget.dObj),
        "exerciseList": sessionExercises
            .map((exercise) => Map<String, dynamic>.from(exercise))
            .toList(),
      },
      exerciseList: sessionExercises
          .map((exercise) => Map<String, dynamic>.from(exercise))
          .toList(),
    );
    final progress = WorkoutStore.progressionFor(entry);

    setState(() {
      _startedAt = null;
      _elapsed = Duration.zero;
    });

    _skipTemplateSync = true;
    await WorkoutSummarySheet.show(
      context: context,
      entry: entry,
      progress: progress,
      sessionExercises: sessionExercises
          .map((exercise) => Map<String, dynamic>.from(exercise))
          .toList(),
      template: widget.dObj,
      progressText: _progressSummaryText(entry, progress),
    );
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Widget? _plannedLoadBanner() {
    final plan = WorkoutStore.nextPlanOf(widget.dObj);
    if (plan == null) {
      return null;
    }
    final percent = (plan["percent"] as num?)?.toDouble() ?? 0;
    final signed = percent == 0
        ? "ugyanannyi"
        : "${percent > 0 ? "+" : ""}${percent.toStringAsFixed(percent.abs() == percent.abs().roundToDouble() ? 0 : 1)}%";
    final unit = CoachRules.workoutHasLoad(widget.dObj) ? "súly" : "ismétlés";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: TColor.primaryColor2.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tervezett terhelés: $signed $unit",
            style: TextStyle(
              color: TColor.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "A gyakorlatokon már ez a terv van. Indítás előtt módosíthatod.",
            style: TextStyle(color: TColor.gray, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _progressSummaryText(
      Map<String, dynamic> entry, WorkoutProgress? progress) {
    if (progress == null) {
      return "Ez az első „${entry["title"]}” edzésed, innen indul a fejlődés mérése.";
    }

    final parts = <String>[];
    final percent = progress.volumeDeltaPercent;
    if (percent != null && percent.abs() >= 1) {
      parts.add(
          "a terhelés ${percent > 0 ? "+" : ""}${percent.round()}% (${progress.volumeDelta.round()} kg)");
    } else if (progress.volumeDelta.abs() >= 1) {
      parts.add("a terhelés ${progress.volumeDelta.round()} kg-mal változott");
    }
    if (progress.minutesDelta != 0) {
      parts.add(
          "az idő ${progress.minutesDelta > 0 ? "+" : ""}${progress.minutesDelta} perc");
    }
    if (progress.caloriesDelta != 0) {
      parts.add(
          "a kalória ${progress.caloriesDelta > 0 ? "+" : ""}${progress.caloriesDelta} kcal");
    }

    if (parts.isEmpty) {
      return "Az előző „${entry["title"]}” edzéssel megegyező terhelést vittél.";
    }

    return "Az előző „${entry["title"]}” edzéshez képest ${parts.join(", ")}.";
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, "0");
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    final rounds = exercise["rounds"] as int;
    final completedRounds = exercise["completedRounds"] as List<bool>;
    final roundWeights = exercise["roundWeights"] as List<int>;
    final isExpanded = exercise["isExpanded"] as bool? ?? false;

    // A kártya a gyakorlathoz kötött kulcsot kap, hogy törlés után a
    // súlymezők állapota ne csússzon át a következő gyakorlatra.
    return Container(
      key: ObjectKey(exercise),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              AppHaptics.selection();
              setState(() {
                exercise["isExpanded"] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    exercise["image"] as String,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise["name"] as String,
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${exercise["repetitions"]} ismétlés · $rounds kör",
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: TColor.gray,
                ),
                IconButton(
                  onPressed: () {
                    AppHaptics.delete();
                    setState(() {
                      exercisesArr.remove(exercise);
                    });
                    _syncTemplate();
                  },
                  icon: Icon(Icons.close, color: TColor.gray, size: 20),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 10),
            ...List.generate(rounds, (index) {
            return Row(
              children: [
                // Csak futó edzés közben jelölhető teljesítettnek. Indítás
                // előtt a koppintás figyelmeztet, hogy ne tűnjön hibának.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _startedAt == null ? _warnNotStarted : null,
                  child: Checkbox(
                    value: completedRounds[index],
                    activeColor: TColor.primaryColor1,
                    onChanged: _startedAt == null
                        ? null
                        : (value) =>
                            _toggleRound(completedRounds, index, value ?? false),
                  ),
                ),
                Expanded(
                  child: Text(
                    "${index + 1}. kör",
                    style: TextStyle(color: TColor.black, fontSize: 12),
                  ),
                ),
                SizedBox(
                  width: 85,
                  child: _RoundWeightField(
                    value: roundWeights[index],
                    onChanged: (value) {
                      roundWeights[index] = value;
                      exercise["weight"] = roundWeights.isNotEmpty
                          ? roundWeights.first
                          : 0;
                    },
                    onCommitted: _syncTemplate,
                  ),
                ),
              ],
            );
            }),
          ],
        ],
      ),
    );
  }

  Future<void> _showImagePicker() async {
    final images = List<String>.from(jsonDecode(
            await rootBundle.loadString("assets/repdb_image_paths.json"))
        as List);
    if (!mounted) {
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Material(
          color: TColor.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TColor.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Edzés képe",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final image = images[index];
                      final isSelected =
                          image == widget.dObj["image"]?.toString();
                      return InkWell(
                        onTap: () => Navigator.pop(context, image),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: TColor.lightGray,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? TColor.primaryColor1
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(image, fit: BoxFit.cover),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      AppHaptics.selection();
      widget.dObj["image"] = selected;
    });
    _syncTemplate();
  }

  void _showDifficultyPicker() {
    const difficulties = ["Kezdő", "Középhaladó", "Haladó"];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Material(
          color: TColor.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(25)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: TColor.gray.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Nehézségi szint",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              ...difficulties.map((difficulty) => SheetOption(
                    title: difficulty,
                    trailing: widget.dObj["difficulty"] == difficulty
                        ? Icon(Icons.check_circle,
                            color: TColor.primaryColor1)
                        : null,
                    onTap: () {
                      setState(() {
                        AppHaptics.selection();
                        widget.dObj["difficulty"] = difficulty;
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
          ),
        ),
      ),
    );
  }

  void _showAddExerciseSheet() {
    String query = "";
    Map<String, String>? selectedExercise;
    int repetitions = 10;
    int rounds = 3;
    int weightKg = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredExercises = exerciseCatalog
              .where((exercise) =>
                  exercise["searchTerms"]!
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                child: Material(
                  color: TColor.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(25)),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.82,
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: TColor.gray.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Gyakorlat hozzáadása",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onChanged: (value) {
                              setModalState(() {
                                query = value;
                              });
                            },
                            onSubmitted: (_) =>
                                FocusManager.instance.primaryFocus?.unfocus(),
                            decoration: InputDecoration(
                              hintText:
                                  "Keress gyakorlatra, például: guggolás",
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: TColor.lightGray,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: ListView.builder(
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: filteredExercises.length,
                              itemBuilder: (context, index) {
                                final exercise = filteredExercises[index];
                                final isSelected = selectedExercise == exercise;
                                return SheetOption(
                                  title: exercise["name"]!,
                                  onTap: () {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    setModalState(() {
                                      selectedExercise = exercise;
                                    });
                                  },
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      exercise["image"]!,
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle,
                                          color: TColor.primaryColor1)
                                      : null,
                                );
                              },
                            ),
                          ),
                          if (selectedExercise != null) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _buildNumberControl(
                                    "Ismétlés",
                                    repetitions,
                                    (value) => setModalState(
                                        () => repetitions = value),
                                    minimum: 1,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberControl(
                                    "Súly (kg)",
                                    weightKg,
                                    (value) =>
                                        setModalState(() => weightKg = value),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildNumberControl(
                                    "Kör",
                                    rounds,
                                    (value) =>
                                        setModalState(() => rounds = value),
                                    minimum: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: RoundButton(
                                title: "Gyakorlat hozzáadása",
                                fontSize: 14,
                                onPressed: () {
                                  AppHaptics.success();
                                  setState(() {
                                    exercisesArr.add({
                                      "name": selectedExercise!["name"]!,
                                      "image": selectedExercise!["image"]!,
                                      "repetitions": repetitions,
                                      "weight": weightKg,
                                      "rounds": rounds,
                                      "roundWeights":
                                          List<int>.filled(rounds, weightKg),
                                      "completedRounds":
                                          List<bool>.filled(rounds, false),
                                    });
                                  });
                                  _syncTemplate();
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumberControl(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    int minimum = 0,
  }) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: value > minimum
                  ? () {
                      AppHaptics.selection();
                      onChanged(value - 1);
                    }
                  : null,
              icon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
            Text("$value", style: TextStyle(color: TColor.black)),
            IconButton(
              onPressed: () {
                AppHaptics.selection();
                onChanged(value + 1);
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}

/// Egy kör súlymezője. Saját vezérlőt és fókuszt tart, így a szülő
/// újraépülése (pl. a másodpercenként frissülő stopper) nem veszi el a
/// fókuszt gépelés közben. A sablonba mentés a mező elhagyásakor történik.
class _RoundWeightField extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final VoidCallback onCommitted;

  const _RoundWeightField({
    required this.value,
    required this.onChanged,
    required this.onCommitted,
  });

  @override
  State<_RoundWeightField> createState() => _RoundWeightFieldState();
}

class _RoundWeightFieldState extends State<_RoundWeightField> {
  late final TextEditingController _controller =
      TextEditingController(text: "${widget.value}");
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _RoundWeightField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Kívülről jött változás csak akkor íródik be, ha épp nem gépel benne.
    if (!_focusNode.hasFocus && widget.value != _parsed) {
      _controller.text = "${widget.value}";
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  int get _parsed => int.tryParse(_controller.text.trim()) ?? 0;

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Belépéskor kijelöljük az értéket, hogy rögtön felülírható legyen.
      _controller.selection = TextSelection(
          baseOffset: 0, extentOffset: _controller.text.length);
      return;
    }
    if (_controller.text.trim().isEmpty) {
      _controller.text = "0";
    }
    widget.onChanged(_parsed);
    widget.onCommitted();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      textAlign: TextAlign.center,
      decoration: const InputDecoration(
        suffixText: "kg",
        isDense: true,
      ),
      onChanged: (_) => widget.onChanged(_parsed),
      onSubmitted: (_) => _focusNode.unfocus(),
      // A mező mellé koppintva bezárul a billentyűzet és mentődik az érték.
      onTapOutside: (_) => _focusNode.unfocus(),
    );
  }
}
