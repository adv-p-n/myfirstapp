import 'package:flutter/material.dart';
import 'package:myfirstapp/utilities/dialogs/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
      context: context,
      title: 'Share',
      content: 'You cannot share an empty note!',
      optionsBuilder: () => {'OK': null});
}
