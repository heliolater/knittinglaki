import 'package:flutter/material.dart';

/// Shows a single-text-field dialog and returns the trimmed input, or `null`
/// if the user cancelled or left it empty.
Future<String?> showNameDialog(
  BuildContext context, {
  required String title,
  String confirmLabel = 'Speichern',
  String? initialValue,
  String hintText = 'Name',
}) {
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: hintText),
          onSubmitted: (_) => _submit(context, controller),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => _submit(context, controller),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
}

void _submit(BuildContext context, TextEditingController controller) {
  final value = controller.text.trim();
  Navigator.pop(context, value.isEmpty ? null : value);
}
