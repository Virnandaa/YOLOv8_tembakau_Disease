import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:yolo_app/models/detection_result.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.8:3000';

  Future<DetectionResult> detectObjects(String imagePath) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/detect'));

      // Add image file to request
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Parse response
        final Map<String, dynamic> data = json.decode(response.body);
        return DetectionResult.fromJson(data);
      } else {
        throw Exception('Failed to detect objects: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error during API request: $e');
    }
  }
}
