import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/movie.dart'; // Adjust the import as necessary

final _lightColors = [
  Colors.amber.shade300,
  Colors.lightGreen.shade300,
  Colors.lightBlue.shade300,
  Colors.orange.shade300,
  Colors.pinkAccent.shade100,
  Colors.tealAccent.shade100
];

class NoteCardWidget extends StatelessWidget {
  const NoteCardWidget({
    Key? key,
    required this.note,
    required this.index,
  }) : super(key: key);

  final Movie note;
  final String index;

  @override
  Widget build(BuildContext context) {
    // Pick colors from the accent colors based on index
    final color = _lightColors[int.parse(index) % _lightColors.length];
    final time = DateFormat.yMMMd().format(note.createdTime);
    final minHeight = getMinHeight();

    return Card(
      color: color,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              time,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 4),
            Text(
              note.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8), // Added some space between text and image
            if (note.image.isNotEmpty)
              Image.network(
                note.image,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.broken_image,
                    color: Colors.grey.shade700,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  // To return different height for different widgets
  double getMinHeight() {
    return 200;
  }
}