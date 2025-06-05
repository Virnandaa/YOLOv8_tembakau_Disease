import 'dart:typed_data';

class DetectionUtils {
  static List<Map<String, dynamic>> postProcessYOLOv8Output(
    Float32List output,
    double confidenceThreshold,
  ) {
    const numClasses = 5; // Total number of classes in the model
    final results = <Map<String, dynamic>>[];

    // Calculate total number of detections based on output size
    final elementsPerDetection =
        5 +
        numClasses; // 4 for bounding box + 1 for confidence + numClasses for class scores
    final totalDetections = output.length ~/ elementsPerDetection;

    for (int i = 0; i < totalDetections; i++) {
      final baseIndex = i * elementsPerDetection;

      final confidence = output[baseIndex + 4];
      if (confidence <= confidenceThreshold)
        continue; // skip low confidence detections

      // Debug output for each detection
      final classId = List.generate(
        numClasses,
        (j) => output[baseIndex + 5 + j],
      ).indexOf(
        List.generate(
          numClasses,
          (j) => output[baseIndex + 5 + j],
        ).reduce((a, b) => a > b ? a : b),
      );

      // Normalize and clamp values between 0 and 1
      results.add({
        'x': output[baseIndex].clamp(0.0, 1.0),
        'y': output[baseIndex + 1].clamp(0.0, 1.0),
        'w': output[baseIndex + 2].clamp(0.0, 1.0),
        'h': output[baseIndex + 3].clamp(0.0, 1.0),
        'confidence': confidence,
        'classId': classId,
      });
    }

    return results;
  }

  static Map<String, dynamic>? getHighestConfidenceDetection(
    List<Map<String, dynamic>> outputs,
    double confidenceThreshold,
  ) {
    if (outputs.isEmpty) return null;

    Map<String, dynamic> highestConfidenceDetection = outputs[0];

    for (final detection in outputs) {
      if (detection['confidence'] > highestConfidenceDetection['confidence']) {
        highestConfidenceDetection = detection;
      }
    }

    return highestConfidenceDetection['confidence'] > confidenceThreshold
        ? highestConfidenceDetection
        : null;
  }
}
