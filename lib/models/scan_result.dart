import 'package:hive/hive.dart';
import 'package:yolo_app/models/detection_result.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 1)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<DetectionItem> detections;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String? originalImagePath;

  @HiveField(4)
  final String? resultImagePath;

  ScanResult({
    required this.id,
    required this.detections,
    required this.timestamp,
    this.originalImagePath,
    this.resultImagePath,
  });

  factory ScanResult.create({
    required List<DetectionItem> detections,
    String? originalImagePath,
    String? resultImagePath,
  }) {
    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      detections: detections,
      timestamp: DateTime.now(),
      originalImagePath: originalImagePath,
      resultImagePath: resultImagePath,
    );
  }
}
