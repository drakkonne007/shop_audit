

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> customAlertMsg(BuildContext context, String text) async
{
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title:  Text(text),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Ок'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}