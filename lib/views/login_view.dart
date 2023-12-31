import 'package:flutter/material.dart';
import 'dart:developer' as dev show log;
import 'package:myfirstapp/constants/routes.dart';
import 'package:myfirstapp/services/auth/auth_exceptions.dart';
import 'package:myfirstapp/services/auth/auth_services.dart';
import 'package:myfirstapp/utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text('Login'),
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
                final userCredential = await AuthService.firebase()
                    .logIn(email: email, password: password);
                dev.log(userCredential.toString());
                final user = AuthService.firebase().currentUser;
                if (!mounted) {
                  return;
                }
                if (user?.isEmailVerified ?? false) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    notesRoute,
                    (route) => false,
                  );
                } else {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    verifyEmailRoute,
                    (route) => false,
                  );
                }
              } on UserNotFoundAuthException {
                await showErrorDialog(
                  context,
                  'User not found.........',
                );
              } on WrongPasswordAuthException {
                await showErrorDialog(
                  context,
                  "Password is incorrect........",
                );
              } on InvalidCredentialsAuthException {
                await showErrorDialog(
                  context,
                  "Invalid Credentials........",
                );
              } on GenericAuthException {
                await showErrorDialog(
                  context,
                  'An Error Occoured: Failed to logIn',
                );
              }
            },
            child: const Text("Login"),
          ),
          TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Not Registered? Register Here!'))
        ],
      ),
    );
  }
}
