import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/find_eat_cell.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/today_meal_row.dart';
import '../../data/coach/coach_sheets.dart';
import '../../data/models/diary_entry.dart';
import '../../data/providers.dart';
import 'food_search_view.dart';
import 'meal_schedule_view.dart';
import 'meal_store.dart';
import 'portion_sheet.dart';

class MealPlannerView extends ConsumerStatefulWidget {
  const MealPlannerView({super.key});

  @override
  ConsumerState<MealPlannerView> createState() => _MealPlannerViewState();
}

class _MealPlannerViewState extends ConsumerState<MealPlannerView> {
  static const String allCategories = "Összes";

  MealPeriod _period = MealPeriod.daily;
  int _periodOffset = 0;
  String _selectedCategory = allCategories;

  List findEatArr = [
    {
      "name": MealTypes.breakfast,
      "image": "assets/img/m_3.png",
      "number": "Keresés és naplózás"
    },
    {
      "name": MealTypes.lunch,
      "image": "assets/img/m_4.png",
      "number": "Keresés és naplózás"
    },
    {
      "name": MealTypes.snack,
      "image": "assets/img/m_1.png",
      "number": "Keresés és naplózás"
    },
    {
      "name": MealTypes.dinner,
      "image": "assets/img/m_2.png",
      "number": "Keresés és naplózás"
    },
  ];

  late MealStore _store;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(coachServiceProvider).maybeWeeklySummary(
            profile: ref.read(profileControllerProvider).profile,
            store: ref.read(mealStoreProvider),
          );
    });
  }

  List<DiaryEntry> get _listedMeals {
    final category =
        _selectedCategory == allCategories ? null : _selectedCategory;
    switch (_period) {
      case MealPeriod.daily:
        final now = DateTime.now();
        return _store.mealsForDay(
          DateTime(now.year, now.month, now.day + _periodOffset),
          category: category,
        );
      case MealPeriod.weekly:
        final start = MealStore.startOfWeek(DateTime.now())
            .add(Duration(days: 7 * _periodOffset));
        return _store.mealsInRange(
          start,
          start.add(const Duration(days: 7)),
          category: category,
        );
      case MealPeriod.monthly:
        final now = DateTime.now();
        final month = DateTime(now.year, now.month + _periodOffset, 1);
        return _store.mealsInRange(
          month,
          DateTime(month.year, month.month + 1, 1),
          category: category,
        );
    }
  }

  String get _mealsSectionTitle {
    if (_period == MealPeriod.daily && _periodOffset == 0) {
      return "Mai étkezések";
    }
    if (_period == MealPeriod.daily && _periodOffset == -1) {
      return "Tegnapi étkezések";
    }
    return "Étkezések – ${MealStore.periodLabel(period: _period, offset: _periodOffset)}";
  }

  String get _mealsEmptyMessage {
    if (_period == MealPeriod.daily && _periodOffset == 0) {
      return _selectedCategory == allCategories
          ? "Ma még nem naplóztál étkezést."
          : "Ma még nincs naplózott étkezés ebben a kategóriában: $_selectedCategory.";
    }
    return _selectedCategory == allCategories
        ? "Ebben az időszakban nincs naplózott étkezés."
        : "Ebben az időszakban nincs naplózott étkezés ebben a kategóriában: $_selectedCategory.";
  }

  List<MealChartBucket> get _buckets =>
      _store.chartBuckets(period: _period, offset: _periodOffset);

  Future<void> _openSearch(String mealType) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchView(mealType: mealType),
      ),
    );
  }

  Future<void> _removeEntry(DiaryEntry entry) async {
    final userId = ref.read(sessionServiceProvider).userId;
    if (userId == null) {
      return;
    }

    final repository = ref.read(diaryRepositoryProvider);
    await repository.delete(userId, entry);

    if (!mounted) {
      return;
    }

    showAppSnack(
      context,
      message: "${entry.foodName} törölve a naplóból.",
      icon: Icons.delete_outline,
      actionLabel: "Visszavonás",
      onAction: () => repository.restore(userId, entry),
    );
  }

  Future<void> _editEntry(DiaryEntry entry) async {
    final food = await ref
        .read(foodRepositoryProvider)
        .byLocalId(entry.foodLocalId ?? "");

    if (food == null || !mounted) {
      return;
    }

    await PortionSheet.show(
      context,
      food: food,
      mealType: entry.mealType,
      date: entry.loggedAt,
      editing: entry,
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    _store = ref.watch(mealStoreProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
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
        title: Text(
          "Étrend Tervező",
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Táplálkozási Adatok",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      _buildPeriodDropdown(),
                    ],
                  ),
                  _buildPeriodNavigator(),
                  SizedBox(
                    height: media.width * 0.5,
                    width: double.maxFinite,
                    child: _store.isEmpty
                        ? Center(
                            child: Text(
                              "Még nincs naplózott étkezésed. Válassz egy ételt, add hozzá egy étkezéshez, és itt látod a kalóriát makrókra bontva.",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 12),
                            ),
                          )
                        : BarChart(_buildChartData()),
                  ),
                  const SizedBox(height: 10),
                  _buildLegend(),
                  const SizedBox(height: 15),
                  _buildMacroSummary(),
                  if (ref.watch(coachSettingsProvider).meal &&
                      !_store.isEmpty) ...[
                    const SizedBox(height: 12),
                    CoachDigestCard(
                      digest: coachNutritionDigest(
                        store: _store,
                        profile: ref.watch(profileControllerProvider).profile,
                        weekly: _period == MealPeriod.weekly,
                      ),
                    ),
                  ],
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Napi Étrend Tervező",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 90,
                          height: 25,
                          child: RoundButton(
                            title: "Megtekintés",
                            type: RoundButtonType.bgGradient,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MealScheduleView(),
                                ),
                              );
                              setState(() {});
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _mealsSectionTitle,
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                      _buildCategoryDropdown(),
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.03,
                  ),
                  if (_listedMeals.isEmpty)
                    Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _mealsEmptyMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    )
                  else
                    ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _listedMeals.length,
                        itemBuilder: (context, index) {
                          final meal = _listedMeals[index];
                          return Dismissible(
                            key: ValueKey(meal.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 2),
                              padding: const EdgeInsets.only(right: 24),
                              alignment: Alignment.centerRight,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white),
                            ),
                            onDismissed: (direction) => _removeEntry(meal),
                            child: TodayMealRow(
                              entry: meal,
                              onTap: () => _editEntry(meal),
                            ),
                          );
                        }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                "Találj Ötletet Étkezéshez",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(
              height: media.width * 0.55,
              child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: findEatArr.length,
                  itemBuilder: (context, index) {
                    var fObj = findEatArr[index] as Map? ?? {};
                    return InkWell(
                      onTap: () => _openSearch("${fObj["name"]}"),
                      child: FindEatCell(
                        fObj: fObj,
                        index: index,
                      ),
                    );
                  }),
            ),
            SizedBox(
              height: media.width * 0.05,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodDropdown() {
    const labels = {
      MealPeriod.daily: "Napi",
      MealPeriod.weekly: "Heti",
      MealPeriod.monthly: "Havi",
    };

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: DropdownButtonHideUnderline(
        child: DropdownButton<MealPeriod>(
          value: _period,
          isDense: true,
          dropdownColor: TColor.white,
          borderRadius: BorderRadius.circular(15),
          icon: Icon(Icons.expand_more, color: TColor.white),
          selectedItemBuilder: (context) => labels.values
              .map((label) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      label,
                      style: TextStyle(color: TColor.white, fontSize: 12),
                    ),
                  ))
              .toList(),
          items: labels.entries
              .map((entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: TextStyle(color: TColor.black, fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _period = value;
              _periodOffset = 0;
            });
          },
        ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final categories = [allCategories, ...MealStore.categories];

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: TColor.primaryG),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isDense: true,
          dropdownColor: TColor.white,
          borderRadius: BorderRadius.circular(15),
          icon: Icon(Icons.expand_more, color: TColor.white),
          selectedItemBuilder: (context) => categories
              .map((category) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      category,
                      style: TextStyle(color: TColor.white, fontSize: 12),
                    ),
                  ))
              .toList(),
          items: categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(
                      category,
                      style: TextStyle(color: TColor.black, fontSize: 14),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
        ),
      ),
    );
  }

  Widget _buildPeriodNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _periodOffset -= 1;
            });
          },
          icon: Icon(Icons.chevron_left, color: TColor.gray, size: 22),
        ),
        Text(
          MealStore.periodLabel(period: _period, offset: _periodOffset),
          style: TextStyle(
              color: TColor.black, fontSize: 13, fontWeight: FontWeight.w600),
        ),
        IconButton(
          onPressed: _periodOffset >= 0
              ? null
              : () {
                  setState(() {
                    _periodOffset += 1;
                  });
                },
          icon: Icon(
            Icons.chevron_right,
            color: _periodOffset >= 0 ? TColor.gray.withValues(alpha: 0.3) : TColor.gray,
            size: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Fehérje", TColor.primaryColor1),
        const SizedBox(width: 12),
        _legendItem("Szénhidrát", TColor.secondaryColor1),
        const SizedBox(width: 12),
        _legendItem("Zsír", TColor.secondaryColor2),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
      ],
    );
  }

  Widget _buildMacroSummary() {
    final totals =
        _store.periodTotals(period: _period, offset: _periodOffset);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _summaryItem("${totals.calories.round()}", "kcal", TColor.black),
          _summaryItem("${totals.protein.round()} g", "fehérje",
              TColor.primaryColor1),
          _summaryItem("${totals.carbs.round()} g", "szénhidrát",
              TColor.secondaryColor1),
          _summaryItem("${totals.fat.round()} g", "zsír",
              TColor.secondaryColor2),
        ],
      ),
    );
  }

  Widget _summaryItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              color: color, fontSize: 14, fontWeight: FontWeight.w700),
        ),
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
      ],
    );
  }

  BarChartData _buildChartData() {
    final buckets = _buckets;
    final highest = buckets.fold<double>(
        0, (max, bucket) => bucket.totals.calories > max ? bucket.totals.calories : max);
    final maxY = highest <= 0
        ? _store.fallbackMaxCalories(_period)
        : highest * 1.25;
    final barWidth = buckets.length > 6 ? 14.0 : 20.0;

    return BarChartData(
      minY: 0,
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => TColor.secondaryColor1,
          tooltipRoundedRadius: 12,
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final totals = buckets[groupIndex].totals;
            return BarTooltipItem(
              "${buckets[groupIndex].label}\n${totals.calories.round()} kcal\n"
              "F ${totals.protein.round()} g · Sz ${totals.carbs.round()} g · Zs ${totals.fat.round()} g",
              const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
      barGroups: List.generate(buckets.length, (index) {
        final totals = buckets[index].totals;
        final protein = totals.proteinCalories;
        final carbs = totals.carbsCalories;
        final fat = totals.fatCalories;

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: totals.calories,
              width: barWidth,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY,
                color: TColor.gray.withValues(alpha: 0.08),
              ),
              rodStackItems: [
                BarChartRodStackItem(0, protein, TColor.primaryColor1),
                BarChartRodStackItem(
                    protein, protein + carbs, TColor.secondaryColor1),
                BarChartRodStackItem(protein + carbs, protein + carbs + fat,
                    TColor.secondaryColor2),
              ],
            ),
          ],
        );
      }),
      titlesData: FlTitlesData(
        show: true,
        leftTitles: AxisTitles(),
        topTitles: AxisTitles(),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= buckets.length) {
                return const SizedBox();
              }
              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 8,
                child: Text(
                  buckets[index].label,
                  style: TextStyle(color: TColor.gray, fontSize: 10),
                ),
              );
            },
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: maxY / 4,
            reservedSize: 42,
            getTitlesWidget: (value, meta) => Text(
              value.round().toString(),
              style: TextStyle(color: TColor.gray, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        horizontalInterval: maxY / 4,
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
    );
  }
}
