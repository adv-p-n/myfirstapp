import 'package:flutter/material.dart';
import 'package:myfirstapp/constants/routes.dart';
import 'package:myfirstapp/services/auth/auth_services.dart';
import 'package:myfirstapp/views/login_view.dart';
import 'package:myfirstapp/views/notes_view.dart';
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified == true) {
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
