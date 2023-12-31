// import 'dart:async';

// import 'package:myfirstapp/extensions/lists/filter.dart';
// import 'package:myfirstapp/services/crud/crud_exceptions.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseUser {
//   final int id;
//   final String email;

//   DatabaseUser({
//     required this.id,
//     required this.email,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;

//   @override
//   String toString() => 'Person, Id=$id,email=$email';
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseNote {
//   final int id;
//   final int userId;
//   final String text;
//   final bool isSyncedWithCloud;

//   DatabaseNote({
//     required this.id,
//     required this.userId,
//     required this.text,
//     required this.isSyncedWithCloud,
//   });

//   DatabaseNote.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         userId = map[userIdColumn] as int,
//         text = map[textColumn] as String,
//         isSyncedWithCloud =
//             (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Note, Id=$id,User Id=$userId, Is Synced with Cloud=$isSyncedWithCloud, Text:$text';
//   @override
//   bool operator ==(covariant DatabaseNote other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class NoteService {
//   //database and local cache for notes
//   Database? _db;
//   DatabaseUser? _user;
//   List<DatabaseNote> _notes = [];

//   //Singleton instance for NoteService()
//   static final _shared = NoteService._sharedInstance();
//   NoteService._sharedInstance() {
//     _noteStreamController = StreamController<List<DatabaseNote>>.broadcast(
//       onListen: () {
//         _noteStreamController.sink.add(_notes);
//       },
//     );
//   }
//   factory NoteService() => _shared;

//   //Stream and StreamController to manipulate the stream
//   late final StreamController<List<DatabaseNote>> _noteStreamController;

//   Stream<List<DatabaseNote>> get allNotes =>
//       _noteStreamController.stream.filter((note) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return note.userId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });

//   //All the functions of NoteService
//   Future<void> _cacheNotes() async {
//     final allNotes = await getAllNotes();
//     _notes = allNotes.toList();
//     _noteStreamController.add(_notes);
//   }

//   Future<void> open() async {
//     if (_db != null) throw DatabaseAlreadyOpenException();
//     try {
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       db.execute(createUserTable);
//       db.execute(createNoteTable);
//       _cacheNotes();
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetPlatformDirectoryException();
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseNotOpenException();
//     } else {
//       return db;
//     }
//   }

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     bool setUserAsActive = true,
//   }) async {
//     try {
//       final user = await getUser(email: email);
//       if (setUserAsActive) {
//         _user = user;
//       }
//       return user;
//     } on CouldNotFindUserException {
//       final newUser = await createUser(email: email);
//       if (setUserAsActive) {
//         _user = newUser;
//       }
//       return newUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<DatabaseUser> createUser({required String email}) async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email=?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result.isNotEmpty) throw UserAlreadyExistsException();
//     final userId = await db.insert(userTable, {
//       emailColumn: email.toLowerCase(),
//     });

//     return DatabaseUser(id: userId, email: email);
//   }

//   Future<void> deleteUser({required String email}) async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email=?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result.isEmpty) throw CouldNotFindUserException();
//     final deleteCount = await db.delete(userTable,
//         where: 'email = ?', whereArgs: [email.toLowerCase()]);
//     if (deleteCount != 1) throw CouldNotDeleteUserException();
//   }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (result.isEmpty) {
//       throw CouldNotFindUserException();
//     } else {
//       return DatabaseUser.fromRow(result.first);
//     }
//   }

//   Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     final user = await getUser(email: owner.email);
//     if (user != owner) {
//       CouldNotFindUserException();
//     }
//     const text = '';
//     final noteId = await db.insert(noteTable, {
//       userIdColumn: owner.id,
//       textColumn: text,
//       isSyncedWithCloudColumn: 1,
//     });
//     final note = DatabaseNote(
//       id: noteId,
//       userId: owner.id,
//       text: text,
//       isSyncedWithCloud: true,
//     );
//     _notes.add(note);
//     _noteStreamController.add(_notes);
//     return note;
//   }

//   Future<void> deleteNote({required int id}) async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id=?',
//       whereArgs: [id],
//     );
//     if (result.isEmpty) throw CouldNotFindNoteException();
//     final deleteCount = await db.delete(
//       noteTable,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (deleteCount != 1) {
//       throw CouldNotDeleteNoteException();
//     } else {
//       _notes.removeWhere((note) => note.id == id);
//       _noteStreamController.add(_notes);
//     }
//   }

//   Future<int> deleteAllNotes() async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     int deleteCounter = await db.delete(noteTable);
//     _notes = [];
//     _noteStreamController.add(_notes);
//     return deleteCounter;
//   }

//   Future<DatabaseNote> getNote({required int id}) async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       noteTable,
//       limit: 1,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//     if (result.isEmpty) {
//       throw CouldNotFindNoteException();
//     } else {
//       final note = DatabaseNote.fromRow(result.first);
//       _notes.removeWhere((note) => note.id == id);
//       _notes.add(note);
//       _noteStreamController.add(_notes);
//       return note;
//     }
//   }

//   Future<Iterable<DatabaseNote>> getAllNotes() async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     final notes = await db.query(noteTable);
//     return notes.map((noterow) => DatabaseNote.fromRow(noterow));
//   }

//   Future<DatabaseNote> updateNote(
//       {required DatabaseNote note, required String text}) async {
//     await _ensureDbIsOpened();
//     final db = _getDatabaseOrThrow();
//     await getNote(id: note.id);
//     final updateCount = await db.update(
//         noteTable,
//         {
//           textColumn: text,
//           isSyncedWithCloudColumn: 0,
//         },
//         where: 'id=?',
//         whereArgs: [note.id]);
//     if (updateCount == 0) {
//       throw CouldNotUpdateNoteException();
//     } else {
//       final updatedNote = await getNote(id: note.id);
//       _notes.removeWhere((note) => note.id == updatedNote.id);
//       _notes.add(updatedNote);
//       _noteStreamController.add(_notes);
//       return updatedNote;
//     }
//   }

//   Future<void> _ensureDbIsOpened() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       //do nothing
//     }
//   }
// }

// const dbName = 'notes.db';
// const noteTable = 'note';
// const userTable = 'user';
// const idColumn = 'id';
// const emailColumn = 'email';
// const userIdColumn = 'user_id';
// const textColumn = 'text';
// const isSyncedWithCloudColumn = 'is_synced_with_cloud';
// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//         "id"	INTEGER NOT NULL,
//         "email"	TEXT NOT NULL UNIQUE,
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
// const createNoteTable = '''CREATE TABLE IF NOT EXISTS "note" (
//         "id"	INTEGER NOT NULL,
//         "user_id"	INTEGER NOT NULL,
//         "text"	TEXT,
//         "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
//         FOREIGN KEY("user_id") REFERENCES "user"("id"),
//         PRIMARY KEY("id" AUTOINCREMENT)
//       );''';
