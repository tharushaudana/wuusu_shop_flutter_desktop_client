import 'package:flutter/material.dart';

class Alert {
  static show(String title, String msg, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static showConfirm(
      String title, String msg, BuildContext context, onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DialogConfirm(
          title: title,
          msg: msg,
          onConfirm: onConfirm,
        );
      },
    );
  }
}

class DialogConfirm extends StatefulWidget {
  final String title;
  final String msg;
  final onConfirm;

  DialogConfirm(
      {required this.title, required this.msg, required this.onConfirm});

  @override
  State<StatefulWidget> createState() => _DialogConfirmState();
}

class _DialogConfirmState extends State<DialogConfirm> {
  bool isShowProgressIndicator = false;

  showProgressIndicator(bool show) {
    setState(() {
      isShowProgressIndicator = show;
    });
  }

  close() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: isShowProgressIndicator
          ? Row(
              children: [
                Spacer(),
                CircularProgressIndicator(),
                Spacer(),
              ],
            )
          : Text(widget.msg),
      actions: [
        TextButton(
          child: Text(
            "CONFIRM",
            style: TextStyle(color: Colors.red),
          ),
          onPressed: isShowProgressIndicator
              ? null
              : () {
                  widget.onConfirm(this);
                },
        ),
        TextButton(
          child: Text(
            "CANCEL",
          ),
          onPressed: isShowProgressIndicator
              ? null
              : () {
                  close();
                },
        ),
      ],
    );
  }
}
