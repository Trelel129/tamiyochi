import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tamiyochi/db/movies_database.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/page/forum/forum_edit_page.dart';
import 'package:tamiyochi/page/movie_detail_page.dart';
import 'package:tamiyochi/widget/movie_card_widget.dart';

class ForumPage extends StatefulWidget {
  const ForumPage({super.key});

  @override
  State<ForumPage> createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  late List<Movie> notes;
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();

    refreshNotes();
  }

  @override
  void dispose() {
    MovieDatabase.instance.close();

    super.dispose();
  }

  Future refreshNotes() async {
    setState(() => isLoading = true);

    notes = await MovieDatabase.instance.readAllMovie();

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        "Forums",
        style: TextStyle(fontSize: 24, color: Colors.black),

      ),
      actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : notes.isEmpty
          ? const Text(
        'No Books',
        style: TextStyle(color: Colors.black, fontSize: 24),
      )
          : buildNotes(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.white38,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditForumPage()),
        );

        refreshNotes();
      },
    ),
  );
  Widget buildNotes() => StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      children: List.generate(
        notes.length,
            (index) {
          final note = notes[index];

          return StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NoteDetailPage(noteId: note.id!),
                ));

                refreshNotes();
              },
              child: NoteCardWidget(note: note, index: index),
            ),
          );
        },
      ));
}