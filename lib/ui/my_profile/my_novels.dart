import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';

class MyNovelsTab extends StatefulWidget {
  const MyNovelsTab({super.key});

  @override
  State<MyNovelsTab> createState() => MyNovelsTabState();
}

class MyNovelsTabState extends State<MyNovelsTab> {
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
    final url = getUserNovels;

    final response = await api.get(url, context);

    if (response.statusCode == 200) {
      setState(() {
        novels = jsonDecode(response.body);
        isLoading = false;
      });
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
          (n) =>
              n['title'].toString().toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    final width = MediaQuery.of(context).size.width;

    int crossAxisCount = 1;
    if (width > 900)
      crossAxisCount = 3;
    else if (width > 600)
      crossAxisCount = 2;

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 230,
        ),
        itemBuilder: (context, index) {
          final novel = filtered[index];

          final novelProgress =
              novel['progress'] ??
              {'sceneIndex': 0, 'dialogueIndex': 0, 'finished': false};

          final isFinished = novelProgress['finished'] ?? false;

          return Card(
            color: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// LEFT SIDE — COVER + TITLE
                  SizedBox(
                    width: 130,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: Image.network(
                              novel['cover'] ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              novel['title'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(48, 37, 62, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// RIGHT SIDE — TAGS + DESCRIPTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (novel['tags'] != null &&
                            (novel['tags'] as List).isNotEmpty)
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (novel['tags'] as List).map<Widget>((
                              tag,
                            ) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF0F0F0),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyle(fontSize: 12),
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 8),

                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              novel['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),

                        if (isFinished)
                          const Align(
                            alignment: Alignment.bottomRight,
                            child: Icon(
                              Icons.check_circle_outline_outlined,
                              color: Colors.green,
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
    );
  }
}
