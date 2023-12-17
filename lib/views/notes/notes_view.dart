import 'package:flutter/material.dart';
import 'package:myfirstapp/constants/routes.dart';
import 'package:myfirstapp/enum/menu_actions.dart';
import 'package:myfirstapp/services/auth/auth_services.dart';
import 'package:myfirstapp/services/crud/notes_services.dart';
import 'package:myfirstapp/utilities/dialogs/logout_dialog.dart';
import 'package:myfirstapp/views/notes/notes_list_view.dart';

class MyNotesView extends StatefulWidget {
  const MyNotesView({super.key});

  @override
  State<MyNotesView> createState() => _MyNotesViewState();
}

class _MyNotesViewState extends State<MyNotesView> {
  late final NoteService _noteService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _noteService = NoteService();
    super.initState();
  }

  @override
  void dispose() {
    _noteService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.grey,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(createUpdateNoteRoute);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MenuActions>(onSelected: (value) async {
            switch (value) {
              case MenuActions.logout:
                final userLogOut = await showLogOutDialog(context);
                if (userLogOut) {
                  await AuthService.firebase().logOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (route) => false,
                  );
                }
            }
          }, itemBuilder: (context) {
            return const [
              PopupMenuItem<MenuActions>(
                  value: MenuActions.logout, child: Text('Logout'))
            ];
          })
        ],
      ),
      body: FutureBuilder(
        future: _noteService.getOrCreateUser(email: userEmail),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return StreamBuilder(
                  stream: _noteService.allNotes,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        if (snapshot.hasData) {
                          final notes = snapshot.data as List<DatabaseNote>;
                          return NotesListView(
                            notes: notes,
                            onDeleteNote: (note) async {
                              await _noteService.deleteNote(id: note.id);
                            },
                            onTap: (notes) {
                              Navigator.of(context).pushNamed(
                                  createUpdateNoteRoute,
                                  arguments: notes);
                            },
                          );
                        } else {
                          return const CircularProgressIndicator();
                        }
                      default:
                        return const CircularProgressIndicator();
                    }
                  });
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
