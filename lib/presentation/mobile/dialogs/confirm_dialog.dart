import 'package:flutter/material.dart';

Future<bool?> showConfirmDialog(BuildContext context, {required String title, required String content, required String confirmText, Color? confirmColor}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmText, style: TextStyle(color: confirmColor ?? Colors.blue)),
        ),
      ],
    ),
  );
}
