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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
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
                    color: TColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: media.width * 0.3,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: repdbImageOptions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
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
                              color: isSelected
                                  ? TColor.white
                                  : Colors.transparent,
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
              ),
            ),
          ];
        },
        body: Material(
          color: TColor.white,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                            color: TColor.gray.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
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
                      SizedBox(
                        height: media.width * 0.05,
                      ),
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
                      SizedBox(
                        height: media.width * 0.02,
                      ),
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
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: TColor.primaryG)
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
                      SizedBox(height: media.width * 0.05),
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
                      if (exercises.isEmpty)
                        Text(
                          "Még nem adtál hozzá gyakorlatot.",
                          style: TextStyle(color: TColor.gray, fontSize: 12),
                        )
                      else
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exercises.length,
                          itemBuilder: (context, index) =>
                              _buildExerciseCard(exercises[index]),
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
                      SizedBox(
                        height: media.width * 0.3,
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RoundButton(
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
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
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

  Widget _buildExerciseCard(Map<String, dynamic> exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
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
          IconButton(
            onPressed: () {
              setState(() {
                exercises.remove(exercise);
              });
            },
            icon: Icon(Icons.close, color: TColor.gray, size: 20),
          ),
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
                            repetitions,
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
                                roundWeights =
                                    roundWeights.sublist(0, rounds);
                              }
                            }),
                            () => setModalState(() {
                              rounds++;
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
                          roundWeights[index],
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
    );
  }

  Widget _buildNumberControl(
    String label,
    int value,
    ValueChanged<int> onChanged, {
    int minimum = 0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 11)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: value > minimum ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline, size: 20),
            ),
            Text("$value", style: TextStyle(color: TColor.black)),
            IconButton(
              onPressed: () => onChanged(value + 1),
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
