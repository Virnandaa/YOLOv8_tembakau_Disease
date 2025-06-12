import 'package:flutter/material.dart';
import 'dart:io';
import '../models/scan_result.dart';
import '../services/storage_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanResult> scanResults = [];

  @override
  void initState() {
    super.initState();
    _loadScanResults();
  }

  void _loadScanResults() {
    setState(() {
      scanResults = StorageService.getAllScanResults();
    });
  }

  void _deleteScanResult(String id) async {
    await StorageService.deleteScanResult(id);
    _loadScanResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Clear All History'),
                      content: const Text(
                        'Are you sure you want to clear all scan history?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            await StorageService.clearAllScanResults();
                            _loadScanResults();
                            Navigator.pop(context);
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadScanResults();
        },
        child:
            scanResults.isEmpty
                ? SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No scan history yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : ListView.builder(
                  itemCount: scanResults.length,
                  itemBuilder: (context, index) {
                    final scanResult = scanResults[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading:
                            scanResult.resultImagePath != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    File(scanResult.resultImagePath!),
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                                : const Icon(Icons.image_not_supported),
                        title: Text(
                          scanResult.detections.isNotEmpty
                              ? scanResult.detections
                                  .map((d) => d.className)
                                  .toSet()
                                  .join(', ')
                              : 'No detections',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: ${scanResult.timestamp.toString().split('.')[0]}',
                            ),
                            if (scanResult.detections.isNotEmpty)
                              Text(
                                'Confidence: ${scanResult.detections.first.confidence.toStringAsFixed(2)}%',
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteScanResult(scanResult.id),
                        ),
                        onTap: () {
                          _showScanDetails(scanResult);
                        },
                      ),
                    );
                  },
                ),
      ),
    );
  }

  void _showScanDetails(ScanResult scanResult) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Details',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (scanResult.resultImagePath != null)
                    Center(
                      child: Image.file(
                        File(scanResult.resultImagePath!),
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text('Date: ${scanResult.timestamp}'),
                  const SizedBox(height: 8),
                  const Text(
                    'Detections:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...scanResult.detections.map(
                    (detection) => Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        '• ${detection.className} (${detection.confidence.toStringAsFixed(2)}%)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
