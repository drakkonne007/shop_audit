

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_audit/global/global_variants.dart';

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

Future<void> customAlertChoice(BuildContext context, String text,Function(bool) answer)
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
            child: const Text('Да'),
            onPressed: () {
              answer.call(true);
              if(Navigator.of(context).canPop()) {
                Navigator.of(context).pushNamedAndRemoveUntil('/report', (route) => false);
              }else{
                Navigator.of(context).pushNamed('/report');
              }
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Нет'),
            onPressed: () {
              answer.call(false);
              if(Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }else{
                Navigator.of(context).pushNamedAndRemoveUntil('/mapScreen', (route) => false);
              }
            },
          ),
        ],
      );
    },
  );
}