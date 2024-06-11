import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../model/movie.dart';

class FirestoreService {
  final CollectionReference notes =
  FirebaseFirestore.instance.collection('books');

  Future<void> addNote(Movie movie) {
    return notes.add({
      'name': movie.name,
      'image': movie.image,
      'description' : movie.description,
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
    });
  }

  Future<void> updateBook(String bookID, String part, String newDetails) {
    debugPrint('bookID: $bookID, part: $part, newDetails: $newDetails');
    final note = notes.doc(bookID).get();
    debugPrint('note: $note');
    return note.then((value) {
      if (value.exists) {
        return notes.doc(bookID).update({
          part : newDetails,
        });
      }
      else {
        return notes.doc(bookID).set({
          part : newDetails,
        });
      }
    });
  }
  Future<void> deleteBook(String bookID) {
    return notes.doc(bookID).delete();
  }
  Future<void> deleteNote(String noteID) {
    return notes.doc(noteID).delete();
  }
}