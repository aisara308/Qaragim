import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';

class MyAchievementsTab extends StatefulWidget {
  const MyAchievementsTab({super.key});

  @override
  State<MyAchievementsTab> createState() => _MyAchievementsTabState();
}

class _MyAchievementsTabState extends State<MyAchievementsTab> {
  List<dynamic> novels = [];
  List<dynamic> achievements = [];
  String selectedNovelSlug = '';
  bool isLoadingNovels = true;
  bool isLoadingAchievements = false;
  late ApiClient api;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    fetchNovels();
  }

  Future<void> fetchNovels() async {
    setState(() => isLoadingNovels = true);
    try {
      final response = await api.get(getUserNovels, context);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          novels = data;
          isLoadingNovels = false;
          if (novels.isNotEmpty) {
            selectedNovelSlug = novels[0]['slug'];
            fetchAchievements(selectedNovelSlug);
          }
        });
      }
    } catch (e) {
      print('Error fetching novels: $e');
      setState(() => isLoadingNovels = false);
    }
  }

  Future<void> fetchAchievements(String novelSlug) async {
    setState(() => isLoadingAchievements = true);
    try {
      final response = await api.get(myAchievementsRoute, context);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final novelBlock = (data['novels'] as List).firstWhere(
          (n) => n['novelSlug'] == novelSlug,
          orElse: () => {'achievements': []},
        );
        setState(() {
          achievements = novelBlock['achievements'] ?? [];
          isLoadingAchievements = false;
        });
      }
    } catch (e) {
      print('Error fetching achievements: $e');
      setState(() => isLoadingAchievements = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(128, 185, 177, 1),
      padding: const EdgeInsets.all(16),
      child: isLoadingNovels
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Левая колонка: список новелл
                SizedBox(
                  width: 140,
                  child: ListView.builder(
                    itemCount: novels.length,
                    itemBuilder: (context, index) {
                      final novel = novels[index];
                      final isSelected = novel['slug'] == selectedNovelSlug;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedNovelSlug = novel['slug'];
                            fetchAchievements(selectedNovelSlug);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color.fromARGB(255, 138, 138, 138),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  novel['cover'] ?? '',
                                  width: 100,
                                  height: 140,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 100,
                                    height: 140,
                                    color: Colors.grey.shade300,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                novel['title'] ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color.fromRGBO(48, 37, 62, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                // Правая колонка: ачивки выбранной новеллы
                Expanded(
                  child: isLoadingAchievements
                      ? const Center(child: CircularProgressIndicator())
                      : achievements.isEmpty
                      ? const Center(
                          child: Text(
                            "Әлі жетістіктер жоқ",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: achievements.length,
                          itemBuilder: (context, index) {
                            final ach = achievements[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                title: Text(ach['name'] ?? ''),
                                subtitle: Text(ach['description'] ?? ''),
                                leading: const Icon(
                                  Icons.emoji_events,
                                  color: Colors.amber,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
