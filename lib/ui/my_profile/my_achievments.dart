import 'package:flutter/material.dart';
import 'package:qaragim/ui/my_profile/my_novels.dart';
import 'package:qaragim/ui/my_profile/my_titles.dart';

class MyAchievments extends StatelessWidget {
  const MyAchievments({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Color.fromRGBO(128, 185, 177, 1),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              height: 50.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: Color.fromRGBO(48, 37, 62, 1),
                    ),
                    child: const Text(
                      "Жетістіктер",
                      style: TextStyle(color: Color.fromRGBO(195, 200, 140, 1)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyNovels()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(195, 200, 140, 1),
                    ),
                    child: const Text(
                      "Новеллалар",
                      style: TextStyle(color: Color.fromRGBO(48, 37, 62, 1)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyTitles()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(195, 200, 140, 1),
                    ),
                    child: const Text(
                      "Атақтар",
                      style: TextStyle(color: Color.fromRGBO(48, 37, 62, 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
