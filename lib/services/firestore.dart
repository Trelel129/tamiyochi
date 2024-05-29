import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/movie.dart';

class FirestoreService {
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(Movie book) {
    return notes.add({
      'title': book.title,
      'image': book.image,
      'description' : book.description,
      'timestamp': Timestamp.now()
    });
  }

  Stream<QuerySnapshot> getNotesStream() {
    final notesStream =
    notes.orderBy('timestamp', descending: true).snapshots();

    return notesStream;
  }

  Future<void> updateNote(String noteID, String newTitle, String newImage, String newDescription) {
    return notes.doc(noteID).update({
      'title': newTitle,
      'image': newImage,
      'description' : newDescription,
      'timestamp': Timestamp.now(),
    });
  }
  Future<void> updateMovie(Movie movie) async {
    final docMovie = FirebaseFirestore.instance.collection('movies').doc(movie.id);
    await docMovie.update(movie.toJson());
  }
  Future<void> deleteMovie(String id) async {
    final docMovie = FirebaseFirestore.instance.collection('movies').doc(id);
    await docMovie.delete();
  }
  Future<Movie> readMovie(String id) async {
    final doc = await FirebaseFirestore.instance.collection('movies').doc(id).get();
    if (doc.exists) {
      return Movie.fromDocument(doc);
    } else {
      throw Exception('Movie with ID $id not found');
    }
  }
}