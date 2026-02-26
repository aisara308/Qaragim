import 'package:flutter/material.dart';

class MyTitlesTab extends StatelessWidget {
  const MyTitlesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(128, 185, 177, 1),
      child: const Center(
        child: Text(
          "Мои атақтар",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromRGBO(48, 37, 62, 1),
          ),
        ),
      ),
    );
  }
}