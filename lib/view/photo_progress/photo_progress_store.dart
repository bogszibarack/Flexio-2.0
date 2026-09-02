import 'package:flutter/foundation.dart';

import '../../data/models/progress_photo.dart';
import '../../data/repositories/progress_photo_repository.dart';

export '../../data/models/progress_photo.dart';

/// Haladási fotók a felhasználóhoz kötve. A repó kezeli a szinkront.
class PhotoProgressStore {
  PhotoProgressStore._();

  static final List<ProgressPhoto> photos = <ProgressPhoto>[];
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static ProgressPhotoRepository? _repository;
  static String? _userId;

  static bool get isBound => _repository != null && _userId != null;

  static Future<void> bind({
    required ProgressPhotoRepository repository,
    required String userId,
  }) async {
    if (_userId != null && _userId != userId) {
      photos.clear();
    }

    _repository = repository;
    _userId = userId;
    photos
      ..clear()
      ..addAll(await repository.load(userId));
    _sort();
    revision.value++;
  }

  static Future<void> unbind() async {
    _repository = null;
    _userId = null;
    photos.clear();
    revision.value++;
  }

  static Future<void> wipeCurrent() async {
    final repository = _repository;
    final userId = _userId;
    if (repository == null || userId == null) {
      photos.clear();
      revision.value++;
      return;
    }

    for (final photo in List<ProgressPhoto>.from(photos)) {
      await repository.remove(userId: userId, id: photo.id);
    }
    photos.clear();
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
    final repository = _repository;
    final userId = _userId;
    if (repository == null || userId == null) {
      return null;
    }

    final photo = await repository.add(
      userId: userId,
      sourcePath: sourcePath,
      pose: pose,
      takenAt: takenAt,
    );
    if (photo == null) {
      return null;
    }

    photos.add(photo);
    _sort();
    revision.value++;
    return photo;
  }

  static Future<void> remove(ProgressPhoto photo) async {
    final repository = _repository;
    final userId = _userId;
    if (repository == null || userId == null) {
      return;
    }

    photos.removeWhere((item) => item.id == photo.id);
    await repository.remove(userId: userId, id: photo.id);
    revision.value++;
  }

  static void _sort() => photos.sort((a, b) => a.takenAt.compareTo(b.takenAt));
}
