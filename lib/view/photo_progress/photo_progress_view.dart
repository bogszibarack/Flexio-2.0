import 'dart:io';

import 'package:flutter/material.dart';
import '../../common/colo_extension.dart';
import '../../common/common.dart';
import '../../common_widget/app_snackbar.dart';
import '../../common_widget/sheet_option.dart';
import '../../common_widget/image_source_sheet.dart';
import '../../common_widget/round_button.dart';
import 'comparison_view.dart';
import 'photo_progress_store.dart';

class PhotoProgressView extends StatefulWidget {
  const PhotoProgressView({super.key});

  @override
  State<PhotoProgressView> createState() => _PhotoProgressViewState();
}

class _PhotoProgressViewState extends State<PhotoProgressView> {
  bool _hideReminder = false;

  @override
  void initState() {
    super.initState();
    PhotoProgressStore.revision.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    PhotoProgressStore.revision.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _addPhoto() async {
    if (!PhotoProgressStore.isBound) {
      showAppSnack(context,
          message: "Jelentkezz be a fotók mentéséhez.",
          icon: Icons.lock_outline);
      return;
    }

    final pose = await showModalBottomSheet<PhotoPose>(
      context: context,
      backgroundColor: TColor.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Material(
          color: TColor.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Milyen szögből készül a fotó?",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                for (final pose in PhotoPose.values)
                  SheetOption(
                    title: pose.label,
                    onTap: () => Navigator.pop(context, pose),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (pose == null || !mounted) {
      return;
    }

    final picked = await ImageSourceSheet.pick(context);
    if (picked == null || !mounted) {
      return;
    }

    final photo = await PhotoProgressStore.add(
      sourcePath: picked.path,
      pose: pose,
    );

    if (!mounted || photo == null) {
      return;
    }

    showAppSnack(context,
        message: "${pose.label} fotó mentve.", icon: Icons.photo_outlined);
  }

  Future<void> _removePhoto(ProgressPhoto photo) async {
    await PhotoProgressStore.remove(photo);
    if (mounted) {
      showAppSnack(context,
          message: "Fotó törölve.", icon: Icons.delete_outline);
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final groups = PhotoProgressStore.groups;
    final reminder = PhotoProgressStore.nextReminderDate;
    final last = PhotoProgressStore.lastPhoto;
    final showReminder = !_hideReminder &&
        reminder != null &&
        !reminder.isAfter(DateTime.now().add(const Duration(days: 1)));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox(),
        title: Text(
          "Haladási fotók",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showReminder)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: const Color(0xffFFE5E5),
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: BorderRadius.circular(30)),
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        child: Image.asset(
                          "assets/img/date_notifi.png",
                          width: 30,
                          height: 30,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Emlékeztető",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                last == null
                                    ? "Készítsd el az első haladási fotódat."
                                    : "A következő fotó ideje: ${dateToMonthDay(reminder)}",
                                style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700),
                              ),
                            ]),
                      ),
                      IconButton(
                          onPressed: () =>
                              setState(() => _hideReminder = true),
                          icon: Icon(
                            Icons.close,
                            color: TColor.gray,
                            size: 15,
                          ))
                    ],
                  ),
                ),
              ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                width: double.maxFinite,
                padding: const EdgeInsets.all(20),
                height: media.width * 0.4,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      TColor.primaryColor2.withValues(alpha: 0.4),
                      TColor.primaryColor1.withValues(alpha: 0.4)
                    ]),
                    borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 15),
                            Text(
                              "Kövesd a változást\nhavonta egy fotóval",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 130,
                              height: 35,
                              child: RoundButton(
                                  title: "Fotó készítése",
                                  fontSize: 12,
                                  onPressed: _addPhoto),
                            )
                          ]),
                    ),
                    Image.asset(
                      "assets/img/progress_each_photo.png",
                      width: media.width * 0.32,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: media.width * 0.05),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: BoxDecoration(
                color: TColor.primaryColor2.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      "Fotók összehasonlítása",
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  SizedBox(
                    width: 110,
                    height: 25,
                    child: RoundButton(
                      title: "Összehasonlít",
                      type: RoundButtonType.bgGradient,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      onPressed: () {
                        if (PhotoProgressStore.months.length < 2) {
                          showAppSnack(context,
                              message:
                                  "Legalább két különböző hónap fotója kell az összehasonlításhoz.",
                              icon: Icons.info_outline);
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ComparisonView(),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                "Galéria",
                style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
              ),
            ),
            if (groups.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  "Még nincs haladási fotó. A kamera gombbal készíthetsz egyet.",
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
              )
            else
              ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: groups.length,
                  itemBuilder: ((context, index) {
                    final group = groups[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            dateToYearMonth(group.month),
                            style:
                                TextStyle(color: TColor.gray, fontSize: 12),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemCount: group.photos.length,
                            itemBuilder: ((context, indexRow) {
                              final photo = group.photos[indexRow];
                              return GestureDetector(
                                onLongPress: () => _removePhoto(photo),
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 4),
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: TColor.lightGray,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          File(photo.filePath),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stack) =>
                                                  Icon(Icons.broken_image,
                                                      color: TColor.gray),
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            width: double.maxFinite,
                                            color: Colors.black45,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            child: Text(
                                              photo.pose.label,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    );
                  })),
            SizedBox(height: media.width * 0.2),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: _addPhoto,
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.photo_camera,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}
