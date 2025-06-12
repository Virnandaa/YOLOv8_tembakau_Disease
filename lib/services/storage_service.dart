import 'package:hive_flutter/hive_flutter.dart';
import '../models/detection.dart';
import '../models/scan_result.dart';
import '../models/detection_result.dart';

class StorageService {
  static const String _scanResultsBoxName = 'scan_results';
  static Box<ScanResult>? _scanResultsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DetectionAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ScanResultAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DetectionItemAdapter());
    }

    // Open boxes
    _scanResultsBox = await Hive.openBox<ScanResult>(_scanResultsBoxName);
  }

  static Future<void> saveScanResult(ScanResult scanResult) async {
    if (_scanResultsBox == null) throw Exception('Storage not initialized');
    await _scanResultsBox!.put(scanResult.id, scanResult);
  }

  static List<ScanResult> getAllScanResults() {
    if (_scanResultsBox == null) throw Exception('Storage not initialized');
    return _scanResultsBox!.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static ScanResult? getScanResult(String id) {
    if (_scanResultsBox == null) throw Exception('Storage not initialized');
    return _scanResultsBox!.get(id);
  }

  static Future<void> deleteScanResult(String id) async {
    if (_scanResultsBox == null) throw Exception('Storage not initialized');
    await _scanResultsBox!.delete(id);
  }

  static Future<void> clearAllScanResults() async {
    if (_scanResultsBox == null) throw Exception('Storage not initialized');
    await _scanResultsBox!.clear();
  }

  static List<ScanResult> getRecentScanResults(int limit) {
    final allResults = getAllScanResults();
    return allResults.take(limit).toList();
  }

  static Future<void> close() async {
    await _scanResultsBox?.close();
  }
}
