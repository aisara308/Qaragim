import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/ui/novel_page.dart';
import 'package:qaragim/ui/settings/settings_screen.dart';
import 'package:qaragim/ui/my_profile/my_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qaragim/config.dart';

class NovelsPage extends StatefulWidget {
  const NovelsPage({super.key});

  @override
  State<NovelsPage> createState() => _NovelsPageState();
}

class _NovelsPageState extends State<NovelsPage> {
  List<dynamic> novels = [];
  String query = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNovels();
  }

  Future<void> fetchNovels() async {
    try {
      final responce = await http.get(Uri.parse(getNovels));
      if (responce.statusCode == 200) {
        setState(() {
          novels = json.decode(responce.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load novels');
      }
    } catch (e) {
      print('Error fetching novels: $e');
    }
  }

  Future<void> addNovelToUser(String title, String cover, String folder) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final responce = await http.post(
        Uri.parse(addUserNovel),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'title': title, 'cover': cover, 'folder': folder}),
      );

      if (responce.statusCode == 200) {
        print('Novel added to user library!');
      } else {
        print('Failed to add novel: ${responce.body}');
      }
    } catch (e) {
      print('Error adding novel: ${e}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = novels
        .where(
          (n) =>
              n['title'].toString().toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    return Material(
      color: const Color.fromRGBO(148, 199, 180, 1),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromRGBO(255, 255, 255, 1),
                  hintText: "Іздеу",
                  prefixIcon: const Icon(Icons.search),
                ),
                onChanged: (value) => setState(() => query = value),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final novel = filtered[index];
                          return GestureDetector(
                            onTap: () async {
                              await addNovelToUser(
                                novel['title'],
                                novel['cover'],
                                novel['folder'],
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      NovelPage(novelFolder: novel['folder']),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(128, 185, 177, 1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              margin: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      8,
                                    ),
                                    child: Image.asset(
                                      novel['cover']!,
                                      width: 150,
                                      height: 190,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          novel['title']!,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color: Color.fromRGBO(
                                              48,
                                              37,
                                              62,
                                              1,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Color.fromRGBO(99, 136, 114, 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeOverlay(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.book,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      iconSize: 35.0,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SettingsScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.settings,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      iconSize: 35.0,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NovelsPage(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.library_books,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      iconSize: 35.0,
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MyProfileScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.account_circle_sharp,
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      iconSize: 35.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
