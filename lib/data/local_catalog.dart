import 'dart:convert';

import 'package:flutter/services.dart';

import 'models/food_item.dart';

/// A beépített magyar ételkatalógus. Ez a keresés alaprétege: hálózat nélkül is
/// működik, és a szerveroldali találatok is erre rangsorolódnak rá.
class LocalCatalog {
  LocalCatalog._();

  static const String assetPath = "assets/food_catalog_hu.json";

  static final LocalCatalog instance = LocalCatalog._();

  final List<FoodItem> _foods = [];
  final Map<String, FoodItem> _byId = {};
  final Map<String, List<String>> _aliases = {};
  bool _loaded = false;

  int get length => _foods.length;

  Future<void> ensureLoaded() async {
    if (_loaded) {
      return;
    }

    try {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw);
      final list = decoded is Map ? decoded["foods"] : decoded;

      if (list is List) {
        for (final entry in list.whereType<Map>()) {
          final food = FoodItem.fromCatalogJson(entry);
          if (food.name.isEmpty) {
            continue;
          }
          _foods.add(food);
          _byId[food.id] = food;
          _aliases[food.id] = [
            normalize(food.name),
            ...((entry["aliases"] as List?) ?? const [])
                .map((alias) => normalize("$alias"))
                .where((alias) => alias.isNotEmpty),
          ];
        }
      }
    } on Object {
      // A katalógus nélkül is elindul az app, csak a helyi keresés lesz üres.
    }

    _loaded = true;
  }

  FoodItem? byId(String id) => _byId[id];

  /// Ékezet- és kisbetű-független normalizálás. Ugyanaz a szabály, mint a
  /// szerveroldali `food_normalize` függvényben.
  static String normalize(String input) {
    const replacements = {
      "á": "a",
      "é": "e",
      "í": "i",
      "ó": "o",
      "ö": "o",
      "ő": "o",
      "ú": "u",
      "ü": "u",
      "ű": "u",
      "â": "a",
      "ê": "e",
      "ô": "o",
      "ç": "c",
      "ñ": "n",
    };

    final lower = input.toLowerCase().trim();
    final buffer = StringBuffer();
    for (final char in lower.split("")) {
      buffer.write(replacements[char] ?? char);
    }
    return buffer.toString().replaceAll(RegExp(r"\s+"), " ");
  }

  List<FoodItem> search(String query, {int limit = 25}) {
    final normalized = normalize(query);
    if (normalized.isEmpty) {
      return const [];
    }

    final tokens =
        normalized.split(" ").where((token) => token.isNotEmpty).toList();
    final scored = <_ScoredFood>[];

    for (final food in _foods) {
      final aliases = _aliases[food.id] ?? const <String>[];
      final score = _scoreFor(normalized, tokens, aliases);
      if (score > 0) {
        scored.add(_ScoredFood(food, score));
      }
    }

    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) {
        return byScore;
      }
      return a.food.name.compareTo(b.food.name);
    });

    return scored.take(limit).map((entry) => entry.food).toList();
  }

  double _scoreFor(String query, List<String> tokens, List<String> aliases) {
    var best = 0.0;

    for (var i = 0; i < aliases.length; i += 1) {
      final alias = aliases[i];
      // Az első elem a név, azt kicsit erősebben pontozzuk.
      final weight = i == 0 ? 1.0 : 0.92;

      if (alias == query) {
        best = _max(best, 100 * weight);
        continue;
      }
      if (alias.startsWith(query)) {
        best = _max(best, 80 * weight);
        continue;
      }
      if (alias.contains(query)) {
        best = _max(best, 62 * weight);
        continue;
      }

      if (tokens.length > 1 && tokens.every(alias.contains)) {
        best = _max(best, 48 * weight);
        continue;
      }

      // Szótő-közelítés: a keresett szó elejére illeszkedő szavak.
      if (tokens.every((token) => alias
          .split(" ")
          .any((word) => word.startsWith(token) || token.startsWith(word)))) {
        best = _max(best, 40 * weight);
        continue;
      }

      final similarity = _diceSimilarity(alias, query);
      if (similarity >= 0.45) {
        best = _max(best, (18 + 30 * similarity) * weight);
      }
    }

    return best;
  }

  static double _max(double a, double b) => a > b ? a : b;

  /// Bigram alapú hasonlóság: az elírásokat kezeli ("csirimell").
  static double _diceSimilarity(String a, String b) {
    if (a.length < 2 || b.length < 2) {
      return a == b ? 1 : 0;
    }

    final first = _bigrams(a);
    final second = _bigrams(b);
    if (first.isEmpty || second.isEmpty) {
      return 0;
    }

    var shared = 0;
    final pool = List<String>.from(second);
    for (final bigram in first) {
      final index = pool.indexOf(bigram);
      if (index >= 0) {
        pool.removeAt(index);
        shared += 1;
      }
    }

    return (2 * shared) / (first.length + second.length);
  }

  static List<String> _bigrams(String value) {
    final result = <String>[];
    for (var i = 0; i < value.length - 1; i += 1) {
      result.add(value.substring(i, i + 2));
    }
    return result;
  }
}

class _ScoredFood {
  final FoodItem food;
  final double score;

  const _ScoredFood(this.food, this.score);
}
