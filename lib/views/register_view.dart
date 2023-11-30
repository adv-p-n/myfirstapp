import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;

import 'package:myfirstapp/constants/routes.dart';
import 'package:myfirstapp/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.blueGrey,
      ),
      body: Column(
        children: [
          TextField(
            keyboardType: TextInputType.emailAddress,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: "Enter E-Mail address"),
            controller: _email,
          ),
          TextField(
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration:
                const InputDecoration(hintText: "Enter password address"),
            controller: _password,
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;

              try {
                final userCredential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );

                dev.log(userCredential.toString());
                await FirebaseAuth.instance.currentUser
                    ?.sendEmailVerification();
                if (!mounted) {
                  return;
                }
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on FirebaseAuthException catch (e) {
                if (!mounted) {
                  return;
                }
                if (e.code == 'email-already-in-use') {
                  await showErrorDialog(
                    context,
                    'Email already exists.........',
                  );
                } else if (e.code == 'weak-password') {
                  await showErrorDialog(
                    context,
                    "Password is too weeak.........",
                  );
                } else if (e.code == 'invalid-email') {
                  await showErrorDialog(
                    context,
                    "Enter a vaalid Email...........",
                  );
                } else {
                  await showErrorDialog(
                    context,
                    'Error :${e.code}',
                  );
                }
              } catch (e) {
                if (!mounted) {
                  return;
                }
                await showErrorDialog(
                  context,
                  e.toString(),
                );
              }
            },
            child: const Text(
              "Register",
              selectionColor: Colors.deepOrange,
            ),
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  loginRoute,
                  (route) => false,
                );
              },
              child: const Text('Go back to Login'))
        ],
      ),
    );
  }
}
