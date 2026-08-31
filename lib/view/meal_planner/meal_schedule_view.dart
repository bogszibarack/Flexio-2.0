import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/meal_food_schedule_row.dart';
import '../../common_widget/nutritions_row.dart';
import '../../data/models/diary_entry.dart';
import '../../data/providers.dart';
import 'food_search_view.dart';
import 'meal_store.dart';
import 'portion_sheet.dart';

class MealScheduleView extends ConsumerStatefulWidget {
  const MealScheduleView({super.key});

  @override
  ConsumerState<MealScheduleView> createState() => _MealScheduleViewState();
}

class _MealScheduleViewState extends ConsumerState<MealScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();

  late DateTime _selectedDateAppBBar;
  late MealStore _store;

  List<Map<String, String>> get nutritionArr {
    final totals = _store.totalsOf(_store.mealsForDay(_selectedDateAppBBar));

    return [
      {
        "title": "Kalória",
        "image": "assets/img/burn.png",
        "unit_name": "kcal",
        "value": totals.calories.round().toString(),
        "max_value": _store.dailyCalorieGoal.round().toString(),
      },
      {
        "title": "Fehérje",
        "image": "assets/img/proteins.png",
        "unit_name": "g",
        "value": totals.protein.round().toString(),
        "max_value": _store.dailyProteinGoal.round().toString(),
      },
      {
        "title": "Zsír",
        "image": "assets/img/egg.png",
        "unit_name": "g",
        "value": totals.fat.round().toString(),
        "max_value": _store.dailyFatGoal.round().toString(),
      },
      {
        "title": "Szénhidrát",
        "image": "assets/img/carbo.png",
        "unit_name": "g",
        "value": totals.carbs.round().toString(),
        "max_value": _store.dailyCarbsGoal.round().toString(),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
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

  Future<void> _addToCategory(String category) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodSearchView(
          mealType: category,
          date: _selectedDateAppBBar,
        ),
      ),
    );
  }

  Widget _buildCategorySection(String category) {
    final meals = _store.mealsForDay(_selectedDateAppBBar, category: category);
    final totals = _store.totalsOf(meals);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  Text(
                    "${meals.length} tétel | ${totals.calories.round()} kalória",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                  IconButton(
                    onPressed: () => _addToCategory(category),
                    visualDensity: VisualDensity.compact,
                    tooltip: "Étel hozzáadása",
                    icon: Icon(Icons.add_circle_outline,
                        size: 20, color: TColor.primaryColor1),
                  ),
                ],
              )
            ],
          ),
        ),
        if (meals.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              "Nincs naplózott étel ehhez az étkezéshez.",
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
          )
        else
          ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: meals.length,
              itemBuilder: (context, index) {
                final meal = meals[index];
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline,
                        color: Colors.white),
                  ),
                  onDismissed: (direction) => _removeEntry(meal),
                  child: MealFoodScheduleRow(
                    entry: meal,
                    index: index,
                    onTap: () => _editEntry(meal),
                  ),
                );
              }),
      ],
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
          "Étkezési Ütemezés",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () => _addToCategory(
                MealTypes.suggestFor(DateTime.now())),
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.add, size: 20, color: TColor.black),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            // fullCalendar: false,
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
              setState(() {
                _selectedDateAppBBar = date;
              });
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
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final category in MealStore.categories)
                  _buildCategorySection(category),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tápanyagok – ${dateToDayTitle(_selectedDateAppBBar)}",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: nutritionArr.length,
                    itemBuilder: (context, index) {
                      return NutritionRow(
                        nObj: nutritionArr[index],
                      );
                    }),
                SizedBox(
                  height: media.width * 0.05,
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
