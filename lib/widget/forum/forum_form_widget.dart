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
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTitle(),
              const SizedBox(height: 8),
              buildImage(),
              const SizedBox(height: 8),
              buildDescription(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );

  Widget buildTitle() => TextFormField(
        maxLines: 1,
        initialValue: title,
        style: const TextStyle(
          color: Colors.black38,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Title',
          hintStyle: TextStyle(color: Colors.black38),
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'The title cannot be empty' : null,
        onChanged: onChangedTitle,
      );

  Widget buildImage() => TextFormField(
        maxLines: 2,
        initialValue: image,
        style: const TextStyle(color: Colors.black38, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter Image Here',
          hintStyle: TextStyle(color: Colors.black38),
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'The Image cannot be empty' : null,
        onChanged: onChangedImage,
      );

  Widget buildDescription() => TextFormField(
        maxLines: 5,
        initialValue: text,
        style: const TextStyle(color: Colors.black38, fontSize: 18),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter Text Here',
          hintStyle: TextStyle(color: Colors.black38),
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'The text cannot be empty' : null,
        onChanged: onChangedText,
      );
}
