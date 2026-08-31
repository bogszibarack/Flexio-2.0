import 'package:carousel_slider/carousel_slider.dart';
import 'package:fitness/data/models/user_profile.dart';
import 'package:fitness/data/providers.dart';
import 'package:fitness/view/login/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';

class WhatYourGoalView extends ConsumerStatefulWidget {
  final String? firstName;

  const WhatYourGoalView({super.key, this.firstName});

  @override
  ConsumerState<WhatYourGoalView> createState() => _WhatYourGoalViewState();
}

class _WhatYourGoalViewState extends ConsumerState<WhatYourGoalView> {
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  int selectedIndex = 0;

  List goalArr = [
    {
      "image": "assets/img/goal_1.png",
      "title": "Izomépítés és formálás",
      "subtitle":
          "Alacsony a testzsírom, több izmot szeretnék felszedni és növelni az izomtömegemet.",
      "goal": FitnessGoal.gainMuscle,
    },
    {
      "image": "assets/img/goal_2.png",
      "title": "Tónusos és szálkás test",
      "subtitle":
          "Vékony alkatú vagyok tónus nélkül.\nSzeretnék izmot építeni és formába lendülni.",
      "goal": FitnessGoal.keepFit,
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Fogyás és zsírégetés",
      "subtitle":
          "Több mint 10 kg-ot szeretnék fogyni. Célom a felesleges zsír leadása és az izomtömeg növelése.",
      "goal": FitnessGoal.loseWeight,
    },
  ];

  String get safeFirstName => (widget.firstName ?? '').trim();

  Future<void> _saveGoal() async {
    final goal = goalArr[selectedIndex]["goal"] as FitnessGoal;
    await ref.read(profileControllerProvider).update(goal: goal);

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WelcomeView(
          firstName: safeFirstName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: media.height * 0.04),
              Text(
                "Mi a célod?",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Ez segít kiválasztani a\nlegjobb programot számodra.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: media.height * 0.42,
                child: CarouselSlider(
                  items: goalArr
                      .map(
                        (gObj) => Container(
                          height: media.height * 0.42,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: TColor.primaryG,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 18,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                gObj["image"].toString(),
                                width: 120,
                                fit: BoxFit.fitWidth,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                gObj["title"].toString(),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 48,
                                height: 1.5,
                                color: TColor.white,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    gObj["subtitle"].toString(),
                                    textAlign: TextAlign.center,
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 12.5,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  carouselController: buttonCarouselController,
                  options: CarouselOptions(
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.78,
                    height: media.height * 0.42,
                    initialPage: 0,
                    onPageChanged: (index, reason) {
                      setState(() => selectedIndex = index);
                    },
                  ),
                ),
              ),
              const Spacer(),
              Text(
                goalArr[selectedIndex]["title"].toString(),
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              RoundButton(
                title: "Kiválasztom",
                onPressed: _saveGoal,
              ),
              SizedBox(height: media.height * 0.025),
            ],
          ),
        ),
      ),
    );
  }
}
