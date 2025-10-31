import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class forward_button extends StatelessWidget {
  const forward_button({super.key, required this.onPressed});
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(99, 136, 114, 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          Ionicons.chevron_forward_outline,
          color: const Color.fromRGBO(48, 37, 62, 1),
        ),
      ),
    );
  }
}
