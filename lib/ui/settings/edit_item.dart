import 'package:flutter/material.dart';

class EditItem extends StatelessWidget {
  const EditItem({super.key, required this.widget, required this.title});
  final Widget widget;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: const Color.fromARGB(255, 107, 106, 106),
            ),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(flex: 5, child: widget),
      ],
    );
  }
}
