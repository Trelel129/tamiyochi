import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/page/movie_edit_page.dart';

import '../services/firestore.dart';

class NoteDetailPage extends StatefulWidget {
  final String noteId;

  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  Movie? note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshNote();
  }

  Future<void> refreshNote() async {
    setState(() => isLoading = true);
    try {
      note = await FirestoreService().readMovie(widget.noteId);
    } catch (e) {
      // Handle error
      print(e);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [editButton(), deleteButton()],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : note == null
        ? const Center(
        child: Text('No note found', style: TextStyle(color: Colors.white)))
        : Padding(
      padding: const EdgeInsets.all(12),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Text(
            note!.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DateFormat.yMMMd().format(note!.createdTime),
            style: const TextStyle(color: Colors.white38),
          ),
          const SizedBox(height: 8),
          Image.network(
            note!.image,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.broken_image,
                color: Colors.grey.shade700,
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            note!.description,
            style: const TextStyle(color: Colors.white70, fontSize: 18),
          )
        ],
      ),
    ),
  );

  Widget editButton() => IconButton(
    icon: const Icon(Icons.edit_outlined),
    onPressed: () async {
      if (isLoading) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note!),
        ),
      );

      refreshNote();
    },
  );

  Widget deleteButton() => IconButton(
    icon: const Icon(Icons.delete),
    onPressed: () async {
      await FirestoreService().deleteMovie(widget.noteId);
      Navigator.of(context).pop();
    },
  );
}
