import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewNotes extends StatefulWidget {
  const NewNotes({super.key});

  @override
  State<NewNotes> createState() => _NewNotesState();
}

class _NewNotesState extends State<NewNotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Notes'),
        backgroundColor: Colors.deepPurple[200],
      ),
    );
  }
}
