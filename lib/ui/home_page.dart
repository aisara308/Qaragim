import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/admin/add_novel_screen.dart';
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
  late String email;
  bool isAdmin = false;
  @override
  void initState() {
    super.initState();
    api = ApiClient();
    loadTokenFromPrefs();
    fetchNovels();
  }

  Future<void> loadTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final tokenFromPrefs = prefs.getString('token');
    if (tokenFromPrefs != null && tokenFromPrefs.isNotEmpty) {
      Map<String, dynamic> decoded = JwtDecoder.decode(tokenFromPrefs);
      email = decoded['email'];
      if (email == "zhapashaisara@gmail.com") {
        setState(() {
          isAdmin = true;
        });
      }
    }
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

  Future<void> addNovelToUser(String title, String cover, String slug) async {
    try {
      final responce = await api.post(addUserNovel, context, {
        'title': title,
        'cover': cover,
        'slug': slug,
      });

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
    List<dynamic> sortedNovels = [...novels];
    sortedNovels.sort((a, b) {
      final aFinished = (a['progress']?['finished'] ?? false) as bool;
      return aFinished ? 1 : -1;
    });

    final filtered = sortedNovels
        .where(
          (n) => n['title']!.toString().toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    if (widget.mode == NovelMode.user) {
      return Scaffold(
        body: Material(
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
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isAdmin)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(
                                          99,
                                          136,
                                          114,
                                          1,
                                        ),
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddNovelEditorScreen(),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Новелла қосу",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromRGBO(
                                                255,
                                                255,
                                                255,
                                                1,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            size: 24.0,
                                            Icons.add,
                                            color: Color.fromRGBO(
                                              255,
                                              255,
                                              255,
                                              1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final novel = filtered[index];
                                    final novelProgress =
                                        novel['progress'] ??
                                        {
                                          'sceneIndex': 0,
                                          'dialogueIndex': 0,
                                          'finished': false,
                                        };

                                    final isFinished =
                                        novelProgress?['finished'] ?? false;
                                    return GestureDetector(
                                      onTap: () async {
                                        if (isFinished) {
                                          final response = await api.post(
                                            resetNovelProgressUrl,
                                            context,
                                            {'slug': novel['slug']},
                                          );

                                          if (response.statusCode == 200) {
                                            fetchNovels();
                                          }
                                        }

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => NovelPage(
                                              novelSlug: novel['slug'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                            128,
                                            185,
                                            177,
                                            1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        padding: const EdgeInsets.all(
                                          12,
                                        ), // добавляем паддинг
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: SizedBox(
                                                    width: 150,
                                                    height: 190,
                                                    child: FadeInImage(
                                                      placeholder: AssetImage(
                                                        'assets/placeholders/bg_placeholder.png',
                                                      ),
                                                      image: NetworkImage(
                                                        novel['cover'] ?? '',
                                                      ),
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      imageErrorBuilder:
                                                          (_, __, ___) {
                                                            return Image.asset(
                                                              'assets/placeholders/bg_placeholder.png',
                                                              fit: BoxFit.cover,
                                                              width: double
                                                                  .infinity,
                                                              height: double
                                                                  .infinity,
                                                            );
                                                          },
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        novel['title'] ?? '',
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Color.fromRGBO(
                                                            48,
                                                            37,
                                                            62,
                                                            1,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 6),
                                                      Text(
                                                        novel['description'] ??
                                                            '',
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black54,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 10,
                                                      ),
                                                      if (novel['tags'] !=
                                                              null &&
                                                          (novel['tags']
                                                                  as List)
                                                              .isNotEmpty)
                                                        Wrap(
                                                          spacing: 6,
                                                          runSpacing: 6,
                                                          children: (novel['tags'] as List).map<Widget>((
                                                            tag,
                                                          ) {
                                                            return Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration:
                                                                  BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                          20,
                                                                        ),
                                                                  ),
                                                              child: Text(
                                                                tag,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        48,
                                                                        37,
                                                                        62,
                                                                        1,
                                                                      ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (isFinished) ...[
                                              const SizedBox(height: 8),
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    final response = await api
                                                        .post(
                                                          resetNovelProgressUrl,
                                                          context,
                                                          {
                                                            'slug':
                                                                novel['slug'],
                                                          },
                                                        );

                                                    if (response.statusCode ==
                                                        200) {
                                                      fetchNovels();

                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              NovelPage(
                                                                novelSlug:
                                                                    novel['slug'],
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromRGBO(
                                                          99,
                                                          136,
                                                          114,
                                                          1,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 8,
                                                        ),
                                                  ),
                                                  child: const Text(
                                                    'Қайта бастау',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
        ),
      );
    } else {
      return Scaffold(
        body: Material(
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
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (isAdmin)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color.fromRGBO(
                                          99,
                                          136,
                                          114,
                                          1,
                                        ),
                                      ),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddNovelEditorScreen(),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Новелла қосу",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color.fromRGBO(
                                                255,
                                                255,
                                                255,
                                                1,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(
                                            size: 24.0,
                                            Icons.add,
                                            color: Color.fromRGBO(
                                              255,
                                              255,
                                              255,
                                              1,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) {
                                    final novel = filtered[index];
                                    return GestureDetector(
                                      onTap: () async {
                                        await addNovelToUser(
                                          novel['title'],
                                          novel['cover'],
                                          novel['slug'],
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => NovelPage(
                                              novelSlug: novel['slug'],
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: const Color.fromRGBO(
                                            128,
                                            185,
                                            177,
                                            1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                          horizontal: 16,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    8,
                                                  ),
                                              child: SizedBox(
                                                width: 150,
                                                height: 190,
                                                child: FadeInImage(
                                                  placeholder: AssetImage(
                                                    'assets/placeholders/bg_placeholder.png',
                                                  ),
                                                  image: NetworkImage(
                                                    novel['cover'] ?? '',
                                                  ),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  imageErrorBuilder: (_, __, ___) {
                                                    return Image.asset(
                                                      'assets/placeholders/bg_placeholder.png',
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                    ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    /// Название
                                                    Text(
                                                      novel['title'] ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromRGBO(
                                                          48,
                                                          37,
                                                          62,
                                                          1,
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 6),

                                                    /// Описание
                                                    Text(
                                                      novel['description'] ??
                                                          '',
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.black54,
                                                      ),
                                                    ),

                                                    const SizedBox(height: 10),

                                                    /// Теги
                                                    if (novel['tags'] != null &&
                                                        (novel['tags'] as List)
                                                            .isNotEmpty)
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 6,
                                                            ),
                                                        child: Wrap(
                                                          spacing: 6,
                                                          runSpacing: 6,
                                                          children: (novel['tags'] as List).map<Widget>((
                                                            tag,
                                                          ) {
                                                            return Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 4,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color:
                                                                    const Color.fromARGB(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      255,
                                                                    ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      20,
                                                                    ),
                                                              ),
                                                              child: Text(
                                                                tag,
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color:
                                                                      Color.fromRGBO(
                                                                        48,
                                                                        37,
                                                                        62,
                                                                        1,
                                                                      ),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
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
        ),
      );
    }
  }
}
