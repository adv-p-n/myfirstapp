import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfirstapp/constants/routes.dart';
import 'package:myfirstapp/firebase_options.dart';
import 'package:myfirstapp/views/login_view.dart';
import 'package:myfirstapp/views/register_view.dart';
import 'package:myfirstapp/views/verify_email_view.dart';
import 'dart:developer' as dev show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
    routes: {
      loginRoute: (context) => const LoginView(),
      registerRoute: (context) => const RegisterView(),
      notesRoute: (context) => const MyNotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
    },
  ));
}

enum MenuActions { logout }

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              if (user.emailVerified == true) {
                dev.log("Verified User");
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
            return const MyNotesView();
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

class MyNotesView extends StatefulWidget {
  const MyNotesView({super.key});

  @override
  State<MyNotesView> createState() => _MyNotesViewState();
}

class _MyNotesViewState extends State<MyNotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: Colors.grey,
        actions: [
          PopupMenuButton<MenuActions>(onSelected: (value) async {
            switch (value) {
              case MenuActions.logout:
                final userLogOut = await showLogOutDialog(context);
                if (userLogOut) {
                  await FirebaseAuth.instance.signOut();
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
      body: const Text("Hello World"),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text('Are you sure you want to LogOut?'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('SignOut'))
          ],
        );
      }).then((value) => value ?? false);
}
