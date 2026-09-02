import 'package:fitness/data/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/colo_extension.dart';
import '../../common_widget/round_button.dart';

class WelcomeView extends ConsumerStatefulWidget {
  final String? firstName;

  const WelcomeView({super.key, this.firstName});

  @override
  ConsumerState<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends ConsumerState<WelcomeView> {

  String get safeFirstName => (widget.firstName ?? '').trim();

  Future<void> _enterApp() async {
    final session = ref.read(sessionServiceProvider);
    final userScope = ref.read(userScopeProvider);
    await session.completeOnboarding(firstName: safeFirstName);

    final userId = session.userId;
    if (userId != null) {
      await userScope.attachAndSync(userId);
    }

    if (!mounted) {
      return;
    }

    // Vissza a SessionGate gyökeréhez, ami most a főoldalt mutatja.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Container(
          width: media.width,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
             SizedBox(
               height: media.width * 0.1,
             ),
             Image.asset(
               "assets/img/welcome.png",
               width: media.width * 0.75,
               fit: BoxFit.fitWidth,
             ),
             SizedBox(
               height: media.width * 0.1,
             ),
             Text(
               "Szia, ${safeFirstName.isNotEmpty ? safeFirstName : 'barátom'}!",
               style: TextStyle(
                   color: TColor.black,
                   fontSize: 20,
                   fontWeight: FontWeight.w700),
             ),
             Text(
               "Minden készen van, együtt\nérjük el a céljaidat!",
               textAlign: TextAlign.center,
               style: TextStyle(color: TColor.gray, fontSize: 12),
             ),
             const Spacer(),
             RoundButton(
               title: "Főoldalra",
               onPressed: _enterApp,
             ),
            ],
          ),
        ),
      ),
    );
  }
}
