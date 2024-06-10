import 'package:flutter/material.dart';
import 'package:tamiyochi/model/forum.dart';
import 'package:tamiyochi/services/forum/firestore_forum.dart';
import '../../widget/forum/forum_form_widget.dart';

class AddEditForumPage extends StatefulWidget {
  final Forum? forum;

  const AddEditForumPage({
    super.key,
    this.forum,
  });

  @override
  State<AddEditForumPage> createState() => _AddEditForumPageState();
}

class _AddEditForumPageState extends State<AddEditForumPage> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String image;
  late String text;

  final FirestoreForumService firestoreForumService = FirestoreForumService();

  @override
  void initState() {
    super.initState();

    title = widget.forum?.title ?? '';
    image = widget.forum?.image ?? '';
    text = widget.forum?.text ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [buildButton()],
        ),
        body: Form(
          key: _formKey,
          child: ForumFormWidget(
            title: title,
            image: image,
            text: text,
            onChangedImage: (image) => setState(() => this.image = image),
            onChangedTitle: (title) => setState(() => this.title = title),
            onChangedText: (text) => setState(() => this.text = text),
          ),
        ),
      );

  Widget buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.grey.shade700,
        ),
        onPressed: addOrUpdateForum,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateForum() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.forum != null;

      if (isUpdating) {
        await updateForum();
      } else {
        await addForum();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateForum() async {
    final forum = widget.forum!.copy(
      title: title,
      image: image,
      text: text,
    );

    await firestoreForumService.updateForum(forum);
  }

  Future addForum() async {
    final forum = Forum(
      title: title,
      text: text,
      image: image,
      email: "andika@gmail.com",
      createdTime: DateTime.now(),
    );

    // await MovieDatabase.instance.create(forum);
    await firestoreForumService.addForum(forum);
  }
}
