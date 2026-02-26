import 'package:flutter/material.dart';

class NovelList extends StatelessWidget {
  final List<dynamic> novels;
  final String query;
  final Function(dynamic novel) onTap;

  const NovelList({
    super.key,
    required this.novels,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = novels
        .where((n) =>
            n['title'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final novel = filtered[index];

        return GestureDetector(
          onTap: () => onTap(novel),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromRGBO(128, 185, 177, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    novel['cover'],
                    width: 150,
                    height: 190,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    novel['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(48, 37, 62, 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
