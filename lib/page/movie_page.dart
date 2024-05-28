import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:film_management/db/movies_database.dart';
import 'package:film_management/model/movie.dart';
import 'package:film_management/page/movie_edit_page.dart';
import 'package:film_management/page/movie_detail_page.dart';
import 'package:film_management/widget/movie_card_widget.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  late List<Movie> notes;
  bool isLoading = false;

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
        'Favorite Movie',
        style: TextStyle(fontSize: 24),
      ),
      actions: const [Icon(Icons.search), SizedBox(width: 12)],
    ),
    body: Center(
      child: isLoading
          ? const CircularProgressIndicator()
          : notes.isEmpty
          ? const Text(
        'No Notes',
        style: TextStyle(color: Colors.white, fontSize: 24),
      )
          : buildNotes(),
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.black,
      child: const Icon(Icons.add),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditNotePage()),
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