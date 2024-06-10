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
      'email': forum.email,
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

  Future<void> deleteForum(String forumID) {
    return forums.doc(forumID).delete();
  }

  Future<void> deleteComment(String forumId, String commentId) {
    return forums.doc(forumId).collection('comments').doc(commentId).delete();
  }

  Future<void> updateComment(
      String forumId, String commentId, String opt, String text) {
    return forums.doc(forumId).collection('comments').doc(commentId).update({
      opt: text,
    });
  }

  Future<void> addReply(String forumId, String commentId, String replyId,
      String text, String user) {
    return forums
        .doc(forumId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId)
        .set({
      'text': text,
      'user': user,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateReply(String forumId, String commentId, String replyId,
      String opt, String newText) {
    return forums
        .doc(forumId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId)
        .update({
      opt: newText,
    });
  }

  Future<void> deleteReply(String forumId, String commentId, String replyId) {
    return forums
        .doc(forumId)
        .collection('comments')
        .doc(commentId)
        .collection('replies')
        .doc(replyId)
        .delete();
  }
}
