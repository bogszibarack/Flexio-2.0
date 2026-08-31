import 'dart:io';

import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/round_button.dart';
import 'photo_progress_store.dart';

class ResultView extends StatelessWidget {
  final DateTime date1;
  final DateTime date2;
  const ResultView({super.key, required this.date1, required this.date2});

  String _monthLabel(DateTime date) =>
      dateToYearMonth(date);

  @override
  Widget build(BuildContext context) {
    final pairs = PhotoPose.values
        .map((pose) => (
              pose: pose,
              first: PhotoProgressStore.latestOf(date1, pose),
              second: PhotoProgressStore.latestOf(date2, pose),
            ))
        .where((pair) => pair.first != null || pair.second != null)
        .toList();

    final firstCount = PhotoProgressStore.photosInMonth(date1).length;
    final secondCount = PhotoProgressStore.photosInMonth(date2).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
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
          "Eredmény",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _monthLabel(date1),
                    style: TextStyle(
                        color: TColor.gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _monthLabel(date2),
                    style: TextStyle(
                        color: TColor.gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "$firstCount fotó  ·  $secondCount fotó",
                style: TextStyle(color: TColor.gray, fontSize: 12),
              ),
              const SizedBox(height: 20),
              if (pairs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Text(
                    "Ezekben a hónapokban nincs összevethető fotó.",
                    style: TextStyle(color: TColor.gray, fontSize: 12),
                  ),
                )
              else
                for (final pair in pairs) ...[
                  Text(
                    pair.pose.label,
                    style: TextStyle(
                        color: TColor.gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _photoCell(pair.first)),
                      const SizedBox(width: 15),
                      Expanded(child: _photoCell(pair.second)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              RoundButton(
                  title: "Vissza",
                  onPressed: () => Navigator.pop(context)),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoCell(ProgressPhoto? photo) => AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: TColor.lightGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: photo == null
                ? Center(
                    child: Text(
                      "Nincs fotó",
                      style: TextStyle(color: TColor.gray, fontSize: 11),
                    ),
                  )
                : Image.file(
                    File(photo.filePath),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Icon(Icons.broken_image, color: TColor.gray),
                  ),
          ),
        ),
      );
}
