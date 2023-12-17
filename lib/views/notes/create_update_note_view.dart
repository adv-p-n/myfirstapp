import 'package:flutter/material.dart';
import 'package:myfirstapp/services/auth/auth_services.dart';
import 'package:myfirstapp/services/crud/notes_services.dart';
import 'package:myfirstapp/utilities/generics/get_arguments.dart';

class CreateUpdateNotes extends StatefulWidget {
  const CreateUpdateNotes({super.key});

  @override
  State<CreateUpdateNotes> createState() => _CreateUpdateNotesState();
}

class _CreateUpdateNotesState extends State<CreateUpdateNotes> {
  DatabaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _noteService = NoteService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNote> createOrGetExistingNote() async {
    final widgetNote = context.getArgumets<DatabaseNote>();
    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    } else {
      final currentUser = AuthService.firebase().currentUser!;
      final email = currentUser.email!;
      final owner = await _noteService.getUser(email: email);
      final newNote = await _noteService.createNote(owner: owner);
      _note = newNote;
      return newNote;
    }
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _noteService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textController.text;
    if (text.isNotEmpty && note != null) {
      await _noteService.updateNote(
        note: note,
        text: text,
      );
    }
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) return;
    final text = _textController.text;
    await _noteService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Notes'),
        backgroundColor: Colors.deepPurple[200],
      ),
      body: FutureBuilder(
          future: createOrGetExistingNote(),
          builder: (
            BuildContext context,
            AsyncSnapshot snapshot,
          ) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                _setupTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                      hintText: ("Enter Your Notes Here......")),
                );
              default:
                return const CircularProgressIndicator();
            }
          }),
    );
  }
}
