import 'package:hive/hive.dart';

part 'detection.g.dart';

@HiveType(typeId: 0)
class Detection extends HiveObject {
  @HiveField(0)
  final String className;

  @HiveField(1)
  final double confidence;

  @HiveField(2)
  final List<double> bbox;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? imagePath;

  Detection({
    required this.className,
    required this.confidence,
    required this.bbox,
    required this.timestamp,
    this.imagePath,
  });

  factory Detection.fromJson(Map<String, dynamic> json) {
    return Detection(
      className: json['className'] ?? json['class_name'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      bbox: List<double>.from(json['bbox'] ?? []),
      timestamp: DateTime.now(),
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'className': className,
      'confidence': confidence,
      'bbox': bbox,
      'timestamp': timestamp.toIso8601String(),
      'imagePath': imagePath,
    };
  }
}
