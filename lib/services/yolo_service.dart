import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/detection_utils.dart';

class DetectionResult {
  final List<Map<String, dynamic>> detections;
  final Size imageSize;

  DetectionResult(this.detections, this.imageSize);
}

class YOLOService {
  late Interpreter _interpreter;
  late List<String> _labels;
  double confidenceThreshold = 0.5;

  List<String> get labels => _labels;

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/best_float32.tflite',
      );
      _labels = await rootBundle
          .loadString('assets/models/labels.txt')
          .then((s) => s.split('\n'));
    } catch (e) {
      print("Error initializing YOLO Service: $e");
      rethrow;
    }
  }

  Future<DetectionResult> detectObjects(String imagePath) async {
    final inputShape = _interpreter.getInputTensor(0).shape;
    final outputShape = _interpreter.getOutputTensor(0).shape;

    // 1. Read image file
    final imageBytes = await File(imagePath).readAsBytes();
    final inputImage = img.decodeImage(imageBytes)!;

    final originalImageSize = Size(
      inputImage.width.toDouble(),
      inputImage.height.toDouble(),
    );

    // 2. Preprocess image
    final processedImage = img.copyResize(
      inputImage,
      width: inputShape[1],
      height: inputShape[2],
    );
    final inputBuffer = Float32List(
      inputShape[0] * inputShape[1] * inputShape[2] * inputShape[3],
    ); // Prepare input buffer

    // 3. Convert image bytes to model input format (normalized 0-1 range)
    var pixelIndex = 0;
    for (final pixel in processedImage.getBytes()) {
      inputBuffer[pixelIndex++] = pixel / 255.0; // Normalize to [0, 1]
    }

    // 4. Run detection
    final outputBuffer = Float32List(
      outputShape[0] * outputShape[1] * outputShape[2],
    ); // Output buffer with model output shape
    _interpreter.run(inputBuffer.buffer, outputBuffer.buffer);

    // 5. Process detections
    final detections = DetectionUtils.postProcessYOLOv8Output(
      outputBuffer,
      confidenceThreshold,
    );

    return DetectionResult(detections, originalImageSize);
  }

  void dispose() {
    _interpreter.close();
  }
}
