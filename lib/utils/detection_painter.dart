import 'package:flutter/material.dart';

import 'detection_utils.dart';

class DetectionPainter {
  static Widget renderBoxes({
    required BuildContext context,
    required Size imageSize,
    required List<Map<String, dynamic>> detections,
    required List<String> labels,
    required double confidenceThreshold,
    bool detectAll = false,
  }) {
    print(
      'Rendering ${detections.length} detections with threshold $confidenceThreshold',
    );

    // If no detections, return an empty container
    List<Map<String, dynamic>> detectionsToRender = [];

    if (detectAll) {
      // Render all detections above the confidence threshold
      detectionsToRender =
          detections.where((detection) {
            return detection['confidence'] > confidenceThreshold;
          }).toList();
    } else {
      // Render only the highest confidence detection above the threshold
      final highestConfidenceDetection =
          DetectionUtils.getHighestConfidenceDetection(
            detections,
            confidenceThreshold,
          );
      if (highestConfidenceDetection != null) {
        detectionsToRender = [highestConfidenceDetection];
      }
    }

    // If no detections to render, return an empty container
    if (detectionsToRender.isEmpty) return Container();

    final displayedSize = MediaQuery.of(context).size;
    final originalWidth = imageSize.width;
    final originalHeight = imageSize.height;

    // Calculate scaling factors to maintain aspect ratio
    final scaleX = displayedSize.width / originalWidth;
    final scaleY = displayedSize.height / originalHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate offset for centering the image in the available space
    final offsetX = (displayedSize.width - originalWidth * scale) / 2;
    final offsetY = (displayedSize.height - originalHeight * scale) / 2;

    // Render each bounding box
    return Stack(
      children:
          detectionsToRender.map((detection) {
            final left =
                offsetX +
                (detection['x'] - detection['w'] / 2) * originalWidth * scale;
            final top =
                offsetY +
                (detection['y'] - detection['h'] / 2) * originalHeight * scale;
            final width = detection['w'] * originalWidth * scale;
            final height = detection['h'] * originalHeight * scale;

            final disease = labels[detection['classId']];
            final confidence = (detection['confidence'] * 100).toStringAsFixed(
              2,
            );

            return Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Text(
                  "$disease $confidence%",
                  style: const TextStyle(
                    color: Colors.red,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
