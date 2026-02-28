import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';

class NovelPage extends StatefulWidget {
  final String novelSlug;
  const NovelPage({super.key, required this.novelSlug});

  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  List scenes = [];
  int sceneIndex = 0;
  int dialogueIndex = 0;
  late ApiClient api;

  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    loadScript();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  Future<void> loadScript() async {
    final response = await api.get("$getScript${widget.novelSlug}", context);

    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);
      await loadProgress();
      setState(() {
        scenes = jsonResult['scenes'];
      });
    }
  }

  Future<void> loadProgress() async {
    final response = await api.get("$getProgress${widget.novelSlug}", context);

    if (response.statusCode == 200) {
      final jsonResult = jsonDecode(response.body);

      setState(() {
        sceneIndex = jsonResult['sceneIndex'] ?? 0;
        dialogueIndex = jsonResult['dialogueIndex'] ?? 0;
      });
    }
  }

  Future<void> saveProgress() async {
    await api.post(saveProgressRoute, context, {
      "slug": widget.novelSlug,
      "sceneIndex": sceneIndex,
      "dialogueIndex": dialogueIndex,
    });
  }

  void nextDialogue() {
    final currentScene = scenes[sceneIndex];
    final dialogues = currentScene['dialogues'];

    setState(() {
      if (dialogueIndex < dialogues.length - 1) {
        dialogueIndex++;
      } else if (sceneIndex < scenes.length - 1) {
        sceneIndex++;
        dialogueIndex = 0;
      } else {
        Navigator.pop(context);
      }
    });
    _startInactivityTimer();
    saveProgress();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    saveProgress();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (scenes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentScene = scenes[sceneIndex];
    final currentDialogue = currentScene['dialogues'][dialogueIndex];

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _startInactivityTimer();
          nextDialogue();
        },
        child: Stack(
          children: [
            FadeInImage(
              placeholder: AssetImage('assets/placeholders/bg_placeholder.png'),
              image: NetworkImage(currentScene['background'] ?? ''),
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

            if (currentDialogue['character'] != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: FadeInImage(
                  placeholder: const AssetImage(
                    'assets/placeholders/char_placeholder.png',
                  ),
                  image: NetworkImage(currentDialogue['character'] ?? ''),
                  height: 500,
                  fit: BoxFit.contain,
                  fadeInDuration: const Duration(milliseconds: 400),
                  fadeOutDuration: const Duration(milliseconds: 200),

                  imageErrorBuilder: (_, __, ___) {
                    return Image.asset(
                      'assets/placeholders/char_placeholder.png',
                      height: 500,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.8),
                  border: Border.all(
                    color: Color.fromRGBO(48, 37, 62, 1),
                    width: 2.0,
                  ),
                ),
                width: double.infinity,
                height: 135,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          currentDialogue['name'],
                          style: TextStyle(
                            color: Color.fromRGBO(48, 37, 62, 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          currentDialogue['text'],
                          softWrap: true,
                          style: const TextStyle(
                            color: Color.fromRGBO(48, 37, 62, 1),
                            fontSize: 24,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
