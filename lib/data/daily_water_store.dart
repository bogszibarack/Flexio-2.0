import 'package:flutter/material.dart';

import 'repositories/water_repository.dart';

export 'repositories/water_repository.dart' show WaterSip;

/// A mai vízbevitel. Bejelentkezve a felhőbe is szinkronizálódik.
class DailyWaterController extends ChangeNotifier {
  DailyWaterController({
    required WaterRepository repository,
    required this.userId,
  }) : _repository = repository;

  final WaterRepository _repository;
  final String? userId;

  List<WaterSip> _sips = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<WaterSip> get sips => List.unmodifiable(_sips);
  int get totalMl => _sips.fold<int>(0, (sum, sip) => sum + sip.ml);

  Future<void> load() async {
    final id = userId;
    if (id == null) {
      _sips = [];
      _loaded = true;
      notifyListeners();
      return;
    }

    _sips = await _repository.loadForDay(id, DateTime.now());
    _loaded = true;
    notifyListeners();
  }

  Future<void> reload() => load();

  Future<void> add(int milliliters) async {
    if (milliliters <= 0) {
      return;
    }

    final id = userId;
    if (id == null) {
      return;
    }

    final sip = await _repository.addSip(id, milliliters);
    _sips = [..._sips, sip];
    notifyListeners();
  }
}

Future<int?> promptWaterAmount(BuildContext context) async {
  final controller = TextEditingController(text: "250");
  final result = await showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Mennyi vizet ittál meg?"),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "ml",
            suffixText: "ml",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Mégse"),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.pop(context, value);
            },
            child: const Text("Hozzáadás"),
          ),
        ],
      );
    },
  );
  controller.dispose();
  if (result == null || result <= 0) {
    return null;
  }
  return result;
}

String litersLabel(int milliliters) {
  if (milliliters <= 0) {
    return "0 Liter";
  }
  final liters = milliliters / 1000;
  final decimals = milliliters % 1000 == 0 ? 0 : 1;
  return "${liters.toStringAsFixed(decimals)} Liter";
}

String relativeTimeHu(DateTime at) {
  final diff = DateTime.now().difference(at);
  if (diff.inMinutes < 1) {
    return "Épp most";
  }
  if (diff.inMinutes < 60) {
    return "${diff.inMinutes} perce";
  }
  if (diff.inHours < 24) {
    return "${diff.inHours} órája";
  }
  if (diff.inDays == 1) {
    return "Tegnap";
  }
  if (diff.inDays < 7) {
    return "${diff.inDays} napja";
  }
  return "${at.year}.${at.month.toString().padLeft(2, "0")}.${at.day.toString().padLeft(2, "0")}.";
}
