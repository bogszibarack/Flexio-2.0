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
