import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:fitness/common/colo_extension.dart';
import 'package:flutter/material.dart';

class UpcomingWorkoutRow extends StatelessWidget {
  final Map wObj;
  final bool isPlannedToday;
  final ValueChanged<bool> onPlannedTodayChanged;
  final String? subtitle;

  const UpcomingWorkoutRow({
    super.key,
    required this.wObj,
    required this.isPlannedToday,
    required this.onPlannedTodayChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        padding: const EdgeInsets.all( 10),
        decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                wObj["image"].toString(),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wObj["title"].toString(),
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle ?? wObj["time"].toString(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 10,
                  ),
                ),
              ],
            )),

             CustomAnimatedToggleSwitch<bool>(
              current: isPlannedToday,
              values: [false, true],
              dif: 0.0,
              indicatorSize: const Size.square(30.0),
              animationDuration: const Duration(milliseconds: 200),
              animationCurve: Curves.linear,
              onChanged: onPlannedTodayChanged,
              iconBuilder: (context, local, global) {
                return const SizedBox();
              },
              defaultCursor: SystemMouseCursors.click,
              onTap: () => onPlannedTodayChanged(!isPlannedToday),
              iconsTappable: false,
              wrapperBuilder: (context, global, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                        left: 10.0,
                        right: 10.0,
                        height: 30.0,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: TColor.secondaryG),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(50.0)),
                          ),
                        )),
                    child,
                  ],
                );
              },
              foregroundIndicatorBuilder: (context, global) {
                return SizedBox.fromSize(
                  size: const Size(10, 10),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: TColor.white,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(50.0)),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black38,
                            spreadRadius: 0.05,
                            blurRadius: 1.1,
                            offset: Offset(0.0, 0.8))
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ));
  }
}
