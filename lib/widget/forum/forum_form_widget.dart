import 'package:flutter/material.dart';

class ForumFormWidget extends StatelessWidget {
  final String? image;
  final String? title;
  final String? text;
  final ValueChanged<String> onChangedImage;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedText;

  const ForumFormWidget({
    Key? key,
    this.image = '',
    this.title = '',
    this.text = '',
    required this.onChangedImage,
    required this.onChangedTitle,
    required this.onChangedText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Title',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 1,
                initialValue: title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Enter Title Here',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: onChangedTitle,
              ),
              const SizedBox(height: 16),
              Text(
                'Image URL (optional)',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 2,
                initialValue: image,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Enter Image URL Here',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: onChangedImage,
              ),
              const SizedBox(height: 16),
              Text(
                'Text',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 5,
                initialValue: text,
                style: const TextStyle(color: Colors.black87, fontSize: 16),
                decoration: const InputDecoration(
                  hintText: 'Enter Text Here',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                onChanged: onChangedText,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
}
