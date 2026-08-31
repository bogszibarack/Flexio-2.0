import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/local_image_store.dart';

enum PhotoPose {
  front,
  back,
  left,
  right;

  String get label => switch (this) {
        PhotoPose.front => "Elöl",
        PhotoPose.back => "Hátul",
        PhotoPose.left => "Bal oldal",
        PhotoPose.right => "Jobb oldal",
      };

  static PhotoPose fromName(String value) {
    for (final pose in PhotoPose.values) {
      if (pose.name == value) {
        return pose;
      }
    }
    return PhotoPose.front;
  }
}

class ProgressPhoto {
  final String id;
  final DateTime takenAt;
  final PhotoPose pose;
  final String filePath;

  const ProgressPhoto({
    required this.id,
    required this.takenAt,
    required this.pose,
    required this.filePath,
  });

  DateTime get month => DateTime(takenAt.year, takenAt.month);

  Map<String, dynamic> toJson() => {
        "id": id,
        "takenAt": takenAt.toIso8601String(),
        "pose": pose.name,
        "filePath": filePath,
      };

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) => ProgressPhoto(
        id: "${json["id"]}",
        takenAt: DateTime.tryParse("${json["takenAt"]}") ?? DateTime.now(),
        pose: PhotoPose.fromName("${json["pose"]}"),
        filePath: "${json["filePath"]}",
      );
}

class PhotoMonthGroup {
  final DateTime month;
  final List<ProgressPhoto> photos;

  const PhotoMonthGroup({required this.month, required this.photos});
}

/// Haladási fotók a felhasználóhoz kötve, helyi fájlokkal.
class PhotoProgressStore {
  PhotoProgressStore._();

  static const String _folder = "progress_photos";
  static const Uuid _uuid = Uuid();

  static final List<ProgressPhoto> photos = <ProgressPhoto>[];
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static String? _userId;

  static bool get isBound => _userId != null;

  static Future<void> bind(String userId) async {
    _userId = userId;
    photos
      ..clear()
      ..addAll(await _read(userId));
    _sort();
    revision.value++;
  }

  static Future<void> unbind() async {
    _userId = null;
    photos.clear();
    revision.value++;
  }

  static Future<void> wipeCurrent() async {
    for (final photo in List<ProgressPhoto>.from(photos)) {
      await LocalImageStore.deleteFile(photo.filePath);
    }
    photos.clear();
    final userId = _userId;
    if (userId != null) {
      final file = await _indexFile(userId);
      if (await file.exists()) {
        await file.delete();
      }
    }
    revision.value++;
  }

  static List<PhotoMonthGroup> get groups {
    final map = <String, List<ProgressPhoto>>{};
    for (final photo in photos.reversed) {
      final key = "${photo.month.year}-${photo.month.month}";
      map.putIfAbsent(key, () => []).add(photo);
    }
    return map.entries
        .map((entry) => PhotoMonthGroup(
              month: DateTime(
                int.parse(entry.key.split("-").first),
                int.parse(entry.key.split("-").last),
              ),
              photos: entry.value,
            ))
        .toList();
  }

  static List<DateTime> get months {
    final unique = <String, DateTime>{};
    for (final photo in photos) {
      unique["${photo.month.year}-${photo.month.month}"] = photo.month;
    }
    final list = unique.values.toList()
      ..sort((a, b) => b.compareTo(a));
    return list;
  }

  static List<ProgressPhoto> photosInMonth(DateTime month) => photos
      .where((photo) =>
          photo.takenAt.year == month.year && photo.takenAt.month == month.month)
      .toList();

  static ProgressPhoto? latestOf(DateTime month, PhotoPose pose) {
    final matches = photosInMonth(month)
        .where((photo) => photo.pose == pose)
        .toList();
    return matches.isEmpty ? null : matches.last;
  }

  static ProgressPhoto? get lastPhoto =>
      photos.isEmpty ? null : photos.last;

  static DateTime? get nextReminderDate {
    final last = lastPhoto;
    if (last == null) {
      return DateTime.now();
    }
    return DateTime(last.takenAt.year, last.takenAt.month, last.takenAt.day)
        .add(const Duration(days: 30));
  }

  static Future<ProgressPhoto?> add({
    required String sourcePath,
    required PhotoPose pose,
    DateTime? takenAt,
  }) async {
    final userId = _userId;
    if (userId == null) {
      return null;
    }

    final stored = await LocalImageStore.persist(
      sourcePath: sourcePath,
      folder: _folder,
    );

    final photo = ProgressPhoto(
      id: _uuid.v4(),
      takenAt: takenAt ?? DateTime.now(),
      pose: pose,
      filePath: stored,
    );

    photos.add(photo);
    _sort();
    await _write(userId);
    revision.value++;
    return photo;
  }

  static Future<void> remove(ProgressPhoto photo) async {
    photos.removeWhere((item) => item.id == photo.id);
    await LocalImageStore.deleteFile(photo.filePath);
    final userId = _userId;
    if (userId != null) {
      await _write(userId);
    }
    revision.value++;
  }

  static void _sort() => photos.sort((a, b) => a.takenAt.compareTo(b.takenAt));

  static Future<File> _indexFile(String userId) async {
    final root = await getApplicationDocumentsDirectory();
    return File(p.join(root.path, "progress_photos_$userId.json"));
  }

  static Future<List<ProgressPhoto>> _read(String userId) async {
    try {
      final file = await _indexFile(userId);
      if (!await file.exists()) {
        return const [];
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((row) => ProgressPhoto.fromJson(Map<String, dynamic>.from(row)))
          .where((photo) => File(photo.filePath).existsSync())
          .toList();
    } on Object {
      return const [];
    }
  }

  static Future<void> _write(String userId) async {
    final file = await _indexFile(userId);
    await file.writeAsString(
      jsonEncode(photos.map((photo) => photo.toJson()).toList()),
    );
  }
}
