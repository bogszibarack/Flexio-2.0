import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../data/models/diary_entry.dart';
import '../../data/models/food_item.dart';
import '../../data/models/nutrients.dart';
import '../../data/providers.dart';

/// Adag-választó: gramm vagy előre definiált adag, élő kalória- és
/// makró-előnézettel, étkezés-kategóriával és időponttal.
class PortionSheet extends ConsumerStatefulWidget {
  final FoodItem food;
  final String mealType;
  final DateTime? date;
  final DiaryEntry? editing;

  const PortionSheet({
    super.key,
    required this.food,
    required this.mealType,
    this.date,
    this.editing,
  });

  /// A naplózott bejegyzést adja vissza, vagy `null`-t, ha a felhasználó
  /// elvetette.
  static Future<DiaryEntry?> show(
    BuildContext context, {
    required FoodItem food,
    required String mealType,
    DateTime? date,
    DiaryEntry? editing,
  }) {
    return showModalBottomSheet<DiaryEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PortionSheet(
        food: food,
        mealType: mealType,
        date: date,
        editing: editing,
      ),
    );
  }

  @override
  ConsumerState<PortionSheet> createState() => _PortionSheetState();
}

class _PortionSheetState extends ConsumerState<PortionSheet> {
  late final TextEditingController _amountController;
  late String _mealType;
  late DateTime _loggedAt;

  FoodServing? _serving;
  double _amountG = 100;
  int _multiplier = 1;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();

    _mealType = widget.mealType;
    final now = DateTime.now();
    final day = widget.date ?? now;
    _loggedAt = widget.editing?.loggedAt ??
        DateTime(day.year, day.month, day.day, now.hour, now.minute);

    final servings = widget.food.selectableServings;
    if (widget.editing != null) {
      _amountG = widget.editing!.amountG;
      _serving = servings.firstWhere(
        (serving) => serving.label == widget.editing!.servingLabel,
        orElse: () => servings.first,
      );
      _multiplier = (_amountG / _serving!.grams).round().clamp(1, 20);
    } else {
      _serving = servings.first;
      _amountG = _serving!.grams;
    }

    _amountController =
        TextEditingController(text: Nutrients.formatGrams(_amountG));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Nutrients get _preview => widget.food.per100g.forGrams(_amountG);

  void _selectServing(FoodServing serving) {
    setState(() {
      _serving = serving;
      _multiplier = 1;
      _amountG = serving.grams;
      _amountController.text = Nutrients.formatGrams(_amountG);
    });
  }

  void _changeMultiplier(int delta) {
    final serving = _serving;
    if (serving == null) {
      return;
    }
    final next = (_multiplier + delta).clamp(1, 20);
    setState(() {
      _multiplier = next;
      _amountG = serving.grams * next;
      _amountController.text = Nutrients.formatGrams(_amountG);
    });
  }

  void _onAmountChanged(String value) {
    final parsed = double.tryParse(value.replaceAll(",", "."));
    if (parsed == null || parsed <= 0) {
      return;
    }
    setState(() {
      _amountG = parsed.clamp(1, 5000);
      _serving = null;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_loggedAt),
      helpText: "Étkezés időpontja",
      cancelText: "Mégse",
      confirmText: "Kész",
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child ?? const SizedBox(),
      ),
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _loggedAt = DateTime(
        _loggedAt.year,
        _loggedAt.month,
        _loggedAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    final session = ref.read(sessionServiceProvider);
    final userId = session.userId;
    if (userId == null) {
      return;
    }

    setState(() => _isBusy = true);

    final repository = ref.read(diaryRepositoryProvider);
    final foods = ref.read(foodRepositoryProvider);

    DiaryEntry entry;
    if (widget.editing != null) {
      entry = widget.editing!.copyWith(
        loggedAt: _loggedAt,
        mealType: _mealType,
        amountG: _amountG,
        servingLabel: _serving?.label,
        totals: widget.food.per100g.forGrams(_amountG),
        updatedAt: DateTime.now(),
      );
      await repository.save(userId, entry);
    } else {
      entry = await repository.logFood(
        userId: userId,
        food: widget.food,
        amountG: _amountG,
        mealType: _mealType,
        loggedAt: _loggedAt,
        servingLabel: _serving?.label,
      );
    }

    // A naplózott étel bekerül a legutóbbiak közé, és a keresési rangsorban is
    // előrébb sorolódik.
    await foods.markUsed(widget.food);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final servings = widget.food.selectableServings;
    final preview = _preview;

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TColor.gray.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.food.name,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.food.subtitle,
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Text(
                "Adag",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: servings
                    .map((serving) => _servingChip(serving))
                    .toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        onChanged: _onAmountChanged,
                        style: TextStyle(color: TColor.black, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          suffixText: "g",
                          suffixStyle:
                              TextStyle(color: TColor.gray, fontSize: 12),
                          hintText: "Mennyiség grammban",
                          hintStyle:
                              TextStyle(color: TColor.gray, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  if (_serving != null) ...[
                    const SizedBox(width: 10),
                    _stepper(),
                  ],
                ],
              ),
              const SizedBox(height: 18),
              _previewCard(preview),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: _mealTypeDropdown()),
                  const SizedBox(width: 10),
                  _timeButton(),
                ],
              ),
              const SizedBox(height: 20),
              RoundButton(
                title: _isBusy
                    ? "Mentés..."
                    : widget.editing != null
                        ? "Módosítás mentése"
                        : "Hozzáadás a naplóhoz",
                onPressed: _isBusy ? () {} : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _servingChip(FoodServing serving) {
    final isSelected = _serving?.label == serving.label;
    return InkWell(
      onTap: () => _selectServing(serving),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(colors: TColor.primaryG)
              : null,
          color: isSelected ? null : TColor.lightGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          serving.label,
          style: TextStyle(
            color: isSelected ? TColor.white : TColor.gray,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _stepper() => Container(
        decoration: BoxDecoration(
          color: TColor.lightGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => _changeMultiplier(-1),
              icon: Icon(Icons.remove, size: 18, color: TColor.gray),
              visualDensity: VisualDensity.compact,
            ),
            Text(
              "$_multiplier×",
              style: TextStyle(
                color: TColor.black,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () => _changeMultiplier(1),
              icon: Icon(Icons.add, size: 18, color: TColor.gray),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );

  Widget _previewCard(Nutrients preview) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: TColor.primaryColor2.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _previewItem("${preview.kcal.round()}", "kcal", TColor.black),
            _previewItem("${preview.protein.round()} g", "fehérje",
                TColor.primaryColor1),
            _previewItem("${preview.carbs.round()} g", "szénhidrát",
                TColor.secondaryColor1),
            _previewItem(
                "${preview.fat.round()} g", "zsír", TColor.secondaryColor2),
          ],
        ),
      );

  Widget _previewItem(String value, String label, Color color) => Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(label, style: TextStyle(color: TColor.gray, fontSize: 10)),
        ],
      );

  Widget _mealTypeDropdown() => Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: TColor.lightGray,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _mealType,
            isExpanded: true,
            icon: Icon(Icons.expand_more, color: TColor.gray, size: 20),
            style: TextStyle(color: TColor.black, fontSize: 13),
            items: MealTypes.all
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ))
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _mealType = value);
            },
          ),
          ),
        ),
      );

  Widget _timeButton() => InkWell(
        onTap: _pickTime,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TColor.lightGray,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.schedule, size: 16, color: TColor.gray),
              const SizedBox(width: 6),
              Text(
                DateFormat("HH:mm").format(_loggedAt),
                style: TextStyle(color: TColor.black, fontSize: 13),
              ),
            ],
          ),
        ),
      );
}
