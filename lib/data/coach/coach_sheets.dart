import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../view/meal_planner/meal_store.dart';
import '../models/diary_entry.dart';
import '../models/user_profile.dart';
import '../providers.dart';
import 'coach_rules.dart';
import 'coach_service.dart';

/// Ritka, rövid coach-kártyák. Snackre soha nem hívjuk.
class CoachSheets {
  CoachSheets._();

  static Future<void> maybeMealCard({
    required BuildContext context,
    required WidgetRef ref,
    required DiaryEntry entry,
  }) async {
    if (entry.deletedAt != null || !MealTypes.isMain(entry.mealType)) {
      return;
    }
    final settings = ref.read(coachSettingsProvider);
    if (!settings.meal || !settings.mealCard || settings.isQuietNow) {
      return;
    }

    final store = ref.read(mealStoreProvider);
    final profile = ref.read(profileControllerProvider).profile;
    final digest = CoachRules.nutritionFor(
      consumed: store.totalsOf(store.mealsForDay(entry.loggedAt)),
      goals: profile.goals,
      goal: profile.goal,
      lastMealType: entry.mealType,
      lastFoodName: entry.foodName,
    );
    final copy = await ref.read(coachServiceProvider).copyFor(
          snapshot: CoachService.nutritionSnapshot(
            profile: profile,
            digest: digest,
          ),
        );
    if (!context.mounted) {
      return;
    }
    await _show(
      context,
      title: digest.headline,
      body: copy.prose.isNotEmpty ? copy.prose : digest.detail,
      extra: [
        if (digest.good != null) digest.good!,
        if (!digest.praiseOnly && digest.weak != null) digest.weak!,
      ],
    );
    await ref.read(coachServiceProvider).remember(
          title: digest.headline,
          body: digest.detail,
          kind: "coach_meal",
          image: "assets/img/m_3.png",
        );
  }

  static Future<void> maybeSleepTip({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final settings = ref.read(coachSettingsProvider);
    if (!settings.sleep || settings.isQuietNow) {
      return;
    }
    final tip = CoachRules.sleepFromHistory();
    final copy = await ref.read(coachServiceProvider).copyFor(
          snapshot: CoachService.sleepSnapshot(tip: tip),
        );
    if (!context.mounted) {
      return;
    }
    await _show(
      context,
      title: tip.headline,
      body: copy.prose.isNotEmpty ? copy.prose : tip.detail,
    );
    await ref.read(coachServiceProvider).remember(
          title: tip.headline,
          body: tip.detail,
          kind: "coach_sleep",
          image: "assets/img/sleep_schedule.png",
        );
  }

  static Future<void> _show(
    BuildContext context, {
    required String title,
    required String body,
    List<String> extra = const [],
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          ),
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
              Text(
                title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                style: TextStyle(color: TColor.black, fontSize: 13, height: 1.4),
              ),
              for (final line in extra.where((item) => item.isNotEmpty)) ...[
                const SizedBox(height: 8),
                Text(line, style: TextStyle(color: TColor.gray, fontSize: 12)),
              ],
              const SizedBox(height: 16),
              RoundButton(
                title: "Rendben",
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoachDigestCard extends StatelessWidget {
  const CoachDigestCard({
    super.key,
    required this.digest,
  });

  final NutritionDigest digest;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
      decoration: BoxDecoration(
        color: TColor.primaryColor2.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            digest.headline,
            style: TextStyle(
              color: TColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            digest.detail,
            style: TextStyle(color: TColor.gray, fontSize: 11, height: 1.4),
          ),
          if (digest.good != null) ...[
            const SizedBox(height: 6),
            Text(digest.good!, style: TextStyle(color: TColor.black, fontSize: 11)),
          ],
          if (!digest.praiseOnly && digest.weak != null) ...[
            const SizedBox(height: 4),
            Text(digest.weak!, style: TextStyle(color: TColor.gray, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

NutritionDigest coachNutritionDigest({
  required MealStore store,
  required UserProfile profile,
  required bool weekly,
}) {
  if (weekly) {
    return CoachRules.weeklyNutrition(store: store, goals: profile.goals);
  }
  return CoachRules.nutritionFor(
    consumed: store.totalsOf(store.mealsForDay(DateTime.now())),
    goals: profile.goals,
    goal: profile.goal,
  );
}
