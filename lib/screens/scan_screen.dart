import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/yolo_service.dart';
import '../utils/detection_painter.dart';
import '../utils/detection_utils.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({Key? key}) : super(key: key);

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  XFile? _capturedImage;
  bool _isReady = false;
  bool _isProcessing = false;
  late YOLOService _yoloService;
  List<Map<String, dynamic>> _outputs = [];
  String diseaseResult = '-';
  double confidenceResult = 0.0;
  Size? _originalImageSize;

  @override
  void initState() {
    super.initState();
    _yoloService = YOLOService();
    _initializeServices();
    _initializeCamera();
  }

  Future<void> _initializeServices() async {
    await _yoloService.initialize();
    setState(() => _isReady = true);
  }

  void _resetCameraPreview() {
    setState(() {
      _capturedImage = null;
      _outputs = [];
      diseaseResult = '-';
      confidenceResult = 0.0;
    });
  }

  String get _buttonText {
    if (_capturedImage != null) return 'Back to Camera';
    return _isProcessing ? 'Processing...' : 'Capture and Predict';
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    setState(() {
      _isCameraInitialized = true;
    });
  }

  Future<void> _captureAndPredict() async {
    if (_capturedImage != null) {
      _resetCameraPreview();
      return;
    }

    if (_isProcessing || !_isCameraInitialized) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Capture image
      final image = await _cameraController!.takePicture();
      setState(() => _capturedImage = image);

      // 2. Process image and get detections
      final result = await _yoloService.detectObjects(image.path);

      setState(() {
        _outputs = result.detections;
        _originalImageSize = result.imageSize;
        _isProcessing = false;

        // Update results display
        final bestDetection = DetectionUtils.getHighestConfidenceDetection(
          _outputs,
          _yoloService.confidenceThreshold,
        );
        if (bestDetection != null) {
          diseaseResult = _yoloService.labels[bestDetection['classId']];
          confidenceResult = (bestDetection['confidence'] * 100);
        }
      });
    } catch (e) {
      print('Error during capture: $e');
      setState(() => _isProcessing = false);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _yoloService.dispose();
    super.dispose();
  }

  Widget _renderDetectionResults() {
    if (_capturedImage == null || _originalImageSize == null)
      return Container();

    return DetectionPainter.renderBoxes(
      context: context,
      imageSize: _originalImageSize!,
      detections: _outputs,
      labels: _yoloService.labels,
      confidenceThreshold: _yoloService.confidenceThreshold,
      detectAll: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Camera')),
      body: Column(
        children: [
          Expanded(
            child:
                _isCameraInitialized && _isReady
                    ? Stack(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child:
                              _capturedImage == null
                                  ? CameraPreview(_cameraController!)
                                  : Center(
                                    child: Image.file(
                                      File(_capturedImage!.path),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                        ),
                        if (_capturedImage != null)
                          Positioned.fill(
                            child: Image.file(
                              File(_capturedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        _renderDetectionResults(),
                      ],
                    )
                    : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _isCameraInitialized ? _captureAndPredict : null,
              child:
                  _isProcessing
                      ? SizedBox(
                        height: 24,
                        width: 24,
                        child: const CircularProgressIndicator(),
                      )
                      : Text(_buttonText),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prediction Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Disease: $diseaseResult'),
                Text('Confidence: ${confidenceResult.toStringAsFixed(2)}%'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
