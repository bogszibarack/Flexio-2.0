import 'package:fitness/common/colo_extension.dart';
import 'package:fitness/view/on_boarding/on_boarding_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  bool isColorChanged = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        curve: Curves.bounceOut,
        width: media.width,
        decoration: BoxDecoration(
          gradient: isColorChanged
              ? LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isColorChanged ? null : Colors.white,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  "Flexio",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Neked is sikerülhet",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: 520,
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(31),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(31),
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        final navigator = Navigator.of(context);
                        setState(() {
                          isColorChanged = true;
                        });
                        await Future.delayed(const Duration(milliseconds: 1500));
                        if (!mounted) return;
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) => const OnBoardingView(),
                          ),
                        );
                      },
                      child: const Center(
                        child: Text(
                          'Vágjunk bele',
                          style: TextStyle(
                            color: Color(0xFF9AAEFF),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
