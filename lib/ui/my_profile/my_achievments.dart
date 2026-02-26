import 'package:flutter/material.dart';

class MyAchievementsTab extends StatelessWidget {
  const MyAchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(128, 185, 177, 1),
      child: const Center(
        child: Text(
          "Мои жетістіктер",
          style: TextStyle(
            fontSize: 20,
            color: Color.fromRGBO(48, 37, 62, 1),
          ),
        ),
      ),
    );
  }
}