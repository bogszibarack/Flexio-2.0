import 'dart:convert';

import 'package:flutter/material.dart';

import 'local/app_database.dart';

class WaterSip {
  const WaterSip({required this.at, required this.ml});

  final DateTime at;
  final int ml;

  Map<String, dynamic> toJson() => {
        "at": at.toIso8601String(),
        "ml": ml,
      };

  factory WaterSip.fromJson(Map<String, dynamic> json) => WaterSip(
        at: DateTime.tryParse("${json["at"]}") ?? DateTime.now(),
        ml: (json["ml"] as num?)?.toInt() ?? 0,
      );

  String get clockLabel =>
      "${at.hour.toString().padLeft(2, "0")}:${at.minute.toString().padLeft(2, "0")}";
}

/// A mai vízbevitel, helyi SyncMeta-ban. Nincs kitalált kezdőérték.
class DailyWaterController extends ChangeNotifier {
  DailyWaterController({
    required AppDatabase database,
    required this.userId,
  }) : _database = database;

  final AppDatabase _database;
  final String? userId;

  List<WaterSip> _sips = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<WaterSip> get sips => List.unmodifiable(_sips);
  int get totalMl => _sips.fold<int>(0, (sum, sip) => sum + sip.ml);

  String get _key {
    final now = DateTime.now();
    final day =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";
    return "water_${userId ?? "local"}_$day";
  }

  Future<void> load() async {
    final raw = await _database.metaValue(_key);
    _sips = _decode(raw);
    _loaded = true;
    notifyListeners();
  }

  Future<void> add(int milliliters) async {
    if (milliliters <= 0) {
      return;
    }
    _sips = [
      ..._sips,
      WaterSip(at: DateTime.now(), ml: milliliters),
    ];
    notifyListeners();
    await _database.setMeta(
      _key,
      jsonEncode(_sips.map((sip) => sip.toJson()).toList()),
    );
  }

  static List<WaterSip> _decode(String? raw) {
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return [];
      }
      return decoded
          .whereType<Map>()
          .map((item) => WaterSip.fromJson(Map<String, dynamic>.from(item)))
          .where((sip) => sip.ml > 0)
          .toList();
    } catch (_) {
      return [];
    }
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
