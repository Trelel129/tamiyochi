import 'package:flutter/material.dart';
import 'package:tamiyochi/db/movies_database.dart';
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
  late String name;
  late String image;
  late String description;

  final FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    name = widget.note?.name ?? '';
    image = widget.note?.image ?? '';
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
        name: name,
        image: image,

        description: description,
        onChangedImage: (image) => setState(() => this.image = image),
        onChangedName: (name) => setState(() => this.name = name),
        onChangedDescription: (description) =>
            setState(() => this.description = description),
      ),
    ),
  );

  Widget buildButton() {
    final isFormValid = name.isNotEmpty && description.isNotEmpty;

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

  Future updateNote() async {
    final note = widget.note!.copy(
      name: name,
      image: image,
      description: description,
    );

    await MovieDatabase.instance.update(note);
  }

  Future addNote() async {
    final note = Movie(
      name: name,
      description: description,
      image: image,
      createdTime: DateTime.now(),
    );

    // await MovieDatabase.instance.create(note);
    await firestoreService.addNote(note);
  }
}