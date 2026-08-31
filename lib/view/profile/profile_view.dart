import 'dart:io';

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/app_haptics.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/image_source_sheet.dart';
import '../../common_widget/round_button.dart';
import '../../data/local/local_image_store.dart';
import '../../common_widget/setting_row.dart';
import '../../common_widget/title_subtitle_cell.dart';
import '../../data/models/user_profile.dart';
import '../../data/health_sync_service.dart';
import '../../data/providers.dart';
import '../meal_planner/meal_planner_view.dart';
import '../photo_progress/photo_progress_store.dart';
import '../workout_tracker/completed_workout_list_view.dart';
import 'personal_data_view.dart';
import 'privacy_policy_view.dart';

class ProfileView extends ConsumerStatefulWidget {
  final String? firstName;

  const ProfileView({super.key, this.firstName});

  @override
  ConsumerState<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  bool _busy = false;

  String _displayName(UserProfile profile) {
    final fromProfile = (profile.firstName ?? "").trim();
    if (fromProfile.isNotEmpty) {
      return fromProfile;
    }
    final fromWidget = (widget.firstName ?? "").trim();
    return fromWidget.isNotEmpty ? fromWidget : "Barátom";
  }

  Future<void> _changeAvatar() async {
    final picked = await ImageSourceSheet.pick(context);
    if (picked == null || !mounted) {
      return;
    }

    final stored = await LocalImageStore.persist(
      sourcePath: picked.path,
      folder: "avatars",
      fileName: "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg",
    );

    final previous = ref.read(profileControllerProvider).profile.avatarPath;
    await ref.read(profileControllerProvider).update(avatarPath: stored);
    await LocalImageStore.deleteFile(previous);

    if (mounted) {
      showAppSnack(context,
          message: "Profilkép frissítve.", icon: Icons.check_circle_outline);
    }
  }

  Future<void> _openPersonalData() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalDataView()),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await _confirm(
      title: "Kijelentkezés",
      message: "Kilépsz a fiókodból. Az adataid megmaradnak.",
      confirmLabel: "Kijelentkezés",
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _busy = true);
    ref.read(userScopeProvider).detach();
    await ref.read(sessionServiceProvider).signOut();

    if (!mounted) {
      return;
    }
    setState(() => _busy = false);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _deleteAccount() async {
    final confirmed = await _confirm(
      title: "Fiók és adatok törlése",
      message:
          "Minden adatod véglegesen törlődik: profil, étkezési napló, edzések, "
          "alvás és a saját ételeid. Ez nem visszavonható.",
      confirmLabel: "Véglegesen törlöm",
      destructive: true,
    );

    if (confirmed != true) {
      return;
    }

    setState(() => _busy = true);
    await PhotoProgressStore.wipeCurrent();
    ref.read(userScopeProvider).detach();
    final deleted = await ref.read(sessionServiceProvider).deleteAccount();

    if (!mounted) {
      return;
    }
    setState(() => _busy = false);

    if (!deleted) {
      showAppSnack(context,
          message:
              "A törlés most nem sikerült. Ellenőrizd a hálózatot, és próbáld újra.",
          icon: Icons.error_outline);
      return;
    }

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) =>
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: TColor.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            title,
            style: TextStyle(
                color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          content: Text(
            message,
            style: TextStyle(color: TColor.gray, fontSize: 12, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Mégse", style: TextStyle(color: TColor.gray)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                confirmLabel,
                style: TextStyle(
                  color: destructive ? Colors.redAccent : TColor.primaryColor1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(profileControllerProvider);
    final profile = controller.profile;
    final goals = profile.goals;
    final session = ref.watch(sessionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Profil",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _busy ? null : _signOut,
            tooltip: "Kijelentkezés",
            icon: Icon(Icons.logout, size: 20, color: TColor.black),
          ),
        ],
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: _busy ? null : _changeAvatar,
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: _avatarImage(profile.avatarPath),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: TColor.primaryG),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(Icons.camera_alt,
                                size: 10, color: TColor.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayName(profile),
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          profile.goal == null
                              ? (session.email ?? "Helyi fiók")
                              : (goalLabels[profile.goal] ?? ""),
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 25,
                    child: RoundButton(
                      title: "Szerkesztés",
                      type: RoundButtonType.bgGradient,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      onPressed: _openPersonalData,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TitleSubtitleCell(
                      title: profile.heightCm == null
                          ? "–"
                          : "${profile.heightCm!.round()}cm",
                      subtitle: "Magasság",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: profile.weightKg == null
                          ? "–"
                          : "${profile.weightKg!.round()}kg",
                      subtitle: "Súly",
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TitleSubtitleCell(
                      title: profile.age == null ? "–" : "${profile.age} év",
                      subtitle: "Életkor",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              _card(
                title: "Napi célok",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${goals.calories.round()} kcal · F ${goals.protein.round()} g · "
                      "Zs ${goals.fat.round()} g · Sz ${goals.carbs.round()} g",
                      style: TextStyle(color: TColor.black, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      goals.isManual
                          ? "Kézzel beállított célértékek."
                          : profile.isComplete
                              ? "Mifflin-St Jeor alapú számítás a profilodból."
                              : "Töltsd ki a profilt a pontos célértékekhez.",
                      style: TextStyle(color: TColor.gray, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _card(
                title: "Fiók",
                child: Column(
                  children: [
                    SettingRow(
                      icon: "assets/img/p_personal.png",
                      title: "Személyes adatok",
                      onPressed: _openPersonalData,
                    ),
                    SettingRow(
                      icon: "assets/img/p_achi.png",
                      title: "Profilkép feltöltése",
                      onPressed: _busy ? () {} : _changeAvatar,
                    ),
                    SettingRow(
                      icon: "assets/img/p_activity.png",
                      title: "Étkezési előzmények",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MealPlannerView()),
                      ),
                    ),
                    SettingRow(
                      icon: "assets/img/p_workout.png",
                      title: "Edzés előzmények",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CompletedWorkoutListView()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _appleHealthCard(),
              const SizedBox(height: 25),
              _card(
                title: "Értesítés",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset("assets/img/p_notification.png",
                            height: 15, width: 15, fit: BoxFit.contain),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Text(
                            "Felugró értesítés",
                            style:
                                TextStyle(color: TColor.black, fontSize: 12),
                          ),
                        ),
                        CustomAnimatedToggleSwitch<bool>(
                          current: ref.watch(notificationServiceProvider).enabled,
                          values: const [false, true],
                          dif: 0.0,
                          indicatorSize: const Size.square(30.0),
                          animationDuration: const Duration(milliseconds: 200),
                          animationCurve: Curves.linear,
                          onChanged: _toggleNotifications,
                          iconBuilder: (context, local, global) {
                            return const SizedBox();
                          },
                          defaultCursor: SystemMouseCursors.click,
                          onTap: () => _toggleNotifications(
                              !ref.read(notificationServiceProvider).enabled),
                          iconsTappable: false,
                          wrapperBuilder: (context, global, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                    left: 10.0,
                                    right: 10.0,
                                    height: 30.0,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: TColor.secondaryG),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(50.0)),
                                      ),
                                    )),
                                child,
                              ],
                            );
                          },
                          foregroundIndicatorBuilder: (context, global) {
                            return SizedBox.fromSize(
                              size: const Size(10, 10),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: TColor.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(50.0)),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Colors.black38,
                                        spreadRadius: 0.05,
                                        blurRadius: 1.1,
                                        offset: Offset(0.0, 0.8))
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Edzés előtt, lefekvéskor és a havi fotónál emlékeztet.",
                      style: TextStyle(color: TColor.gray, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _coachCard(),
              const SizedBox(height: 25),
              _card(
                title: "Egyéb",
                child: Column(
                  children: [
                    SettingRow(
                      icon: "assets/img/p_privacy.png",
                      title: "Adatvédelmi tájékoztató",
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyView()),
                      ),
                    ),
                    SettingRow(
                      icon: "assets/img/p_setting.png",
                      title: "Kijelentkezés",
                      onPressed: _busy ? () {} : _signOut,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              _card(
                title: "Adataid törlése",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "A törlés minden naplódat és a profilodat is eltávolítja, "
                      "a szerverről és az eszközről is.",
                      style: TextStyle(
                          color: TColor.gray, fontSize: 11, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: TextButton(
                        onPressed: _busy ? null : _deleteAccount,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent.withValues(
                              alpha: 0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          "Fiók és adatok törlése",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Ételadatok: Open Food Facts (ODbL) · openfoodfacts.org\n"
                "Gyakorlatadatok: RepDB · repdb.co",
                textAlign: TextAlign.center,
                style: TextStyle(color: TColor.gray, fontSize: 10, height: 1.5),
              ),
              const SizedBox(height: 20),
              if (_busy)
                Center(
                  child: CircularProgressIndicator(
                      color: TColor.primaryColor1),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _healthConnectedMessage(HealthSyncService health) {
    final sleep = health.lastImportedSleep;
    final workouts = health.lastImportedWorkouts;
    if (sleep == 0 && workouts == 0) {
      return "Összekötve. A Health adatait a Flexio ezentúl ide hozza.";
    }
    return "Összekötve. Áthozva: $sleep alvás, $workouts edzés az Apple Healthből.";
  }

  Future<void> _toggleNotifications(bool enable) async {
    AppHaptics.selection();
    final notifications = ref.read(notificationServiceProvider);
    final ok = await notifications.setEnabled(enable);
    if (!mounted) {
      return;
    }
    showAppSnack(
      context,
      message: !enable
          ? "Értesítések kikapcsolva."
          : ok
              ? "Értesítések bekapcsolva. Az edzés, alvás és a havi fotó emlékeztet."
              : "Az értesítést a rendszerbeállításokban kell engedélyezni.",
      icon: ok || !enable ? Icons.notifications_none : Icons.error_outline,
    );
  }

  Future<void> _toggleAppleHealth(bool enable) async {
    AppHaptics.selection();
    final health = ref.read(healthSyncProvider);
    if (!enable) {
      await health.disconnect();
      if (mounted) {
        showAppSnack(context,
            message: "Apple Health szinkron kikapcsolva.",
            icon: Icons.link_off);
      }
      return;
    }

    final meals = ref.read(diaryEntriesProvider).valueOrNull ?? const [];
    final connected = await health.connect(
      profile: ref.read(profileControllerProvider).profile,
      meals: meals,
    );

    if (!mounted) {
      return;
    }
    showAppSnack(
      context,
      message: connected
          ? _healthConnectedMessage(health)
          : "Az Apple Health engedélyét a rendszerablakban kell megadni.",
      icon: connected ? Icons.favorite : Icons.error_outline,
    );
  }

  Widget _coachSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: TColor.black, fontSize: 12)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(color: TColor.gray, fontSize: 10)),
              ],
            ),
          ),
          Switch.adaptive(
            activeThumbColor: TColor.primaryColor1,
            value: value,
            onChanged: _busy ? null : onChanged,
          ),
        ],
      ),
    );
  }

  Widget _hourDropdown({
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Material(
      type: MaterialType.transparency,
      child: DropdownButtonHideUnderline(
      child: DropdownButton<int>(
        value: value,
        isDense: true,
        dropdownColor: TColor.white,
        borderRadius: BorderRadius.circular(12),
        items: List.generate(
          24,
          (hour) => DropdownMenuItem(
            value: hour,
            child: Text(
              "${hour.toString().padLeft(2, "0")}:00",
              style: TextStyle(color: TColor.black, fontSize: 12),
            ),
          ),
        ),
        onChanged: _busy
            ? null
            : (hour) {
                if (hour != null) {
                  onChanged(hour);
                }
              },
      ),
      ),
    );
  }

  Widget _coachCard() {
    final settings = ref.watch(coachSettingsProvider);
    return _card(
      title: "Coach",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _coachSwitch(
            title: "Edzés",
            subtitle:
                "Befejezés után RPE és következő terhelés. A számokat a szabályok adják.",
            value: settings.workout,
            onChanged: (value) =>
                ref.read(coachSettingsProvider).setWorkout(value),
          ),
          _coachSwitch(
            title: "Étkezés",
            subtitle: "Napi és heti makró-összefoglaló, nem falatonként.",
            value: settings.meal,
            onChanged: (value) =>
                ref.read(coachSettingsProvider).setMeal(value),
          ),
          _coachSwitch(
            title: "Étkezés utáni kártya",
            subtitle: "Csak reggeli, ebéd, vacsora. Snackre soha.",
            value: settings.mealCard,
            onChanged: (value) =>
                ref.read(coachSettingsProvider).setMealCard(value),
          ),
          _coachSwitch(
            title: "Alvás",
            subtitle:
                "Esti emlékeztető a hét átlagából. Rövid éjszaka után nincs terhelésemelés.",
            value: settings.sleep,
            onChanged: (value) =>
                ref.read(coachSettingsProvider).setSleep(value),
          ),
          Text(
            "Csendes órák (${settings.quietLabel})",
            style: TextStyle(color: TColor.black, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            "Ebben az idősávban nincs étel- vagy alváskártya. Az edzésösszefoglaló megmarad.",
            style: TextStyle(color: TColor.gray, fontSize: 10),
          ),
          Row(
            children: [
              Text("Tól", style: TextStyle(color: TColor.gray, fontSize: 11)),
              const SizedBox(width: 8),
              _hourDropdown(
                value: settings.quietStartHour,
                onChanged: (hour) => ref.read(coachSettingsProvider).setQuietHours(
                      start: hour,
                      end: settings.quietEndHour,
                    ),
              ),
              const SizedBox(width: 16),
              Text("Ig", style: TextStyle(color: TColor.gray, fontSize: 11)),
              const SizedBox(width: 8),
              _hourDropdown(
                value: settings.quietEndHour,
                onChanged: (hour) => ref.read(coachSettingsProvider).setQuietHours(
                      start: settings.quietStartHour,
                      end: hour,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appleHealthCard() {
    final health = ref.watch(healthSyncProvider);
    if (!health.isSupported) {
      return const SizedBox.shrink();
    }

    return _card(
      title: "Apple Health",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, size: 16, color: TColor.primaryColor1),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  health.enabled ? "Összekötve" : "Nincs összekötve",
                  style: TextStyle(color: TColor.black, fontSize: 12),
                ),
              ),
              if (health.busy)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: TColor.primaryColor1,
                  ),
                )
              else
                Switch.adaptive(
                  activeThumbColor: TColor.primaryColor1,
                  value: health.enabled,
                  onChanged: _busy ? null : _toggleAppleHealth,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Kétirányú szinkron: a Flexióban rögzített edzés, alvás, súly és "
            "étkezés megjelenik a Healthben. A Healthből ide jön a lépésszám, "
            "alvás, edzés és pulzus, hogy a korábbi adatokhoz is tudj viszonyítani.",
            style: TextStyle(color: TColor.gray, fontSize: 10, height: 1.4),
          ),
          if (health.enabled && health.todaySteps != null) ...[
            const SizedBox(height: 8),
            Text(
              "Mai lépések: ${health.todaySteps}",
              style: TextStyle(color: TColor.black, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }

  Widget _avatarImage(String? path) {
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return Image.file(
        File(path),
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      "assets/img/u2.png",
      width: 50,
      height: 50,
      fit: BoxFit.cover,
    );
  }

  Widget _card({required String title, required Widget child}) => Material(
        color: TColor.white,
        borderRadius: BorderRadius.circular(15),
        shadowColor: Colors.black12,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      );
}
