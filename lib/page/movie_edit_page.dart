import 'package:flutter/material.dart';
import 'package:tamiyochi/model/movie.dart';
import 'package:tamiyochi/widget/movie_form_widget.dart';
import 'package:tamiyochi/services/firestore.dart';

class AddEditNotePage extends StatefulWidget {
  final Movie? note;

  const AddEditNotePage({
    Key? key,
    this.note,
  }) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  late bool isImportant;
  late String image;
  late String title;
  late String description;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    isImportant = widget.note?.isImportant ?? false;
    image = widget.note?.image ?? '';
    title = widget.note?.title ?? '';
    description = widget.note?.description ?? '';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      actions: [buildButton()],
    ),
    body: Form(
      key: _formKey,
      child: NoteFormWidget(
        isImportant: isImportant,
        image: image,
        title: title,
        description: description,
        onChangedImportant: (isImportant) =>
            setState(() => this.isImportant = isImportant),
        onChangedImage: (image) => setState(() => this.image = image),
        onChangedTitle: (title) => setState(() => this.title = title),
        onChangedDescription: (description) =>
            setState(() => this.description = description),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = title.isNotEmpty && description.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: isFormValid ? null : Colors.grey.shade700,
        ),
        onPressed: addOrUpdateNote,
        child: const Text('Save'),
      ),
    );
  }

  void addOrUpdateNote() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future<void> updateNote() async {
    final note = widget.note!.copy(
      isImportant: isImportant,
      title: title,
      image: image,
      description: description,
    );

    await firestoreService.updateMovie(note);
  }

  Future<void> addNote() async {
    final note = Movie(id: '',
      title: title,
      isImportant: isImportant,
      description: description,
      image: image,
      createdTime: DateTime.now(),
    );

    await firestoreService.addNote(note);
  }
}
