
import 'package:flutter/material.dart';

import '../common/colo_extension.dart';

class OnBoardingPage extends StatelessWidget {
  final Map pObj;
  const OnBoardingPage({super.key, required this.pObj});

  @override
  Widget build(BuildContext context) {
     var media = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 120),
      child: SizedBox(
        width: media.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              pObj["image"].toString(),
              width: media.width,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              height: media.width * 0.08,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                pObj["title"].toString(),
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                pObj["subtitle"].toString(),
                style: TextStyle(color: TColor.gray, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}