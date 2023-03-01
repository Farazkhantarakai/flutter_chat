import 'package:flutter/material.dart';

//this is for creating a part of the widgets
const inputDecoration = InputDecoration(
  hintStyle: TextStyle(color: Colors.black),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFee7b64),
      width: 2,
    ),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFee7b64), width: 2),
  ),
);

void nextScreen(ctx, page) {
  Navigator.of(ctx).push(MaterialPageRoute(builder: (ctx) => page));
}

nextScreenPush(ctx, page, [arg]) {
  return Navigator.of(ctx).pushReplacement(page);
}

void showSnackBar(BuildContext context, color, message) {
  SnackBar snackBar = SnackBar(
    content: Text(message),
    backgroundColor: color,
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {
        const Duration(seconds: 1);
      },
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showYourDialog(BuildContext ctx, title, message) {
  showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message.toString()),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          ));
}
