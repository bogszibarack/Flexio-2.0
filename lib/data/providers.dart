import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../view/meal_planner/meal_store.dart';
import '../view/photo_progress/photo_progress_store.dart';
import '../view/sleep_tracker/sleep_store.dart';
import '../view/workout_tracker/workout_store.dart';
import 'coach/coach_service.dart';
import 'coach/coach_settings.dart';
import 'daily_water_store.dart';
import 'health_sync_service.dart';
import 'notification_service.dart';
import 'local/app_database.dart';
import 'models/diary_entry.dart';
import 'models/user_profile.dart';
import 'remote/flexio_api_gateway.dart';
import 'remote/storage_gateway.dart';
import 'remote/supabase_gateway.dart';
import 'repositories/diary_repository.dart';
import 'repositories/food_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/progress_photo_repository.dart';
import 'repositories/sleep_repository.dart';
import 'repositories/water_repository.dart';
import 'repositories/workout_repository.dart';
import 'session_service.dart';
import 'sync_service.dart';
import 'app_config.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final supabaseGatewayProvider = Provider<SupabaseGateway>((ref) {
  if (AppConfig.hasOwnApi) {
    return const FlexioApiGateway();
  }
  return const SupabaseGateway();
});

final storageGatewayProvider = Provider<StorageGateway>((ref) {
  return const StorageGateway();
});

final sessionServiceProvider = ChangeNotifierProvider<SessionService>((ref) {
  return SessionService(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
  );
});

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
  );
});

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepository(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
    storage: ref.watch(storageGatewayProvider),
  );
});

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  return WaterRepository(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
  );
});

final progressPhotoRepositoryProvider = Provider<ProgressPhotoRepository>((ref) {
  return ProgressPhotoRepository(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
    storage: ref.watch(storageGatewayProvider),
  );
});

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
  );
});

final sleepRepositoryProvider = Provider<SleepRepository>((ref) {
  return SleepRepository(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    database: ref.watch(appDatabaseProvider),
    gateway: ref.watch(supabaseGatewayProvider),
    diary: ref.watch(diaryRepositoryProvider),
    foods: ref.watch(foodRepositoryProvider),
    profiles: ref.watch(profileRepositoryProvider),
    workouts: ref.watch(workoutRepositoryProvider),
    sleep: ref.watch(sleepRepositoryProvider),
    water: ref.watch(waterRepositoryProvider),
    progressPhotos: ref.watch(progressPhotoRepositoryProvider),
  );
});

/// A napló élő állapota. Erre épül a diagram, a napi lista és az ütemezés.
final diaryEntriesProvider = StreamProvider<List<DiaryEntry>>((ref) {
  final session = ref.watch(sessionServiceProvider);
  final userId = session.userId;
  if (userId == null) {
    return Stream.value(const <DiaryEntry>[]);
  }
  return ref.watch(diaryRepositoryProvider).watch(userId);
});

/// Profil és az abból számolt célértékek.
class ProfileController extends ChangeNotifier {
  ProfileController({
    required ProfileRepository repository,
    required this.userId,
  }) : _repository = repository;

  final ProfileRepository _repository;
  final String? userId;

  UserProfile _profile = UserProfile.empty();
  bool _loading = true;
  bool _alive = true;

  UserProfile get profile => _profile;
  bool get isLoading => _loading;
  NutritionGoals get goals => _profile.goals;

  void _emit() {
    if (_alive) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _alive = false;
    super.dispose();
  }

  Future<void> load() async {
    final id = userId;
    if (id == null) {
      _loading = false;
      _emit();
      return;
    }

    _profile = await _repository.load(id);
    final stashed = await _repository.peekOnboardingProfile();
    if (stashed != null) {
      _profile = _profile.mergeFrom(stashed);
      await _repository.save(id, _profile);
      await _repository.takeOnboardingProfile();
    }
    if (!_alive) {
      return;
    }
    _applyToWorkoutStore();
    _loading = false;
    _emit();

    // A pull a repóban egyesíti a távoli és helyi adatot; itt csak a DB-ből
    // frissítünk, hogy ne írja felül a fenti emit-et egy üres szerver-válasz.
    await _repository.pull(id);
    if (!_alive) {
      return;
    }
    _profile = await _repository.load(id);
    _applyToWorkoutStore();
    _emit();
  }

  void Function(UserProfile profile)? onSaved;

  Future<void> save(UserProfile profile) async {
    final id = userId;
    _profile = profile;
    _applyToWorkoutStore();
    _emit();
    onSaved?.call(profile);

    if (id != null) {
      final stashed = await _repository.takeOnboardingProfile();
      final merged =
          stashed == null ? profile : profile.mergeFrom(stashed);
      await _repository.save(id, merged);
      _profile = merged;
      _applyToWorkoutStore();
      _emit();
      return;
    }

    await _repository.stashOnboardingProfile(profile);
  }

  Future<void> update({
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
      save(_profile.copyWith(
        firstName: firstName,
        gender: gender,
        birthDate: birthDate,
        heightCm: heightCm,
        weightKg: weightKg,
        activityLevel: activityLevel,
        goal: goal,
        manualGoals: manualGoals,
        avatarPath: avatarPath,
        clearManualGoals: clearManualGoals,
        clearAvatar: clearAvatar,
      ));

  /// Az edzés-kalória becslés a valódi testsúllyal számol.
  void _applyToWorkoutStore() {
    final weight = _profile.weightKg;
    if (weight != null && weight > 25) {
      WorkoutStore.userWeightKg = weight;
    }
  }
}

final profileControllerProvider = ChangeNotifierProvider<ProfileController>((ref) {
  final session = ref.watch(sessionServiceProvider);
  final controller = ProfileController(
    repository: ref.watch(profileRepositoryProvider),
    userId: session.userId,
  );
  controller.onSaved = (profile) {
    ref.read(healthSyncProvider).syncBody(profile);
  };
  controller.load();
  return controller;
});

final healthSyncProvider = ChangeNotifierProvider<HealthSyncService>((ref) {
  final health = HealthSyncService(database: ref.watch(appDatabaseProvider));
  WorkoutStore.onCompletedLogged = health.syncWorkout;
  SleepStore.onLogged = health.syncSleep;
  ref.read(diaryRepositoryProvider).onLogged = health.syncMeal;
  health.bootstrap();
  return health;
});

final notificationServiceProvider =
    ChangeNotifierProvider<NotificationService>((ref) {
  final notifications = NotificationService(
    database: ref.watch(appDatabaseProvider),
  );
  WorkoutStore.revision.addListener(notifications.scheduleSoon);
  SleepStore.revision.addListener(notifications.scheduleSoon);
  PhotoProgressStore.revision.addListener(notifications.scheduleSoon);
  notifications.bootstrap();
  ref.onDispose(() {
    WorkoutStore.revision.removeListener(notifications.scheduleSoon);
    SleepStore.revision.removeListener(notifications.scheduleSoon);
    PhotoProgressStore.revision.removeListener(notifications.scheduleSoon);
  });
  return notifications;
});

final coachSettingsProvider = ChangeNotifierProvider<CoachSettings>((ref) {
  final settings = CoachSettings(database: ref.watch(appDatabaseProvider));
  settings.addListener(() {
    final notifications = ref.read(notificationServiceProvider);
    notifications.sleepCoachEnabled = settings.sleep;
    notifications.scheduleSoon();
  });
  settings.load().then((_) {
    CoachService(
      settings: settings,
      notifications: ref.read(notificationServiceProvider),
    ).maybeWeeklySummary(
      profile: ref.read(profileControllerProvider).profile,
      store: ref.read(mealStoreProvider),
    );
  });
  return settings;
});

final coachServiceProvider = Provider<CoachService>((ref) {
  return CoachService(
    settings: ref.watch(coachSettingsProvider),
    notifications: ref.watch(notificationServiceProvider),
  );
});

/// A mai vízbevitel. Nincs mock kezdőérték, üres nappal indul.
final dailyWaterProvider = ChangeNotifierProvider<DailyWaterController>((ref) {
  final controller = DailyWaterController(
    repository: ref.watch(waterRepositoryProvider),
    userId: ref.watch(sessionServiceProvider).userId,
  );
  controller.load();
  return controller;
});

/// A napi célértékek: a profilból számolva, vagy kézi beállításból.
final nutritionGoalsProvider = Provider<NutritionGoals>((ref) {
  return ref.watch(profileControllerProvider).goals;
});

/// A statikus store-ok (edzés, alvás) a bejelentkezett felhasználó adataival
/// töltődnek fel, és fiókváltásnál kiürülnek.
class UserScope {
  UserScope({
    required WorkoutRepository workouts,
    required SleepRepository sleep,
    required ProgressPhotoRepository progressPhotos,
    required SyncService sync,
    Future<void> Function()? onAfterSync,
  })  : _workouts = workouts,
        _sleep = sleep,
        _progressPhotos = progressPhotos,
        _sync = sync,
        _onAfterSync = onAfterSync;

  final WorkoutRepository _workouts;
  final SleepRepository _sleep;
  final ProgressPhotoRepository _progressPhotos;
  final SyncService _sync;
  final Future<void> Function()? _onAfterSync;

  Future<void> attach(String userId) async {
    await WorkoutStore.bind(repository: _workouts, userId: userId);
    await SleepStore.bind(repository: _sleep, userId: userId);
    await PhotoProgressStore.bind(
      repository: _progressPhotos,
      userId: userId,
    );
  }

  void detach() {
    WorkoutStore.unbind();
    SleepStore.unbind();
    PhotoProgressStore.unbind();
  }

  /// Belépés után: helyi adat azonnal, majd szinkron, végül újratöltés, hogy a
  /// másik eszközön rögzített adatok is megjelenjenek.
  Future<void> attachAndSync(String userId) async {
    await attach(userId);
    await WorkoutStore.flushPersists();
    await _sync.syncAll(userId);
    await attach(userId);
    if (_onAfterSync != null) {
      await _onAfterSync();
    }
  }
}

final userScopeProvider = Provider<UserScope>((ref) {
  return UserScope(
    workouts: ref.watch(workoutRepositoryProvider),
    sleep: ref.watch(sleepRepositoryProvider),
    progressPhotos: ref.watch(progressPhotoRepositoryProvider),
    sync: ref.watch(syncServiceProvider),
    onAfterSync: () async {
      await ref.read(dailyWaterProvider).reload();
      await ref.read(profileControllerProvider).load();
    },
  );
});

/// Az étkezési összesítések (diagram, napi lista, ütemezés) egy helyről.
final mealStoreProvider = Provider<MealStore>((ref) {
  final entries = ref.watch(diaryEntriesProvider).valueOrNull ??
      const <DiaryEntry>[];
  return MealStore(entries, goals: ref.watch(nutritionGoalsProvider));
});
