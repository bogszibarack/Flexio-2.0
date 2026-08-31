import 'nutrients.dart';

enum Gender { male, female, other }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum FitnessGoal { loseWeight, gainMuscle, keepFit }

const Map<ActivityLevel, double> activityFactors = {
  ActivityLevel.sedentary: 1.2,
  ActivityLevel.light: 1.375,
  ActivityLevel.moderate: 1.55,
  ActivityLevel.active: 1.725,
  ActivityLevel.veryActive: 1.9,
};

const Map<ActivityLevel, String> activityLabels = {
  ActivityLevel.sedentary: "Ülő életmód",
  ActivityLevel.light: "Könnyű mozgás",
  ActivityLevel.moderate: "Heti 3-4 edzés",
  ActivityLevel.active: "Heti 5-6 edzés",
  ActivityLevel.veryActive: "Napi edzés",
};

const Map<FitnessGoal, String> goalLabels = {
  FitnessGoal.loseWeight: "Zsírvesztés",
  FitnessGoal.gainMuscle: "Izomépítés",
  FitnessGoal.keepFit: "Formában maradás",
};

/// Napi célértékek. Vagy a profilból számoljuk, vagy a felhasználó adja meg.
class NutritionGoals {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final int waterMl;
  final bool isManual;

  const NutritionGoals({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
    this.waterMl = 2500,
    this.isManual = false,
  });

  static const NutritionGoals fallback = NutritionGoals(
    calories: 2000,
    protein: 120,
    fat: 70,
    carbs: 250,
  );

  Nutrients get asNutrients =>
      Nutrients(kcal: calories, protein: protein, fat: fat, carbs: carbs);
}

class UserProfile {
  final String? firstName;
  final Gender? gender;
  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel activityLevel;
  final FitnessGoal? goal;
  final NutritionGoals? manualGoals;
  final String? avatarPath;
  final DateTime updatedAt;

  const UserProfile({
    this.firstName,
    this.gender,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.activityLevel = ActivityLevel.moderate,
    this.goal,
    this.manualGoals,
    this.avatarPath,
    required this.updatedAt,
  });

  static UserProfile empty() => UserProfile(updatedAt: DateTime.now());

  int? get age {
    if (birthDate == null) {
      return null;
    }
    final now = DateTime.now();
    var years = now.year - birthDate!.year;
    final hadBirthday = now.month > birthDate!.month ||
        (now.month == birthDate!.month && now.day >= birthDate!.day);
    if (!hadBirthday) {
      years -= 1;
    }
    return years < 0 ? null : years;
  }

  bool get isComplete =>
      heightCm != null && weightKg != null && birthDate != null && gender != null;

  /// kg / m². Csak akkor van érték, ha megvan a magasság és a súly.
  double? get bmi {
    final height = heightCm;
    final weight = weightKg;
    if (height == null || weight == null || height <= 0 || weight <= 0) {
      return null;
    }
    final meters = height / 100;
    return weight / (meters * meters);
  }

  String get bmiLabel {
    final value = bmi;
    if (value == null) {
      return "Súly és magasság hiányzik";
    }
    if (value < 18.5) {
      return "Sovány tartomány";
    }
    if (value < 25) {
      return "Egészséges tartomány";
    }
    if (value < 30) {
      return "Túlsúly";
    }
    return "Elhízás";
  }

  String get bmiDisplay {
    final value = bmi;
    if (value == null) {
      return "–";
    }
    return value.toStringAsFixed(1).replaceAll(".", ",");
  }

  /// Mifflin-St Jeor alapanyagcsere.
  double? get basalMetabolicRate {
    final height = heightCm;
    final weight = weightKg;
    final years = age;
    if (height == null || weight == null || years == null || gender == null) {
      return null;
    }

    final base = 10 * weight + 6.25 * height - 5 * years;
    switch (gender!) {
      case Gender.male:
        return base + 5;
      case Gender.female:
        return base - 161;
      case Gender.other:
        return base - 78;
    }
  }

  double? get maintenanceCalories {
    final bmr = basalMetabolicRate;
    if (bmr == null) {
      return null;
    }
    return bmr * (activityFactors[activityLevel] ?? 1.55);
  }

  /// A célhoz igazított napi kalória és makróbontás. Ha nincs elég profiladat,
  /// a beállított kézi cél vagy az alapértelmezés jön.
  NutritionGoals get goals {
    if (manualGoals != null && manualGoals!.isManual) {
      return manualGoals!;
    }

    final maintenance = maintenanceCalories;
    if (maintenance == null) {
      return manualGoals ?? NutritionGoals.fallback;
    }

    final target = switch (goal) {
      FitnessGoal.loseWeight => maintenance - 400,
      FitnessGoal.gainMuscle => maintenance + 300,
      _ => maintenance,
    };

    final calories = target.clamp(1200, 5000).toDouble();
    final weight = weightKg ?? 70;

    // Fehérje testsúly alapján, zsír az energia 27%-a, a maradék szénhidrát.
    final proteinPerKg = switch (goal) {
      FitnessGoal.gainMuscle => 2.0,
      FitnessGoal.loseWeight => 1.9,
      _ => 1.6,
    };

    final protein = (weight * proteinPerKg).clamp(60, 260).toDouble();
    final fat = (calories * 0.27 / Nutrients.fatKcalPerGram).clamp(35, 160).toDouble();
    final remaining = calories -
        protein * Nutrients.proteinKcalPerGram -
        fat * Nutrients.fatKcalPerGram;
    final carbs = (remaining / Nutrients.carbsKcalPerGram).clamp(50, 600).toDouble();

    return NutritionGoals(
      calories: calories,
      protein: protein,
      fat: fat,
      carbs: carbs,
      waterMl: ((weight * 33).round()).clamp(1500, 4500),
    );
  }

  UserProfile copyWith({
    String? firstName,
    Gender? gender,
    DateTime? birthDate,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activityLevel,
    FitnessGoal? goal,
    NutritionGoals? manualGoals,
    String? avatarPath,
    bool clearManualGoals = false,
    bool clearAvatar = false,
  }) =>
      UserProfile(
        firstName: firstName ?? this.firstName,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        activityLevel: activityLevel ?? this.activityLevel,
        goal: goal ?? this.goal,
        manualGoals:
            clearManualGoals ? null : (manualGoals ?? this.manualGoals),
        avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
        updatedAt: DateTime.now(),
      );

  /// A másik profilból kitölti a hiányzó mezőket (onboarding átmeneti mentés).
  UserProfile mergeFrom(UserProfile other) => UserProfile(
        firstName: firstName ?? other.firstName,
        gender: gender ?? other.gender,
        birthDate: birthDate ?? other.birthDate,
        heightCm: heightCm ?? other.heightCm,
        weightKg: weightKg ?? other.weightKg,
        activityLevel: activityLevel,
        goal: goal ?? other.goal,
        manualGoals: manualGoals ?? other.manualGoals,
        avatarPath: avatarPath ?? other.avatarPath,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toRemoteRow(String userId) => {
        "user_id": userId,
        "first_name": firstName,
        "gender": gender?.name,
        "birth_date": birthDate == null
            ? null
            : "${birthDate!.year.toString().padLeft(4, '0')}-${birthDate!.month.toString().padLeft(2, '0')}-${birthDate!.day.toString().padLeft(2, '0')}",
        "height_cm": heightCm,
        "weight_kg": weightKg,
        "activity_level": _activityToDb(activityLevel),
        "goal": _goalToDb(goal),
        "updated_at": updatedAt.toUtc().toIso8601String(),
      };

  factory UserProfile.fromRemoteRow(Map<dynamic, dynamic> row) => UserProfile(
        firstName: row["first_name"] as String?,
        gender: _genderFromDb(row["gender"] as String?),
        birthDate: row["birth_date"] == null
            ? null
            : DateTime.tryParse("${row["birth_date"]}"),
        heightCm: Nutrients.readNullableDouble(row["height_cm"]),
        weightKg: Nutrients.readNullableDouble(row["weight_kg"]),
        activityLevel: _activityFromDb(row["activity_level"] as String?),
        goal: _goalFromDb(row["goal"] as String?),
        updatedAt: row["updated_at"] == null
            ? DateTime.now()
            : DateTime.parse("${row["updated_at"]}").toLocal(),
      );

  static String _activityToDb(ActivityLevel level) =>
      level == ActivityLevel.veryActive ? "very_active" : level.name;

  static ActivityLevel _activityFromDb(String? value) {
    switch (value) {
      case "sedentary":
        return ActivityLevel.sedentary;
      case "light":
        return ActivityLevel.light;
      case "active":
        return ActivityLevel.active;
      case "very_active":
        return ActivityLevel.veryActive;
      default:
        return ActivityLevel.moderate;
    }
  }

  static Gender? _genderFromDb(String? value) {
    switch (value) {
      case "male":
        return Gender.male;
      case "female":
        return Gender.female;
      case "other":
        return Gender.other;
      default:
        return null;
    }
  }

  static String? _goalToDb(FitnessGoal? goal) {
    switch (goal) {
      case FitnessGoal.loseWeight:
        return "lose_weight";
      case FitnessGoal.gainMuscle:
        return "gain_muscle";
      case FitnessGoal.keepFit:
        return "keep_fit";
      case null:
        return null;
    }
  }

  static FitnessGoal? _goalFromDb(String? value) {
    switch (value) {
      case "lose_weight":
        return FitnessGoal.loseWeight;
      case "gain_muscle":
        return FitnessGoal.gainMuscle;
      case "keep_fit":
        return FitnessGoal.keepFit;
      default:
        return null;
    }
  }
}
