import 'dart:convert';

import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/common_widget/round_button.dart';
import 'package:fitness/common_widget/sheet_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateWorkoutView extends StatefulWidget {
  const CreateWorkoutView({super.key});

  @override
  State<CreateWorkoutView> createState() => _CreateWorkoutViewState();
}

class _CreateWorkoutViewState extends State<CreateWorkoutView> {
  final titleController = TextEditingController();

  String selectedImage = "assets/img/repdb/ab-wheel-rollout-peak.webp";
  String difficulty = "Kezdő";
  List<String> repdbImageOptions = [];
  bool _loadedRepdbImages = false;
  final List<Map<String, dynamic>> exercises = [];
  int? _expandedIndex;
  TextEditingController? _editRepsController;
  List<TextEditingController> _editWeightControllers = [];

  List<Map<String, String>> exerciseCatalog = [];

  final List<String> difficultyOptions = ["Kezdő", "Középhaladó", "Haladó"];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadedRepdbImages) {
      _loadedRepdbImages = true;
      _loadRepdbImages();
    }
  }

  Future<void> _loadRepdbImages() async {
    final imageListJson =
        await rootBundle.loadString("assets/repdb_image_paths.json");
    final images = List<String>.from(jsonDecode(imageListJson) as List);
    final catalogJson =
        await rootBundle.loadString("assets/exercise_catalog_hu.json");
    final catalog = (jsonDecode(catalogJson) as List)
        .map((item) => Map<String, String>.from(item as Map))
        .toList();

    if (mounted) {
      setState(() {
        repdbImageOptions = images;
        exerciseCatalog = catalog;
      });
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    _disposeEditControllers();
    super.dispose();
  }

  void _disposeEditControllers() {
    _editRepsController?.dispose();
    _editRepsController = null;
    for (final controller in _editWeightControllers) {
      controller.dispose();
    }
    _editWeightControllers = [];
  }

  List<int> _weightsOf(Map<String, dynamic> exercise) {
    final stored = exercise["roundWeights"];
    if (stored is List && stored.isNotEmpty) {
      return stored.map((item) => (item as num).toInt()).toList();
    }
    final rounds = (exercise["rounds"] as num?)?.toInt() ?? 1;
    final weight = (exercise["weight"] as num?)?.toInt() ?? 0;
    return List<int>.filled(rounds, weight);
  }

  void _bindEditControllers(Map<String, dynamic> exercise) {
    _disposeEditControllers();
    final reps = (exercise["repetitions"] as num?)?.toInt() ?? 10;
    _editRepsController = TextEditingController(text: "$reps");
    _editWeightControllers = _weightsOf(exercise)
        .map((weight) => TextEditingController(text: "$weight"))
        .toList();
  }

  void _toggleExercise(int index) {
    setState(() {
      if (_expandedIndex == index) {
        _disposeEditControllers();
        _expandedIndex = null;
        return;
      }
      _bindEditControllers(exercises[index]);
      _expandedIndex = index;
    });
  }

  void _applyExerciseEdits(Map<String, dynamic> exercise) {
    final rounds = _editWeightControllers.length;
    final weights = _editWeightControllers
        .map((controller) => int.tryParse(controller.text) ?? 0)
        .toList();
    exercise["repetitions"] =
        int.tryParse(_editRepsController?.text ?? "") ?? 1;
    exercise["rounds"] = rounds;
    exercise["roundWeights"] = weights;
    exercise["weight"] = weights.isEmpty ? 0 : weights.first;
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
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
            "Új Edzés Létrehozása",
            style: TextStyle(
                color: TColor.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: media.width * 0.28,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: repdbImageOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  var img = repdbImageOptions[index];
                  var isSelected = img == selectedImage;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedImage = img;
                      });
                    },
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: media.width * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected ? TColor.white : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Image.asset(
                          img,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Material(
                color: TColor.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25)),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: TColor.gray.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      const SizedBox(height: 16),
                      _buildInputCard(
                        title: "Edzés neve",
                        icon: Icons.fitness_center_outlined,
                        child: TextField(
                          controller: titleController,
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            hintText: "pl. Has edzés",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.trending_up, color: TColor.gray, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Nehézségi szint",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: difficultyOptions.map((d) {
                          var isSelected = d == difficulty;
                          return Expanded(
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  difficulty = d;
                                });
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(colors: TColor.primaryG)
                                      : null,
                                  color: isSelected
                                      ? null
                                      : TColor.secondaryColor2
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected
                                        ? TColor.white
                                        : TColor.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Gyakorlatok",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w700),
                          ),
                          Text(
                            "${exercises.length} db",
                            style: TextStyle(color: TColor.gray, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: exercises.isEmpty
                            ? Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Még nem adtál hozzá gyakorlatot.",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 12),
                                ),
                              )
                            : ListView.builder(
                                padding: EdgeInsets.zero,
                                itemCount: exercises.length,
                                itemBuilder: (context, index) =>
                                    _buildExerciseCard(exercises[index], index),
                              ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: RoundButton(
                          title: "Gyakorlat hozzáadása",
                          fontSize: 14,
                          onPressed: _showAddExerciseSheet,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RoundButton(
                            title: "Létrehozás",
                            onPressed: () {
                              if (titleController.text.trim().isEmpty) {
                                return;
                              }
                              Navigator.pop(context, {
                                "image": selectedImage,
                                "title": titleController.text.trim(),
                                "exercises": "${exercises.length} gyakorlat",
                                "difficulty": difficulty,
                                "exerciseList": exercises,
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: TColor.primaryColor2.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: TColor.gray, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: TColor.gray, fontSize: 11)),
                SizedBox(height: 28, child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int index) {
    final expanded = _expandedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => _toggleExercise(index),
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    exercise["image"] as String,
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise["name"] as String,
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                      Text(
                        "${exercise["repetitions"]} ismétlés · ${exercise["weight"]} kg · ${exercise["rounds"]} kör",
                        style: TextStyle(color: TColor.gray, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: TColor.gray,
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if (_expandedIndex == index) {
                        _disposeEditControllers();
                        _expandedIndex = null;
                      } else if (_expandedIndex != null &&
                          _expandedIndex! > index) {
                        _expandedIndex = _expandedIndex! - 1;
                      }
                      exercises.removeAt(index);
                    });
                  },
                  icon: Icon(Icons.close, color: TColor.gray, size: 20),
                ),
              ],
            ),
          ),
          if (expanded && _editRepsController != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildNumberControl(
                    "Ismétlés",
                    _editRepsController!,
                    (_) => setState(() => _applyExerciseEdits(exercise)),
                    minimum: 1,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRoundCountControl(
                    _editWeightControllers.length,
                    () => setState(() {
                      if (_editWeightControllers.length > 1) {
                        _editWeightControllers.removeLast().dispose();
                        _applyExerciseEdits(exercise);
                      }
                    }),
                    () => setState(() {
                      _editWeightControllers
                          .add(TextEditingController(text: "0"));
                      _applyExerciseEdits(exercise);
                    }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_editWeightControllers.length, (roundIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildNumberControl(
                  "${roundIndex + 1}. kör súlya (kg)",
                  _editWeightControllers[roundIndex],
                  (_) => setState(() => _applyExerciseEdits(exercise)),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showAddExerciseSheet() {
    String query = "";
    Map<String, String>? selectedExercise;
    int repetitions = 10;
    int rounds = 3;
    var roundWeights = List<int>.filled(rounds, 0);
    final repetitionsController =
        TextEditingController(text: "$repetitions");
    var weightControllers = List.generate(
      rounds,
      (_) => TextEditingController(text: "0"),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final filteredExercises = exerciseCatalog
              .where((exercise) =>
                  exercise["searchTerms"]!
                      .toLowerCase()
                      .contains(query.toLowerCase()))
              .toList();
          final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

          return GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SafeArea(
                child: Material(
              color: TColor.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(25)),
              clipBehavior: Clip.antiAlias,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.82,
                  child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: TColor.gray.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Gyakorlat hozzáadása",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setModalState(() {
                        query = value;
                      });
                    },
                    onSubmitted: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    decoration: InputDecoration(
                      hintText: "Keress gyakorlatra, például: guggolás",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: TColor.lightGray,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        final isSelected = selectedExercise == exercise;
                        return SheetOption(
                            title: exercise["name"]!,
                            onTap: () {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setModalState(() {
                                selectedExercise = exercise;
                              });
                            },
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                exercise["image"]!,
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              ),
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle,
                                    color: TColor.primaryColor1)
                                : null,
                          );
                      },
                    ),
                  ),
                  if (selectedExercise != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberControl(
                            "Ismétlés",
                            repetitionsController,
                            (value) =>
                                setModalState(() => repetitions = value),
                            minimum: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildRoundCountControl(
                            rounds,
                            () => setModalState(() {
                              if (rounds > 1) {
                                rounds--;
                                weightControllers.removeLast().dispose();
                                roundWeights =
                                    roundWeights.sublist(0, rounds);
                              }
                            }),
                            () => setModalState(() {
                              rounds++;
                              weightControllers
                                  .add(TextEditingController(text: "0"));
                              roundWeights = [...roundWeights, 0];
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(rounds, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildNumberControl(
                          "${index + 1}. kör súlya (kg)",
                          weightControllers[index],
                          (value) =>
                              setModalState(() => roundWeights[index] = value),
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: RoundButton(
                        title: "Gyakorlat hozzáadása",
                        fontSize: 14,
                        onPressed: () {
                          setState(() {
                            exercises.add({
                              "name": selectedExercise!["name"]!,
                              "image": selectedExercise!["image"]!,
                              "repetitions": repetitions,
                              "weight": roundWeights.first,
                              "rounds": rounds,
                              "roundWeights": List<int>.from(roundWeights),
                            });
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ],
              ),
                ),
              ),
            ),
              ),
            ),
          );
        },
      ),
    ).whenComplete(() {
      repetitionsController.dispose();
      for (final controller in weightControllers) {
        controller.dispose();
      }
    });
  }

  Widget _buildNumberControl(
    String label,
    TextEditingController controller,
    ValueChanged<int> onChanged, {
    int minimum = 0,
  }) {
    int parsed() {
      final value = int.tryParse(controller.text);
      if (value == null) {
        return minimum;
      }
      return value.clamp(minimum, 9999);
    }

    void setValue(int value) {
      final next = value.clamp(minimum, 9999);
      controller.value = TextEditingValue(
        text: "$next",
        selection: TextSelection.collapsed(offset: "$next".length),
      );
      onChanged(next);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: parsed() > minimum ? () => setValue(parsed() - 1) : null,
              icon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
            SizedBox(
              width: 64,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: TColor.black, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  isDense: true,
                  hintText: "0",
                  border: UnderlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                onChanged: (text) {
                  if (text.isEmpty) {
                    onChanged(minimum);
                    return;
                  }
                  final value = int.tryParse(text);
                  if (value != null) {
                    onChanged(value.clamp(minimum, 9999));
                  }
                },
                onSubmitted: (_) => setValue(parsed()),
              ),
            ),
            IconButton(
              onPressed: () => setValue(parsed() + 1),
              icon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundCountControl(
      int rounds, VoidCallback onDecrement, VoidCallback onIncrement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Körök száma", style: TextStyle(color: TColor.gray, fontSize: 11)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: rounds > 1 ? onDecrement : null,
              icon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
            Text("$rounds", style: TextStyle(color: TColor.black)),
            IconButton(
              onPressed: onIncrement,
              icon: const Icon(Icons.add_circle_outline, size: 20),
            ),
          ],
        ),
      ],
    );
  }
}
