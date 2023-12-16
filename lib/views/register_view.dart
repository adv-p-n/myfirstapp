import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;
import 'package:myfirstapp/constants/routes.dart';
import 'package:myfirstapp/services/auth/auth_exceptions.dart';
import 'package:myfirstapp/services/auth/auth_services.dart';
import 'package:myfirstapp/utilities/dialogs/error_dialog.dart';

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
                final userCredential = await AuthService.firebase().createUser(
                  email: email,
                  password: password,
                );

                dev.log(userCredential.toString());
                await AuthService.firebase().sendEmailVerification();
                if (!mounted) {
                  return;
                }
                Navigator.of(context).pushNamed(verifyEmailRoute);
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(
                  context,
                  'Email already exists.........',
                );
              } on WeakPasswordAuthException {
                await showErrorDialog(
                  context,
                  "Password is too weeak.........",
                );
              } on InvalidEmailAuthException {
                await showErrorDialog(
                  context,
                  "Enter a vaalid Email...........",
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  "An error Occured: Registration Failed",
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
