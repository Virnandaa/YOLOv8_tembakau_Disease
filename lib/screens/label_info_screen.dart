import 'package:flutter/material.dart';

class LabelInfoScreen extends StatelessWidget {
  const LabelInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> labels = [
      {'name': 'Mildew', 'description': 'Penyakit jamur yang menyebabkan bercak putih seperti tepung pada daun, menurunkan kualitas daun.'},
      {'name': 'Thysanoptera', 'description': 'Hama serangga kecil yang menghisap cairan daun sehingga muncul bercak putih dan pertumbuhan daun tidak normal.'},
      {'name': 'Whitefly', 'description': 'Serangga kecil berwarna putih yang menghisap cairan daun menyebabkan daun menguning, layu, dan bisa menularkan virus.'},
      {'name': 'Armyworm', 'description': 'Ulat yang memakan daun tembakau meninggalkan lubang besar dan mengurangi hasil panen.'},
      {'name': 'Cercospora nicotianae', 'description': 'Penyakit jamur yang menyebabkan bercak coklat pada daun, daun mengering dan mudah gugur.'}
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Label Information'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: labels.length,
        itemBuilder: (context, index) {
          final label = labels[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(label['name']!),
              subtitle: Text(label['description']!),
            ),
          );
        },
      ),
    );
  }
}
