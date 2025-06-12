import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key, required this.changeIndex}) : super(key: key);

  final Function(int) changeIndex;
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text('YOLO Scanner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome to YOLO Scanner!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Today is ${now.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SummaryCard(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                changeIndex(1);
              },
              child: const Text('Go to Scan Page'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Scans',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RecentScanTile(
              imagePath: 'assets/images/scan1.jpg',
              labels: ['armyworm'],
              confidence: 87,
            ),
            const SizedBox(height: 8),
            RecentScanTile(
              imagePath: 'assets/images/scan1.jpg',
              labels: ['Mildew'],
              confidence: 92,
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Total Scans: 12'),
            Text('Most Detected Disease: WhiteFly'),
            Text('Last Scan: 1 minute ago'),
          ],
        ),
      ),
    );
  }
}

class RecentScanTile extends StatelessWidget {
  final String imagePath;
  final List<String> labels;
  final int confidence;

  const RecentScanTile({
    Key? key,
    required this.imagePath,
    required this.labels,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text('Disease: ${labels.join(', ')}'),
        subtitle: Text('Confidence: $confidence%'),
      ),
    );
  }
}
