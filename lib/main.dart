import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myfirstapp/firebase_options.dart';
import 'package:myfirstapp/views/login_view.dart';
import 'package:myfirstapp/views/register_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Home Page"),
          backgroundColor: Colors.blue,
        ),
        body: FutureBuilder(
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // switch (snapshot.connectionState) {
            //   case ConnectionState.done:
            //     final user = FirebaseAuth.instance.currentUser;
            //     if (user?.emailVerified ?? false) {
            //       print("You are a verified user");
            //     } else {
            //       return const VerifyEmailView();
            //     }
            //     return const Text('Done.....');
            //   default:
            //     return const Text("Loading...");
            // }
            return const LoginView();
          },
        ));
  }
}

class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text('Please verify Your email'),
      TextButton(
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            await user?.sendEmailVerification();
          },
          child: const Text("Send Verification Email"))
    ]);
  }
}
