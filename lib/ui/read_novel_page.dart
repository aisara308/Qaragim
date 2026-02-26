import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NovelPage extends StatefulWidget {
  final String novelFolder;
  const NovelPage({super.key, required this.novelFolder});

  @override
  State<NovelPage> createState() => _NovelPageState();
}

class _NovelPageState extends State<NovelPage> {
  List scenes = [];
  int sceneIndex = 0;
  int dialogueIndex = 0;

  Timer? _inactivityTimer;

  @override
  void initState() {
    super.initState();
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
    final data = await rootBundle.loadString(
      'assets/novels/${widget.novelFolder}/script.json',
    );
    final jsonResult = jsonDecode(data);
    setState(() {
      scenes = jsonResult['scenes'];
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
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
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
            Image.asset(
              'assets/novels/${widget.novelFolder}/bg/${currentScene['background']}',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            if (currentDialogue['character'] != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/novels/${widget.novelFolder}/char/${currentDialogue['character']}',
                  height: 500,
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
