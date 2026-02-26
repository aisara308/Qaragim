import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/my_profile/my_profile_screen.dart';
import 'package:qaragim/ui/settings/settings_screen.dart';
import 'package:qaragim/ui/read_novel_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum NovelMode { user, all }

class HomePage extends StatefulWidget {
  final NovelMode mode;

  const HomePage({super.key, required this.mode});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<dynamic> novels = [];
  String query = '';
  bool isLoading = true;
  late ApiClient api;
  @override
  void initState() {
    super.initState();
    api = ApiClient();
    fetchNovels();
  }

  Future<void> fetchNovels() async {
    final url = widget.mode == NovelMode.user ? getUserNovels : getNovels;

    final response = await api.get(url, context);

    if (response.statusCode == 200) {
      setState(() {
        novels = jsonDecode(response.body);
        isLoading = false;
      });
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
          (n) => n['title']!.toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    if (widget.mode == NovelMode.user) {
      return Material(
        color: Color.fromRGBO(148, 199, 180, 1),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromRGBO(255, 255, 255, 0.9),
                    hintText: 'Іздеу',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() => query = value),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : novels.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Сізде әлі новеллалар жоқ...',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromRGBO(48, 37, 62, 1),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const HomePage(mode: NovelMode.all),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromRGBO(
                                    99,
                                    136,
                                    114,
                                    1,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text(
                                  'Новелла таңдауға өту',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final novel = filtered[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NovelPage(
                                      novelFolder: novel['folder']!,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(128, 185, 177, 1),
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
                                      borderRadius:
                                          BorderRadiusGeometry.circular(8),
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
                        onPressed: () {},
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
                              builder: (context) =>
                                  HomePage(mode: NovelMode.all),
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
    } else {
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
                                      borderRadius:
                                          BorderRadiusGeometry.circular(8),
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
                              builder: (context) =>
                                  HomePage(mode: NovelMode.user),
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
                        onPressed: () {},
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
}
