import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';
import '../../common_widget/round_textfield.dart';
import '../../data/models/food_item.dart';
import '../../data/models/nutrients.dart';
import '../../data/providers.dart';

/// Kézi étel felvitele: ha semmi nem található, a felhasználó maga adja meg a
/// 100 grammra vetített tápanyagértékeket. Az étel a saját katalógusába kerül.
class ManualFoodView extends ConsumerStatefulWidget {
  final String? initialName;
  final String? barcode;

  const ManualFoodView({super.key, this.initialName, this.barcode});

  @override
  ConsumerState<ManualFoodView> createState() => _ManualFoodViewState();
}

class _ManualFoodViewState extends ConsumerState<ManualFoodView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _kcal = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _serving = TextEditingController();

  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _name.text = widget.initialName ?? "";
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _kcal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _serving.dispose();
    super.dispose();
  }

  double _value(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(",", ".")) ?? 0;

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isBusy = true);

    final servingGrams = _value(_serving);
    final food = await ref.read(foodRepositoryProvider).createUserFood(
          name: _name.text,
          brand: _brand.text,
          barcode: widget.barcode,
          per100g: Nutrients(
            kcal: _value(_kcal),
            protein: _value(_protein),
            fat: _value(_fat),
            carbs: _value(_carbs),
          ),
          servings: [
            if (servingGrams > 0)
              FoodServing(
                label: "1 adag (${Nutrients.formatGrams(servingGrams)} g)",
                grams: servingGrams,
              ),
          ],
        );

    if (!mounted) {
      return;
    }

    Navigator.pop(context, food);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, color: TColor.black, size: 18),
        ),
        title: Text(
          "Saját étel",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "A tápanyagértékeket 100 grammra (vagy 100 ml-re) add meg, ahogy a csomagoláson szerepel.",
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
              const SizedBox(height: 18),
              RoundTextField(
                controller: _name,
                hitText: "Étel neve",
                icon: "assets/img/oatmeal.png",
                validator: (value) => (value ?? "").trim().length < 2
                    ? "Add meg az étel nevét."
                    : null,
              ),
              const SizedBox(height: 12),
              RoundTextField(
                controller: _brand,
                hitText: "Márka (nem kötelező)",
                icon: "assets/img/oatmeal.png",
              ),
              const SizedBox(height: 12),
              _numberField(_kcal, "Kalória (kcal / 100 g)", required: true),
              const SizedBox(height: 12),
              _numberField(_protein, "Fehérje (g / 100 g)"),
              const SizedBox(height: 12),
              _numberField(_carbs, "Szénhidrát (g / 100 g)"),
              const SizedBox(height: 12),
              _numberField(_fat, "Zsír (g / 100 g)"),
              const SizedBox(height: 12),
              _numberField(_serving, "Egy adag súlya grammban (nem kötelező)"),
              const SizedBox(height: 24),
              RoundButton(
                title: _isBusy ? "Mentés..." : "Mentés",
                onPressed: _isBusy ? () {} : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String label,
      {bool required = false}) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: TColor.black, fontSize: 14),
        validator: (value) {
          final text = (value ?? "").trim();
          if (text.isEmpty) {
            return required ? "Ez a mező kötelező." : null;
          }
          final parsed = double.tryParse(text.replaceAll(",", "."));
          if (parsed == null || parsed < 0 || parsed > 2000) {
            return "Nem életszerű érték.";
          }
          return null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: label,
          hintStyle: TextStyle(color: TColor.gray, fontSize: 12),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}
