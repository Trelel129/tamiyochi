import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tamiyochi/db/movies_database.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/page/movie_edit_page.dart';
import 'package:tamiyochi/page/movie_detail_page.dart';
import 'package:tamiyochi/widget/movie_card_widget.dart';

import '../services/firestore.dart';
import 'book_rent_page.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  late List<Movie> notes;
  bool isLoading = false;
  final user = FirebaseAuth.instance.currentUser!;
  final FirestoreService firestoreService = FirestoreService();

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
          title: Text(
            "All Comics",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          actions: const [Icon(Icons.search), SizedBox(width: 12)],
        ),
        body:StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('books').orderBy('name').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List books = snapshot.data!.docs;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: books.length,
                itemBuilder: (context, index) {
                  //get each individual document
                  final DocumentSnapshot document = books[index];
                  String docId = document.id;

                  //get note from each document
                  Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
                  String bookName = data['name'];
                  String bookImage = data['image'];

                  //display as ListTile
                  return StaggeredGridTile.fit(
                    crossAxisCellCount: 1,
                    child: GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => BookRentPage(bookId: docId),
                          ));
                        },
                        child: SingleChildScrollView(
                          child: Card(
                            color: Colors.lightGreen.shade300,
                            child: Container(
                              constraints: BoxConstraints(minHeight: 200),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bookName,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Image.network(bookImage)
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              );
            }
          },
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