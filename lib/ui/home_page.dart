import 'package:flutter/material.dart';
import 'package:qaragim/ui/my_profile/my_profile_screen.dart';
import 'package:qaragim/ui/settings/settings_screen.dart';
import 'package:qaragim/ui/novel_page.dart';

class HomeOverlay extends StatefulWidget {
  const HomeOverlay({super.key});

  @override
  State<HomeOverlay> createState() => _HomeOverlayState();
}

class _HomeOverlayState extends State<HomeOverlay> {
  final TextEditingController _searchController = TextEditingController();
  String query = '';

  final List<Map<String, String>> novels = [
    {
      'title': 'Күн астындағы күнекей қыз',
      'cover': 'assets/images/cover1.png',
      'folder': 'novel1',
    },
    {
      'title': 'Қошқар мен теке',
      'cover': 'assets/images/cover2.png',
      'folder': 'novel2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = novels
        .where((n) => n['title']!.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Material(
      color: Color.fromRGBO(148, 199, 180, 1),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
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
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final novel = filtered[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NovelPage(novelFolder: novel['folder']!),
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
                              borderRadius: BorderRadiusGeometry.circular(8),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    novel['title']!,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: Color.fromRGBO(48, 37, 62, 1),
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
                            builder: (context) => MyProfileScreen(),
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
                            builder: (context) => MyProfileScreen(),
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
