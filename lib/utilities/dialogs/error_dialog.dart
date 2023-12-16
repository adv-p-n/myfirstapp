import 'package:flutter/material.dart';
import 'package:myfirstapp/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String content) {
  return showGenericDialog<void>(
    context: context,
    title: 'An Error Occoured',
    content: content,
    optionsBuilder: () => {'OK': null},
  );
}
