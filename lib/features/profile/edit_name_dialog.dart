import 'package:flutter/material.dart';

class EditNameDialog extends StatefulWidget {
  final String initial;
  const EditNameDialog({super.key, required this.initial});

  @override
  State<EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<EditNameDialog> {
  late final TextEditingController c;

  @override
  void initState() {
    super.initState();
    c = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit name'),
      content: TextField(
        controller: c,
        decoration: const InputDecoration(
          hintText: 'Full name',
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Save')),
      ],
    );
  }
}