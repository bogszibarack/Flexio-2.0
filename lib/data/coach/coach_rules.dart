import '../../view/meal_planner/meal_store.dart';
import '../../view/sleep_tracker/sleep_store.dart';
import '../../view/workout_tracker/workout_store.dart';
import '../models/user_profile.dart';

class ProgressionAdvice {
  const ProgressionAdvice({
    required this.suggestedPercent,
    required this.reason,
    required this.holdBack,
    required this.hasLoad,
  });

  final double suggestedPercent;
  final String reason;
  final bool holdBack;
  final bool hasLoad;
}

class NutritionDigest {
  const NutritionDigest({
    required this.headline,
    required this.detail,
    required this.praiseOnly,
    this.good,
    this.weak,
  });

  final String headline;
  final String detail;
  final bool praiseOnly;
  final String? good;
  final String? weak;
}

class SleepTip {
  const SleepTip({
    required this.headline,
    required this.detail,
    required this.praise,
  });

  final String headline;
  final String detail;
  final bool praise;
}

class CoachCopy {
  const CoachCopy({
    required this.prose,
    required this.pros,
    required this.cons,
  });

  final String prose;
  final String pros;
  final String cons;
}

/// Számok és helyi szövegek. Az LLM csak ezt a keretet magyarítja.
class CoachRules {
  CoachRules._();

  static bool exerciseHasLoad(Map exercise) {
    final weights = exercise["roundWeights"];
    if (weights is List && weights.any((item) => (item as num? ?? 0) > 0)) {
      return true;
    }
    return (exercise["weight"] as num? ?? 0) > 0;
  }

  static bool workoutHasLoad(Map workout) {
    final list = workout["exerciseList"] as List? ?? [];
    return list.whereType<Map>().any(exerciseHasLoad);
  }

  static double lastNightHours() {
    final last = SleepStore.lastNight;
    return last?.hours ?? 0;
  }

  static double averageSleepHours() => SleepStore.averageHours;

  static bool lastNightWasShort() {
    final last = lastNightHours();
    if (last <= 0) {
      return false;
    }
    final average = averageSleepHours();
    if (average <= 0) {
      return last < 6;
    }
    return last + 1.5 < average || last < 6;
  }

  static bool hardStreak() {
    final weeks = WorkoutStore.lastFourWeeksTotals(
      metric: WorkoutMetric.calories,
    );
    if (weeks.length < 4) {
      return false;
    }
    return weeks[1] > 0 && weeks[2] > weeks[1] && weeks[3] > weeks[2];
  }

  static ProgressionAdvice adviceFor({
    required int rpe,
    required Map<String, dynamic> entry,
    WorkoutProgress? progress,
  }) {
    final workout = entry["workout"];
    final hasLoad = workout is Map && workoutHasLoad(workout);
    final completed = entry["completedSets"] as int? ?? 0;
    final total = entry["totalSets"] as int? ?? 0;
    final finished = total == 0 || completed >= total;
    final shortNight = lastNightWasShort();
    final deload = hardStreak();

    if (shortNight) {
      return ProgressionAdvice(
        suggestedPercent: 0,
        holdBack: true,
        hasLoad: hasLoad,
        reason:
            "Az utolsó éjszakád rövidebb volt a szokásosnál, ezért most nem ajánlunk emelést.",
      );
    }
    if (deload) {
      return ProgressionAdvice(
        suggestedPercent: -10,
        holdBack: true,
        hasLoad: hasLoad,
        reason:
            "Három egyre terheltebb heted volt. Egy könnyebb (−10%) hét most többet hoz, mint a további emelés.",
      );
    }
    if (rpe >= 9) {
      return ProgressionAdvice(
        suggestedPercent: 0,
        holdBack: true,
        hasLoad: hasLoad,
        reason:
            "Ez az edzés nagyon kemény volt (RPE $rpe). Maradj ugyanitt, amíg könnyebben megy.",
      );
    }
    if (!finished) {
      return ProgressionAdvice(
        suggestedPercent: 0,
        holdBack: true,
        hasLoad: hasLoad,
        reason: "Nem minden sor készült el. Előbb zárd le ugyanilyen terheléssel.",
      );
    }
    if (rpe <= 6 && (progress == null || (progress.volumeDelta >= 0))) {
      return ProgressionAdvice(
        suggestedPercent: 5,
        holdBack: false,
        hasLoad: hasLoad,
        reason: hasLoad
            ? "Maradt tartalékod (RPE $rpe). A következő azonos edzésen +5% súly reális."
            : "Maradt tartalékod (RPE $rpe). A következő alkalommal +5% ismétlés reális.",
      );
    }
    if (rpe <= 7) {
      return ProgressionAdvice(
        suggestedPercent: 2.5,
        holdBack: false,
        hasLoad: hasLoad,
        reason: "Stabil menet volt. Egy óvatos +2,5% már fejlődés, de nem ugrás.",
      );
    }
    return ProgressionAdvice(
      suggestedPercent: 0,
      holdBack: false,
      hasLoad: hasLoad,
      reason: "Tartsd a mai terhelést. Ha legközelebb könnyebb, akkor emelj.",
    );
  }

  static List<Map<String, dynamic>> scaleExercises(
    List exercises,
    double percent,
  ) {
    final factor = 1 + percent / 100;
    return exercises.whereType<Map>().map((exercise) {
      final copy = Map<String, dynamic>.from(exercise)
        ..remove("completedRounds");
      if (exerciseHasLoad(copy)) {
        final raw = copy["roundWeights"];
        final weights = raw is List
            ? raw.map((item) => (item as num?)?.toInt() ?? 0).toList()
            : <int>[];
        if (weights.isEmpty) {
          final weight = (copy["weight"] as num?)?.toInt() ?? 0;
          copy["weight"] = weight <= 0 ? 0 : (weight * factor).round().clamp(1, 500);
        } else {
          copy["roundWeights"] = weights
              .map((weight) =>
                  weight <= 0 ? 0 : (weight * factor).round().clamp(1, 500))
              .toList();
          copy["weight"] = (copy["roundWeights"] as List).first;
        }
      } else {
        final reps = (copy["repetitions"] as num?)?.toInt() ?? 0;
        if (reps > 0) {
          copy["repetitions"] = (reps * factor).round().clamp(1, 200);
        }
      }
      return copy;
    }).toList();
  }

  static NutritionDigest nutritionFor({
    required MealTotals consumed,
    required NutritionGoals goals,
    required FitnessGoal? goal,
    String? lastMealType,
    String? lastFoodName,
  }) {
    final calorieRatio =
        goals.calories <= 0 ? 1.0 : consumed.calories / goals.calories;
    final proteinGap = goals.protein - consumed.protein;
    final carbGap = goals.carbs - consumed.carbs;
    final fatGap = goals.fat - consumed.fat;
    final onTarget = calorieRatio >= 0.9 && calorieRatio <= 1.1;

    if (onTarget && proteinGap.abs() < goals.protein * 0.15) {
      return NutritionDigest(
        headline: "Szép nap, tartod a célt.",
        detail:
            "${consumed.calories.round()} / ${goals.calories.round()} kcal, a makrók is a sávban vannak.",
        praiseOnly: true,
        good: lastFoodName == null
            ? null
            : "$lastFoodName belefért a mai keretbe.",
      );
    }

    String weak;
    if (proteinGap > 15) {
      weak =
          "A fehérje még ${proteinGap.round()} g-mal a cél alatt van. Egy egyszerű forrás (tojás, joghurt, csirke) sokat hoz.";
    } else if (calorieRatio < 0.8 && goal == FitnessGoal.gainMuscle) {
      weak =
          "Az energia ${consumed.calories.round()} kcal, az izomcélhoz ma még kellene ennivaló.";
    } else if (calorieRatio > 1.15 && goal == FitnessGoal.loseWeight) {
      weak =
          "Ma ${((calorieRatio - 1) * 100).round()}%-kal a kalóriacél felett vagy. A következő étkezésnél a fehérje és a zöldség a biztos pont.";
    } else if (carbGap < -30) {
      weak = "A szénhidrát már bőven a cél felett van. Estére inkább fehérje és zöldség.";
    } else if (fatGap < -20) {
      weak = "A zsír magasabb a tervezettnél. A következő adagnál kevesebb olaj / sajt elég.";
    } else {
      weak =
          "Még ${ (goals.calories - consumed.calories).round() } kcal van a napi keretben.";
    }

    String? good;
    if (lastFoodName != null && lastMealType != null) {
      good = proteinGap <= 15 && consumed.protein > 0
          ? "$lastMealType: $lastFoodName — a fehérje jó irányba ment."
          : "$lastMealType: $lastFoodName naplózva.";
    }

    return NutritionDigest(
      headline: onTarget ? "A kalória stimmel, a bontás finomítható." : "Hol tartasz ma",
      detail:
          "${consumed.calories.round()} / ${goals.calories.round()} kcal · F ${consumed.protein.round()}/${goals.protein.round()} g · Sz ${consumed.carbs.round()}/${goals.carbs.round()} g · Zs ${consumed.fat.round()}/${goals.fat.round()} g",
      praiseOnly: false,
      good: good,
      weak: weak,
    );
  }

  static NutritionDigest weeklyNutrition({
    required MealStore store,
    required NutritionGoals goals,
  }) {
    final start = WorkoutStore.startOfWeek(DateTime.now());
    var proteinDays = 0;
    var loggedDays = 0;
    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final totals = store.totalsOf(store.mealsForDay(day));
      if (totals.isEmpty) {
        continue;
      }
      loggedDays++;
      if (totals.protein >= goals.protein * 0.9) {
        proteinDays++;
      }
    }
    if (loggedDays == 0) {
      return const NutritionDigest(
        headline: "Ezen a héten még nincs naplózott étkezés.",
        detail: "Ha bekerül a nap, a heti irányt is tudjuk mondani.",
        praiseOnly: true,
      );
    }
    if (proteinDays >= loggedDays - 1) {
      return NutritionDigest(
        headline: "A heti fehérje stimmel.",
        detail: "$proteinDays / $loggedDays naplózott napon megvolt a cél.",
        praiseOnly: true,
      );
    }
    return NutritionDigest(
      headline: "A fehérje $proteinDays / $loggedDays napon volt meg.",
      detail:
          "A héten érdemes egy ismétlődő, egyszerű fehérjeforrást beiktatni (tojás, joghurt, csirke).",
      praiseOnly: false,
      weak: "Még ${loggedDays - proteinDays} napon volt kevés a fehérje.",
    );
  }

  static SleepTip sleepFromHistory() {
    final last = SleepStore.lastNight;
    if (last == null) {
      return const SleepTip(
        headline: "Még nincs alvásnaplód",
        detail:
            "Naplózz egy éjszakát. Esténként a megszokott lefekvés előtt 15 perccel emlékeztetünk.",
        praise: false,
      );
    }

    final average = SleepStore.averageHours;
    if (average > 0 && (last.hours - average).abs() < 0.6 && last.hours >= 6.5) {
      return SleepTip(
        headline: "Ez az éjszaka a ritmusodban volt.",
        detail:
            "${last.durationLabel} — tartsd a megszokott lefekvést, ez most a legerősebb, amit tehetsz.",
        praise: true,
      );
    }

    if (last.hours < 6 || (average > 0 && last.hours + 1.5 < average)) {
      return const SleepTip(
        headline: "Rövidebb éjszaka volt a szokásosnál",
        detail:
            "Ma ne emelj terhelést. Estére: kávé 8 után ne, képernyő halványabban, ugyanaz a lefekvés, mint a jó napokon.",
        praise: false,
      );
    }

    final typical = SleepStore.typicalSchedule();
    final bed = typical == null
        ? ""
        : "Szokásos lefekvés: ${typical.bedHour.toString().padLeft(2, "0")}:${typical.bedMinute.toString().padLeft(2, "0")}.";
    return SleepTip(
      headline: "Alvás naplózva: ${last.durationLabel}",
      detail: bed.isEmpty
          ? "A rendszeresség többet számít, mint egy hosszú hétvége."
          : "$bed Lefekvés előtt 30 percben kerüljük a nehéz edzést és a nagy adag koffeint.",
      praise: last.hours >= 7,
    );
  }

  static CoachCopy localWorkoutCopy({
    required double percent,
    required ProgressionAdvice advice,
  }) {
    final signed = percent == 0
        ? "ugyanannyi"
        : "${percent > 0 ? "+" : ""}${percent.toStringAsFixed(percent.abs() == percent.abs().roundToDouble() ? 0 : 1)}%";
    if (percent > 0) {
      return CoachCopy(
        prose: advice.reason,
        pros: "A $signed emelés kicsi, a mozgásminta megmarad, a fejlődés mérhető.",
        cons: "Ha a sorok elkezdenek szétesni, azonnal vissza a mai súlyra. Nem verseny.",
      );
    }
    if (percent < 0) {
      return CoachCopy(
        prose: advice.reason,
        pros: "A $signed könnyítés helyet ad a technikának és a regenerációnak.",
        cons: "Ne maradj sokáig a könnyebb héten, ha már friss vagy — akkor lépj vissza 0-ra.",
      );
    }
    return CoachCopy(
      prose: advice.reason,
      pros: "Az ismétlés ugyanazzal a terheléssel megszilárdítja, amit ma megcsináltál.",
      cons: "Ha háromszor is könnyű marad, a következőnél már emelj egy kicsit.",
    );
  }
}
