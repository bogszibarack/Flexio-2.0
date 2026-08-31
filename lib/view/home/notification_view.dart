import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/app_haptics.dart';
import '../../common/colo_extension.dart';
import '../../common_widget/notification_row.dart';
import '../../data/providers.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationServiceProvider);
    final items = notifications.visibleInbox;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            AppHaptics.light();
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
          "Értesítések",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  notifications.enabled
                      ? "Még nincs emlékeztető. Ütemezz egy edzést, vagy naplózz alvást, és ide kerül."
                      : "A felugró értesítések ki vannak kapcsolva. A coach-kártyák akkor is ide kerülnek, ha a Profilban be van kapcsolva a coach.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gray, fontSize: 14),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              itemCount: items.length + (notifications.enabled ? 0 : 1),
              separatorBuilder: (context, index) => Divider(
                color: TColor.gray.withValues(alpha: 0.5),
                height: 1,
              ),
              itemBuilder: (context, index) {
                if (!notifications.enabled && index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      "A felugró rendszerértesítés ki van kapcsolva. A coach-kártyák itt megmaradnak.",
                      style: TextStyle(color: TColor.gray, fontSize: 11),
                    ),
                  );
                }
                final item = items[notifications.enabled ? index : index - 1];
                return NotificationRow(nObj: {
                  "image": item.image,
                  "title": item.title,
                  "time": "${item.body} · ${item.timeLabel}",
                });
              },
            ),
    );
  }
}
