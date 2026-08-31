import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../data/models/user_profile.dart';
import '../../data/providers.dart';

/// Személyes adatok és napi célértékek. A kalória- és makrócélt a Mifflin-St
/// Jeor formula adja a profilból, de kézzel felül lehet írni.
class PersonalDataView extends ConsumerStatefulWidget {
  const PersonalDataView({super.key});

  @override
  ConsumerState<PersonalDataView> createState() => _PersonalDataViewState();
}

class _PersonalDataViewState extends ConsumerState<PersonalDataView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _calorieController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();

  Gender? _gender;
  DateTime? _birthDate;
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  FitnessGoal? _goal;
  bool _manualGoals = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileControllerProvider).profile;
    _nameController.text = profile.firstName ?? "";
    _heightController.text = _formatNumber(profile.heightCm);
    _weightController.text = _formatNumber(profile.weightKg);
    _gender = profile.gender;
    _birthDate = profile.birthDate;
    _activityLevel = profile.activityLevel;
    _goal = profile.goal;
    _manualGoals = profile.manualGoals?.isManual ?? false;

    final goals = profile.goals;
    _calorieController.text = goals.calories.round().toString();
    _proteinController.text = goals.protein.round().toString();
    _fatController.text = goals.fat.round().toString();
    _carbsController.text = goals.carbs.round().toString();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    super.dispose();
  }

  static String _formatNumber(double? value) {
    if (value == null) {
      return "";
    }
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(",", "."));

  UserProfile get _draft => UserProfile(
        firstName: _nameController.text.trim().isEmpty
            ? null
            : _nameController.text.trim(),
        gender: _gender,
        birthDate: _birthDate,
        heightCm: _parse(_heightController),
        weightKg: _parse(_weightController),
        activityLevel: _activityLevel,
        goal: _goal,
        updatedAt: DateTime.now(),
      );

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      locale: const Locale("hu"),
      initialDate: _birthDate ?? DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 10),
      helpText: "Születési dátum",
    );

    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_birthDate == null) {
      showAppSnack(context,
          message: "Add meg a születési dátumot.", icon: Icons.event);
      return;
    }

    setState(() => _saving = true);

    final controller = ref.read(profileControllerProvider);
    final draft = _draft;

    final manual = _manualGoals
        ? NutritionGoals(
            calories: _parse(_calorieController) ?? draft.goals.calories,
            protein: _parse(_proteinController) ?? draft.goals.protein,
            fat: _parse(_fatController) ?? draft.goals.fat,
            carbs: _parse(_carbsController) ?? draft.goals.carbs,
            waterMl: draft.goals.waterMl,
            isManual: true,
          )
        : null;

    await controller.save(draft.copyWith(
      manualGoals: manual,
      clearManualGoals: manual == null,
    ));

    if (!mounted) {
      return;
    }

    setState(() => _saving = false);
    showAppSnack(context,
        message: "Profil elmentve.", icon: Icons.check_circle_outline);
    Navigator.pop(context);
  }

  void _recalculateGoalPreview() {
    final goals = _draft.goals;
    _calorieController.text = goals.calories.round().toString();
    _proteinController.text = goals.protein.round().toString();
    _fatController.text = goals.fat.round().toString();
    _carbsController.text = goals.carbs.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final draft = _draft;
    final maintenance = draft.maintenanceCalories;

    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios, size: 18, color: TColor.black),
        ),
        title: Text(
          "Személyes adatok",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            children: [
              RoundTextField(
                hitText: "Keresztnév",
                icon: "assets/img/user_text.png",
                controller: _nameController,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 15),
              _genderField(),
              const SizedBox(height: 15),
              _birthDateField(),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: RoundTextField(
                      hitText: "Magasság (cm)",
                      icon: "assets/img/hight.png",
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.,]"))
                      ],
                      onChanged: (_) => setState(_syncPreview),
                      validator: (value) => _rangeValidator(value, 100, 250),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: RoundTextField(
                      hitText: "Súly (kg)",
                      icon: "assets/img/weight.png",
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[0-9.,]"))
                      ],
                      onChanged: (_) => setState(_syncPreview),
                      validator: (value) => _rangeValidator(value, 30, 350),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              _activityField(),
              const SizedBox(height: 15),
              _goalField(),
              const SizedBox(height: 25),
              _goalsCard(maintenance),
              const SizedBox(height: 25),
              SizedBox(
                height: 55,
                child: _saving
                    ? Center(
                        child: CircularProgressIndicator(
                            color: TColor.primaryColor1))
                    : RoundButton(title: "Mentés", onPressed: _save),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _syncPreview() {
    if (!_manualGoals) {
      _recalculateGoalPreview();
    }
  }

  String? _rangeValidator(String? value, double min, double max) {
    final text = (value ?? "").trim();
    if (text.isEmpty) {
      return "Kötelező";
    }
    final parsed = double.tryParse(text.replaceAll(",", "."));
    if (parsed == null || parsed < min || parsed > max) {
      return "${min.round()}–${max.round()} között";
    }
    return null;
  }

  Widget _shell({required Widget child}) => Material(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: child,
        ),
      );

  Widget _genderField() => _shell(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<Gender>(
            isExpanded: true,
            value: _gender,
            hint: Text("Nem kiválasztása",
                style: TextStyle(color: TColor.gray, fontSize: 12)),
            items: const [
              DropdownMenuItem(value: Gender.male, child: Text("Férfi")),
              DropdownMenuItem(value: Gender.female, child: Text("Nő")),
              DropdownMenuItem(value: Gender.other, child: Text("Egyéb")),
            ],
            style: TextStyle(color: TColor.black, fontSize: 14),
            onChanged: (value) => setState(() {
              _gender = value;
              _syncPreview();
            }),
          ),
        ),
      );

  Widget _birthDateField() => InkWell(
        onTap: _pickBirthDate,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          decoration: BoxDecoration(
              color: TColor.lightGray, borderRadius: BorderRadius.circular(15)),
          child: Row(
            children: [
              Icon(Icons.cake_outlined, size: 18, color: TColor.gray),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _birthDate == null
                      ? "Születési dátum"
                      : dateToYearMonthDay(_birthDate!),
                  style: TextStyle(
                    color: _birthDate == null ? TColor.gray : TColor.black,
                    fontSize: _birthDate == null ? 12 : 14,
                  ),
                ),
              ),
              if (_draft.age != null)
                Text("${_draft.age} év",
                    style: TextStyle(color: TColor.gray, fontSize: 12)),
            ],
          ),
        ),
      );

  Widget _activityField() => _shell(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ActivityLevel>(
            isExpanded: true,
            value: _activityLevel,
            items: ActivityLevel.values
                .map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(activityLabels[level] ?? level.name),
                    ))
                .toList(),
            style: TextStyle(color: TColor.black, fontSize: 14),
            onChanged: (value) => setState(() {
              _activityLevel = value ?? _activityLevel;
              _syncPreview();
            }),
          ),
        ),
      );

  Widget _goalField() => _shell(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<FitnessGoal>(
            isExpanded: true,
            value: _goal,
            hint: Text("Cél kiválasztása",
                style: TextStyle(color: TColor.gray, fontSize: 12)),
            items: FitnessGoal.values
                .map((goal) => DropdownMenuItem(
                      value: goal,
                      child: Text(goalLabels[goal] ?? goal.name),
                    ))
                .toList(),
            style: TextStyle(color: TColor.black, fontSize: 14),
            onChanged: (value) => setState(() {
              _goal = value;
              _syncPreview();
            }),
          ),
        ),
      );

  Widget _goalsCard(double? maintenance) => Material(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        shadowColor: Colors.black12,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Napi célértékek",
              style: TextStyle(
                  color: TColor.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              maintenance == null
                  ? "Töltsd ki a nem, dátum, magasság és súly mezőket, hogy Mifflin-St Jeor alapján számolhassunk."
                  : "Alapanyagcsere ${_draft.basalMetabolicRate!.round()} kcal, fenntartás ${maintenance.round()} kcal.",
              style: TextStyle(color: TColor.gray, fontSize: 11),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kézi célértékek",
                        style: TextStyle(color: TColor.black, fontSize: 12),
                      ),
                      Text(
                        _manualGoals
                            ? "A megadott értékeket használjuk."
                            : "Automatikus számítás a profilból.",
                        style: TextStyle(color: TColor.gray, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  activeThumbColor: TColor.primaryColor1,
                  value: _manualGoals,
                  onChanged: (value) => setState(() {
                    _manualGoals = value;
                    if (!value) {
                      _recalculateGoalPreview();
                    }
                  }),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: _goalInput("kcal", _calorieController)),
                const SizedBox(width: 10),
                Expanded(child: _goalInput("Fehérje g", _proteinController)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _goalInput("Zsír g", _fatController)),
                const SizedBox(width: 10),
                Expanded(child: _goalInput("Szénhidrát g", _carbsController)),
              ],
            ),
          ],
        ),
        ),
      );

  Widget _goalInput(String label, TextEditingController controller) =>
      TextFormField(
        controller: controller,
        enabled: _manualGoals,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(color: TColor.black, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: TColor.gray, fontSize: 11),
          filled: true,
          fillColor: TColor.lightGray,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      );
}
