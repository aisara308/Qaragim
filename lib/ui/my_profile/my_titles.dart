import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';

class MyTitlesTab extends StatefulWidget {
  const MyTitlesTab({super.key});

  @override
  State<MyTitlesTab> createState() => _MyTitlesTabState();
}

class _MyTitlesTabState extends State<MyTitlesTab> {
  List<dynamic> novels = [];
  List<dynamic> achievements = [];
  bool isLoading = true;
  late ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    fetchNovels();
  }

  Future<void> fetchNovels() async {
    setState(() => isLoading = true);
    try {
      final response = await api.get(getUserNovels, context);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          novels = data;
          fetchAchievements();
        });
      }
    } catch (e) {
      print('Error fetching novels: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchAchievements() async {
    try {
      final response = await api.get(myAchievementsRoute, context);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> allAch = [];
        for (var n in data['novels']) {
          allAch.addAll(n['achievements'] ?? []);
        }
        setState(() {
          achievements = allAch;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching achievements: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> getTitles() {
    final userNovels = novels.length;
    final achievementes = achievements.length;
    final allNovelsHaveAchievements =
        novels.isNotEmpty &&
        novels.every((n) => achievements.any((a) => a['slug'] == n['slug']));

    return [
      {
        'name': 'Бастауыш оқырман',
        'description': 'Кемінде 1 новелла',
        'icon': Icons.book,
        'color': Colors.blue,
        'earned': userNovels >= 1,
      },
      {
        'name': 'Коллекционер',
        'description': 'Кемінде 5 новеллалар',
        'icon': Icons.collections_bookmark,
        'color': Colors.purple,
        'earned': userNovels >= 5,
      },
      {
        'name': 'Кітапханашы',
        'description': 'Кемінде 10 новеллалар',
        'icon': Icons.menu_book,
        'color': Colors.orange,
        'earned': userNovels >= 10,
      },
      {
        'name': 'Дәл оқырман',
        'description': '3 жетістік бар',
        'icon': Icons.check_circle,
        'color': Colors.green,
        'earned': achievementes >= 3,
      },
      {
        'name': 'Барлық жанрлардың шебері',
        'description': 'Әр новелладан кемінде 1 жетістік',
        'icon': Icons.star,
        'color': Colors.red,
        'earned': allNovelsHaveAchievements,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final titles = getTitles();

    return Container(
      color: const Color.fromRGBO(128, 185, 177, 1),
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: titles.length,
        itemBuilder: (context, index) {
          final title = titles[index];
          final earned = title['earned'] as bool;

          return Card(
            color: earned ? Colors.white : Colors.grey[300],
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(
                title['icon'] as IconData,
                color: earned ? title['color'] as Color : Colors.grey,
                size: 36,
              ),
              title: Text(
                title['name'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: earned ? Colors.black : Colors.grey[600],
                ),
              ),
              subtitle: Text(
                title['description'] as String,
                style: TextStyle(
                  color: earned ? Colors.black54 : Colors.grey[600],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
