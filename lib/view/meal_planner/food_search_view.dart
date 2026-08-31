import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/food_result_row.dart';
import '../../data/coach/coach_sheets.dart';
import '../../data/models/diary_entry.dart';
import '../../data/models/food_item.dart';
import '../../data/providers.dart';
import 'barcode_scan_view.dart';
import 'manual_food_view.dart';
import 'portion_sheet.dart';

enum _SearchTab { results, recent, favorites, own }

/// Ételkereső: keresősáv debounce-szal, legutóbbiak, kedvencek és saját ételek
/// fülekkel, vonalkód-olvasóval és kézi felvitellel.
class FoodSearchView extends ConsumerStatefulWidget {
  final String mealType;
  final DateTime? date;

  const FoodSearchView({super.key, required this.mealType, this.date});

  @override
  ConsumerState<FoodSearchView> createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends ConsumerState<FoodSearchView> {
  final TextEditingController _queryController = TextEditingController();

  Timer? _debounce;
  _SearchTab _tab = _SearchTab.recent;
  List<FoodItem> _results = const [];
  List<FoodItem> _recent = const [];
  List<FoodItem> _favorites = const [];
  List<FoodItem> _own = const [];
  bool _isSearching = false;
  String _lastQuery = "";

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _loadLists() async {
    final repository = ref.read(foodRepositoryProvider);
    final recent = await repository.recentFoods();
    final favorites = await repository.favoriteFoods();
    final own = await repository.ownFoods();

    if (!mounted) {
      return;
    }

    setState(() {
      _recent = recent;
      _favorites = favorites;
      _own = own;
    });
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    if (value.trim().length < 2) {
      setState(() {
        _results = const [];
        _tab = _SearchTab.recent;
        _lastQuery = value.trim();
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    setState(() {
      _isSearching = true;
      _tab = _SearchTab.results;
      _lastQuery = query;
    });

    final results = await ref.read(foodRepositoryProvider).search(query);

    if (!mounted || _lastQuery != query) {
      return;
    }

    setState(() {
      _results = results;
      _isSearching = false;
    });
  }

  Future<void> _openPortionSheet(FoodItem food) async {
    final entry = await PortionSheet.show(
      context,
      food: food,
      mealType: widget.mealType,
      date: widget.date,
    );

    if (entry == null || !mounted) {
      return;
    }

    await _loadLists();
    if (!mounted) {
      return;
    }

    await CoachSheets.maybeMealCard(context: context, ref: ref, entry: entry);
    if (!mounted) {
      return;
    }

    showAppSnack(
      context,
      message:
          "${entry.foodName} hozzáadva: ${entry.mealType}, ${entry.totals.kcal.round()} kcal.",
      actionLabel: "Visszavonás",
      onAction: () => _undo(entry),
    );
  }

  Future<void> _undo(DiaryEntry entry) async {
    final userId = ref.read(sessionServiceProvider).userId;
    if (userId == null) {
      return;
    }
    await ref.read(diaryRepositoryProvider).delete(userId, entry);
  }

  Future<void> _toggleFavorite(FoodItem food) async {
    await ref.read(foodRepositoryProvider).toggleFavorite(food);
    await _loadLists();

    if (!mounted) {
      return;
    }

    setState(() {
      _results = _results
          .map((item) => item.id == food.id
              ? item.copyWith(isFavorite: !food.isFavorite)
              : item)
          .toList();
    });
  }

  Future<void> _openBarcodeScanner() async {
    final food = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScanView()),
    );

    if (food == null || !mounted) {
      return;
    }

    await _openPortionSheet(food);
  }

  Future<void> _openManualEntry() async {
    final food = await Navigator.push<FoodItem>(
      context,
      MaterialPageRoute(
        builder: (context) => ManualFoodView(
          initialName: _queryController.text.trim(),
        ),
      ),
    );

    if (food == null || !mounted) {
      return;
    }

    await _loadLists();
    if (!mounted) {
      return;
    }
    await _openPortionSheet(food);
  }

  List<FoodItem> get _visibleFoods {
    switch (_tab) {
      case _SearchTab.results:
        return _results;
      case _SearchTab.recent:
        return _recent;
      case _SearchTab.favorites:
        return _favorites;
      case _SearchTab.own:
        return _own;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foods = _visibleFoods;

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
          widget.mealType,
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openBarcodeScanner,
            tooltip: "Vonalkód beolvasása",
            icon: Icon(Icons.qr_code_scanner, color: TColor.black, size: 22),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Image.asset(
                    "assets/img/search.png",
                    width: 18,
                    height: 18,
                    color: TColor.gray,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      onChanged: _onQueryChanged,
                      textInputAction: TextInputAction.search,
                      onSubmitted: _search,
                      style: TextStyle(color: TColor.black, fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Keresés: csirkemell, túró rudi, alma...",
                        hintStyle:
                            TextStyle(color: TColor.gray, fontSize: 12),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_queryController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        _queryController.clear();
                        _onQueryChanged("");
                      },
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.close, size: 18, color: TColor.gray),
                    ),
                ],
              ),
            ),
          ),
          _tabs(),
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: TColor.primaryColor1,
                ),
              ),
            ),
          Expanded(
            child: foods.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      return FoodResultRow(
                        food: food,
                        onTap: () => _openPortionSheet(food),
                        onFavoriteToggle: () => _toggleFavorite(food),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    final tabs = <_SearchTab, String>{
      if (_results.isNotEmpty || _tab == _SearchTab.results)
        _SearchTab.results: "Találatok",
      _SearchTab.recent: "Legutóbbiak",
      _SearchTab.favorites: "Kedvencek",
      _SearchTab.own: "Saját ételek",
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.entries.map((entry) {
          final isSelected = _tab == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _tab = entry.key),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient:
                      isSelected ? LinearGradient(colors: TColor.primaryG) : null,
                  color: isSelected ? null : TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? TColor.white : TColor.gray,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _emptyState() {
    final message = switch (_tab) {
      _SearchTab.results => _isSearching
          ? "Keresés..."
          : "Nincs találat erre: \"$_lastQuery\". Beolvashatod a vonalkódot, vagy felvehetsz egy saját ételt.",
      _SearchTab.recent =>
        "Itt jelennek meg a legutóbb naplózott ételeid. Keress rá valamire, és add hozzá a naplóhoz.",
      _SearchTab.favorites =>
        "Nincs kedvenced. A találatok mellett a csillaggal jelölheted azokat, amiket sokszor eszel.",
      _SearchTab.own =>
        "Még nincs saját ételed. Ha valami nincs az adatbázisban, vedd fel kézzel a csomagolás adataival.",
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: TColor.gray, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _openManualEntry,
              icon: Icon(Icons.add, size: 18, color: TColor.primaryColor1),
              label: Text(
                "Saját étel felvitele",
                style: TextStyle(
                  color: TColor.primaryColor1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
