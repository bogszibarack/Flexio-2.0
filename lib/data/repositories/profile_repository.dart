import 'dart:convert';

import '../local/app_database.dart';
import '../models/user_profile.dart';
import '../remote/supabase_gateway.dart';

/// Profil és célértékek. A helyi példány az igazság a felületen, a szerver
/// pedig az eszközök közti másolat.
class ProfileRepository {
  ProfileRepository({
    required AppDatabase database,
    required SupabaseGateway gateway,
  })  : _database = database,
        _gateway = gateway;

  final AppDatabase _database;
  final SupabaseGateway _gateway;

  static String _avatarKey(String userId) => "avatar_$userId";
  static const String _onboardingProfileKey = "onboarding_profile_pending";

  Future<void> stashOnboardingProfile(UserProfile profile) async {
    final goals = profile.manualGoals;
    final payload = <String, dynamic>{
      "first_name": profile.firstName,
      "gender": profile.gender?.name,
      "birth_date": profile.birthDate?.toIso8601String(),
      "height_cm": profile.heightCm,
      "weight_kg": profile.weightKg,
      "activity_level": profile.activityLevel.name,
      "goal": profile.goal?.name,
      "calorie_goal": goals?.calories,
      "protein_goal": goals?.protein,
      "fat_goal": goals?.fat,
      "carbs_goal": goals?.carbs,
      "water_goal_ml": goals?.waterMl,
      "manual_goals": goals?.isManual ?? false,
      "updated_at": profile.updatedAt.toIso8601String(),
    };
    await _database.setMeta(_onboardingProfileKey, jsonEncode(payload));
  }

  Future<UserProfile?> peekOnboardingProfile() async {
    final raw = await _database.metaValue(_onboardingProfileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final goals = map["calorie_goal"] == null
          ? null
          : NutritionGoals(
              calories: (map["calorie_goal"] as num).toDouble(),
              protein: (map["protein_goal"] as num?)?.toDouble() ?? 0,
              fat: (map["fat_goal"] as num?)?.toDouble() ?? 0,
              carbs: (map["carbs_goal"] as num?)?.toDouble() ?? 0,
              waterMl: (map["water_goal_ml"] as num?)?.round() ?? 2500,
              isManual: map["manual_goals"] == true,
            );
      return UserProfile(
        firstName: map["first_name"] as String?,
        gender: _genderFrom(map["gender"] as String?),
        birthDate: map["birth_date"] == null
            ? null
            : DateTime.tryParse(map["birth_date"] as String),
        heightCm: (map["height_cm"] as num?)?.toDouble(),
        weightKg: (map["weight_kg"] as num?)?.toDouble(),
        activityLevel: _activityFrom(map["activity_level"] as String?),
        goal: _goalFrom(map["goal"] as String?),
        manualGoals: goals,
        updatedAt: map["updated_at"] == null
            ? DateTime.now()
            : DateTime.tryParse(map["updated_at"] as String) ?? DateTime.now(),
      );
    } on Object {
      return null;
    }
  }

  Future<UserProfile?> takeOnboardingProfile() async {
    final profile = await peekOnboardingProfile();
    if (profile != null) {
      await _database.setMeta(_onboardingProfileKey, "");
    }
    return profile;
  }

  Future<String?> _avatarFor(String userId) async {
    final raw = await _database.metaValue(_avatarKey(userId));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return raw;
  }

  Future<UserProfile> load(String userId) async {
    final row = await _database.profileForUser(userId);
    final avatar = await _avatarFor(userId);
    if (row != null) {
      return _fromRow(row).copyWith(avatarPath: avatar);
    }
    return UserProfile.empty().copyWith(avatarPath: avatar);
  }

  Future<UserProfile> save(String userId, UserProfile profile) async {
    await _database.setMeta(_avatarKey(userId), profile.avatarPath ?? "");
    await _database.saveProfileRow(_toRow(userId, profile, dirty: true));

    if (_gateway.isSignedIn) {
      final pushed = await _gateway.pushProfile(profile);
      if (pushed) {
        await _database.markProfileSynced(userId);
      }
    }

    return profile;
  }

  Future<UserProfile?> pull(String userId) async {
    if (!_gateway.isSignedIn) {
      return null;
    }

    final remote = await _gateway.pullProfile();
    if (remote == null) {
      return null;
    }

    final local = await _database.profileForUser(userId);
    // A helyi, még nem feltöltött módosítás előnyt kap.
    if (local != null && local.isDirty && local.updatedAt.isAfter(remote.updatedAt)) {
      return _fromRow(local);
    }

    final avatar = await _avatarFor(userId);
    final merged = remote.copyWith(avatarPath: avatar);
    await _database.saveProfileRow(_toRow(userId, merged, dirty: false));
    return merged;
  }

  Future<void> pushPending(String userId) async {
    final row = await _database.profileForUser(userId);
    if (row == null || !row.isDirty || !_gateway.isSignedIn) {
      return;
    }

    final pushed = await _gateway.pushProfile(_fromRow(row));
    if (pushed) {
      await _database.markProfileSynced(userId);
    }
  }

  static UserProfile _fromRow(ProfileRow row) => UserProfile(
        firstName: row.firstName,
        gender: _genderFrom(row.gender),
        birthDate: row.birthDate,
        heightCm: row.heightCm,
        weightKg: row.weightKg,
        activityLevel: _activityFrom(row.activityLevel),
        goal: _goalFrom(row.goal),
        manualGoals: row.calorieGoal == null
            ? null
            : NutritionGoals(
                calories: row.calorieGoal!,
                protein: row.proteinGoal ?? 0,
                fat: row.fatGoal ?? 0,
                carbs: row.carbsGoal ?? 0,
                waterMl: row.waterGoalMl ?? 2500,
                isManual: row.manualGoals,
              ),
        updatedAt: row.updatedAt,
      );

  static ProfileRow _toRow(String userId, UserProfile profile,
      {required bool dirty}) {
    final goals = profile.manualGoals;
    return ProfileRow(
      userId: userId,
      firstName: profile.firstName,
      gender: profile.gender?.name,
      birthDate: profile.birthDate,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      activityLevel: profile.activityLevel.name,
      goal: profile.goal?.name,
      calorieGoal: goals?.calories,
      proteinGoal: goals?.protein,
      fatGoal: goals?.fat,
      carbsGoal: goals?.carbs,
      waterGoalMl: goals?.waterMl,
      manualGoals: goals?.isManual ?? false,
      updatedAt: profile.updatedAt,
      isDirty: dirty,
    );
  }

  static Gender? _genderFrom(String? value) {
    for (final gender in Gender.values) {
      if (gender.name == value) {
        return gender;
      }
    }
    return null;
  }

  static ActivityLevel _activityFrom(String? value) {
    for (final level in ActivityLevel.values) {
      if (level.name == value) {
        return level;
      }
    }
    return ActivityLevel.moderate;
  }

  static FitnessGoal? _goalFrom(String? value) {
    for (final goal in FitnessGoal.values) {
      if (goal.name == value) {
        return goal;
      }
    }
    return null;
  }
}
