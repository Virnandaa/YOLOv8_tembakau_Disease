import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:yolo_app/models/detection_result.dart';
import 'package:yolo_app/services/api_service.dart';
import 'package:yolo_app/models/scan_result.dart';
import 'package:yolo_app/services/storage_service.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key, required this.apiService}) : super(key: key);
  final ApiService apiService;

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;

  bool isLoading = false;
  XFile? capturedImage = null;
  XFile? decodedImage = null;
  List<DetectionItem> diseaseResult = [];
  double confidenceResult = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _resetCameraPreview() {
    setState(() {
      capturedImage = null;
      decodedImage = null;
      diseaseResult = [];
      confidenceResult = 0.0;
    });
  }

  String get _buttonText {
    if (decodedImage != null || capturedImage != null) return 'Back to Camera';
    return 'Capture and Predict';
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<XFile?> _decodeBase64Image(String base64String) async {
    try {
      // Decode base64 string
      final bytes = base64Decode(base64String);

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/detected_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      // Write the bytes to the file
      await file.writeAsBytes(bytes);

      // Create XFile from the saved file
      return XFile(file.path);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  Future<void> _captureAndPredict({bool usingCamera = true}) async {
    if (capturedImage != null) {
      _resetCameraPreview();
      return;
    }

    if (isLoading || !_isCameraInitialized) return;

    setState(() {
      isLoading = true;
    });

    try {
      XFile? image;
      if (usingCamera) {
        image = await _cameraController!.takePicture();
      } else {
        image = await ImagePicker().pickImage(source: ImageSource.gallery);
      }

      if (image == null) {
        return;
      }

      setState(() {
        capturedImage = image;
      });

      final result = await widget.apiService.detectObjects(image.path);
      final decodedResultImage = await _decodeBase64Image(result.resultImage);

      // Parse detections
      final detections = result.detections;

      // Save to storage
      final scanResult = ScanResult.create(
        detections: detections,
        originalImagePath: image.path,
        resultImagePath: decodedResultImage?.path,
      );

      await StorageService.saveScanResult(scanResult);

      setState(() {
        diseaseResult = detections;
        if (decodedResultImage != null) {
          decodedImage = decodedResultImage;
        }
        isLoading = false;
      });
    } catch (e) {
      print('Error during capture: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Camera')),
      body: Column(
        children: [
          Expanded(
            child:
                _isCameraInitialized
                    ? Stack(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child:
                              decodedImage != null
                                  ? Image.file(
                                    File(decodedImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                  : capturedImage != null
                                  ? Image.file(
                                    File(capturedImage!.path),
                                    fit: BoxFit.cover,
                                  )
                                  : CameraPreview(_cameraController!),
                        ),
                      ],
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                isLoading
                    ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: const CircularProgressIndicator(),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed:
                              _isCameraInitialized ? _captureAndPredict : null,
                          child: Text(_buttonText),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed:
                              _isCameraInitialized
                                  ? () => _captureAndPredict(usingCamera: false)
                                  : null,
                          child: Icon(Icons.photo_rounded),
                        ),
                      ],
                    ),
          ),
          if (diseaseResult.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prediction Results',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Disease: ${diseaseResult.map((e) => "${e.className} (${e.confidence.toStringAsFixed(2)}%)").join(', ')}',
                  ),
                  if (confidenceResult != 0.0)
                    Text('Confidence: ${confidenceResult.toStringAsFixed(2)}%'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
