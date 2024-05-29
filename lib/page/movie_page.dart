import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/page/movie_detail_page.dart';
import 'package:tamiyochi/widget/movie_card_widget.dart';
import 'package:tamiyochi/widget/moving_text.dart';

import 'movie_edit_page.dart';

class MoviePage extends StatefulWidget {
  const MoviePage({Key? key}) : super(key: key);

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  late final CollectionReference _moviesCollection;
  bool _isLoading = false;
  bool _isEmpty = true;
  List<Movie> _movies = [];
  late double _screenWidth;
  late double _screenHeight;
  final User _user = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    _moviesCollection = FirebaseFirestore.instance.collection('movies');
    refreshMovies();
  }

  Future<void> refreshMovies() async {
    setState(() => _isLoading = true);
    final querySnapshot = await _moviesCollection.get();
    final List<Movie> movies = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Movie.fromJson(data as Map<String, dynamic>);
    }).toList();
    setState(() {
      _movies = movies;
      _isEmpty = movies.isEmpty;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: _screenHeight - 100,
          child: ScrollingText(
            text: 'Favorite Movies of ${_user.email}',
            textStyle: TextStyle(fontSize: 20, color: Colors.white),
            speed: 5,
          ),
        ),
        actions: [
          Icon(Icons.search),
          SizedBox(width: 12),
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _isEmpty
            ? Text('No Movies Added Yet',
            style: TextStyle(color: Colors.white, fontSize: 24))
            : buildNotes(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddEditNotePage()),
          );

          refreshMovies();
        },
      ),
    );
  }

  Widget buildNotes() => StaggeredGridView.countBuilder(
    crossAxisCount: 2,
    itemCount: _movies.length,
    itemBuilder: (BuildContext context, int index) {
      final movie = _movies[index];
      return GestureDetector(
        onTap: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NoteDetailPage(noteId: movie.id),
          ));
          refreshMovies();
        },
        child: NoteCardWidget(note: movie, index: index),
      );
    },
    staggeredTileBuilder: (int index) => StaggeredTile.fit(1),
    mainAxisSpacing: 2.0,
    crossAxisSpacing: 2.0,
  );

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}