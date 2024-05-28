import 'package:flutter/material.dart';

class NoteFormWidget extends StatelessWidget {
  final bool? isImportant;
  final String? image;
  final String? title;
  final String? description;
  final ValueChanged<bool> onChangedImportant;
  final ValueChanged<String> onChangedImage;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedDescription;

  const NoteFormWidget({
    Key? key,
    this.isImportant = false,
    this.image = '',
    this.title = '',
    this.description = '',
    required this.onChangedImportant,
    required this.onChangedImage,
    required this.onChangedTitle,
    required this.onChangedDescription,
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
      color: Colors.white70,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Title',
      hintStyle: TextStyle(color: Colors.white70),
    ),
    validator: (title) =>
    title != null && title.isEmpty ? 'The title cannot be empty' : null,
    onChanged: onChangedTitle,
  );

  Widget buildImage() => TextFormField(
    maxLines: 2,
    initialValue: image,
    style: const TextStyle(color: Colors.white60, fontSize: 18),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Enter Image Here',
      hintStyle: TextStyle(color: Colors.white60),
    ),
    validator: (title) => title != null && title.isEmpty
        ? 'The Image cannot be empty'
        : null,
    onChanged: onChangedImage,
  );

  Widget buildDescription() => TextFormField(
    maxLines: 5,
    initialValue: description,
    style: const TextStyle(color: Colors.white60, fontSize: 18),
    decoration: const InputDecoration(
      border: InputBorder.none,
      hintText: 'Enter Desc Here',
      hintStyle: TextStyle(color: Colors.white60),
    ),
    validator: (title) => title != null && title.isEmpty
        ? 'The description cannot be empty'
        : null,
    onChanged: onChangedDescription,
  );
}