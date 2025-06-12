import 'package:hive/hive.dart';

part 'detection_result.g.dart';

@HiveType(typeId: 2)
class DetectionItem extends HiveObject {
  @HiveField(0)
  final String className;

  @HiveField(1)
  final double confidence;

  DetectionItem({required this.className, required this.confidence});

  factory DetectionItem.fromJson(Map<String, dynamic> json) {
    return DetectionItem(
      className: json['class_name'],
      confidence: json['confidence'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'class_name': className, 'confidence': confidence};
  }
}

class DetectionResult {
  final List<DetectionItem> detections;
  final String resultImage;

  DetectionResult({required this.detections, required this.resultImage});

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      detections: List<DetectionItem>.from(
        (json['detections'] as List<dynamic>).map(
          (detection) => DetectionItem.fromJson(detection),
        ),
      ),
      resultImage: json['result_image'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'detections': detections, 'result_image': resultImage};
  }
}
