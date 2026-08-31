import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/data/models/user_profile.dart';
import 'package:fitness/data/providers.dart';
import 'package:fitness/view/login/what_your_goal_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/common.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';

class CompleteProfileView extends ConsumerStatefulWidget {
  final String? firstName;

  const CompleteProfileView({super.key, this.firstName});

  @override
  ConsumerState<CompleteProfileView> createState() =>
      _CompleteProfileViewState();
}

class _CompleteProfileViewState extends ConsumerState<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController txtDate = TextEditingController();
  final TextEditingController txtWeight = TextEditingController();
  final TextEditingController txtHeight = TextEditingController();

  Gender? gender;
  DateTime? birthDate;
  bool isBusy = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  void _prefill() {
    final profile = ref.read(profileControllerProvider).profile;
    gender = profile.gender;
    birthDate = profile.birthDate;
    if (birthDate != null) {
      txtDate.text = dateToNumeric(birthDate!);
    }
    if (profile.weightKg != null) {
      txtWeight.text = profile.weightKg!.toStringAsFixed(0);
    }
    if (profile.heightCm != null) {
      txtHeight.text = profile.heightCm!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    txtDate.dispose();
    txtWeight.dispose();
    txtHeight.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = birthDate ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 10, now.month, now.day),
      helpText: "Születési dátum",
      cancelText: "Mégse",
      confirmText: "Kész",
    );

    if (picked == null) {
      return;
    }

    setState(() {
      birthDate = picked;
      txtDate.text = dateToNumeric(picked);
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => isBusy = true);

    final weight = double.tryParse(txtWeight.text.replaceAll(",", "."));
    final height = double.tryParse(txtHeight.text.replaceAll(",", "."));

    await ref.read(profileControllerProvider).update(
          firstName: widget.firstName?.trim().isEmpty == true
              ? null
              : widget.firstName?.trim(),
          gender: gender,
          birthDate: birthDate,
          weightKg: weight,
          heightCm: height,
        );

    if (!mounted) {
      return;
    }

    setState(() => isBusy = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WhatYourGoalView(
          firstName: widget.firstName ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/img/complete_profile.png",
                    width: media.width,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Text(
                    "Egészítsük ki a profilodat!",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Ebből számoljuk ki a napi kalória- és makrócélodat.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        Material(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(15),
                          child: Row(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  width: 50,
                                  height: 50,
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 15),
                                  child: Image.asset(
                                    "assets/img/gender.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: TColor.gray,
                                  )),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Gender>(
                                    value: gender,
                                    items: const [
                                      DropdownMenuItem(
                                        value: Gender.male,
                                        child: Text("Férfi"),
                                      ),
                                      DropdownMenuItem(
                                        value: Gender.female,
                                        child: Text("Nő"),
                                      ),
                                      DropdownMenuItem(
                                        value: Gender.other,
                                        child: Text("Egyéb"),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() => gender = value);
                                    },
                                    isExpanded: true,
                                    style: TextStyle(
                                        color: TColor.black, fontSize: 14),
                                    hint: Text(
                                      "Nem",
                                      style: TextStyle(
                                          color: TColor.gray, fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        RoundTextField(
                          controller: txtDate,
                          hitText: "Születési dátum",
                          icon: "assets/img/date.png",
                          readOnly: true,
                          onTap: _pickBirthDate,
                          validator: (_) => birthDate == null
                              ? "Válaszd ki a születési dátumot."
                              : null,
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RoundTextField(
                                controller: txtWeight,
                                hitText: "Testsúly",
                                icon: "assets/img/weight.png",
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                    _validateRange(value, 30, 300, "testsúlyt"),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            _unitBadge("KG"),
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RoundTextField(
                                controller: txtHeight,
                                hitText: "Magasság",
                                icon: "assets/img/hight.png",
                                keyboardType: TextInputType.number,
                                validator: (value) =>
                                    _validateRange(value, 100, 250, "magasságot"),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            _unitBadge("CM"),
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.07,
                        ),
                        RoundButton(
                            title: isBusy ? "Mentés..." : "Következő >",
                            onPressed: isBusy ? () {} : _submit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _unitBadge(String label) => Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.secondaryG,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(color: TColor.white, fontSize: 12),
        ),
      );

  static String? _validateRange(
      String? value, double min, double max, String label) {
    final parsed = double.tryParse((value ?? "").replaceAll(",", "."));
    if (parsed == null) {
      return "Add meg a $label.";
    }
    if (parsed < min || parsed > max) {
      return "Nem életszerű érték.";
    }
    return null;
  }
}
