import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tamiyochi/model/forum.dart';

class FirestoreForumService {
  final CollectionReference forums =
      FirebaseFirestore.instance.collection('forum');

  Future<void> addForum(Forum forum) {
    return forums.add({
      'title': forum.title,
      'image': forum.image,
      'text': forum.text,
      'time': forum.createdTime
    });
  }

  Future<void> updateForum(Forum forum) {
    return forums.doc(forum.id as String?).update({
      'title': forum.title,
      'image': forum.image,
      'text': forum.text,
      'time': forum.createdTime
    });
  }

  Future<void> updateForumPerPart(
      String forumID, String part, String newDetails) {
    final forum = forums.doc(forumID).get();
    return forum.then((value) {
      if (value.exists) {
        return forums.doc(forumID).update({
          part: newDetails,
        });
      } else {
        return forums.doc(forumID).set({
          part: newDetails,
        });
      }
    });
  }
}
