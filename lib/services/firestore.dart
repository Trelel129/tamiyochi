import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/movie.dart';

class FirestoreService {
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('notes');

  Future<void> addNote(Movie movie) {
    return notes.add({
      'title': movie.title,
      'image': movie.image,
      'description' : movie.description,
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

  Future<void> deleteNote(String noteID) {
    return notes.doc(noteID).delete();
  }
}