import 'package:flutter/material.dart';
import 'package:myfirstapp/utilities/dialogs/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) async {
  return await showGenericDialog<bool>(
    context: context,
    title: 'Sign Out?',
    content: 'Are you sure you want Log out?',
    optionsBuilder: () => {
      'No': false,
      'SignOut': true,
    },
  ).then((value) => value ?? false);
}
