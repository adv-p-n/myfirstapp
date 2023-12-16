import 'package:flutter/material.dart';
import 'package:myfirstapp/utilities/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) async {
  return await showGenericDialog<bool>(
    context: context,
    title: 'Delete Note',
    content: 'Are you sure you want to delete the Note?',
    optionsBuilder: () => {
      'Cancel': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}
