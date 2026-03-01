import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/utils/voice_player.dart';

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
  DateTime _lastSoundTime = DateTime.now();
  bool showAchievementCard = false;
  String achievementTitle = '';

  String visibleText = '';
  String? _lastTypedText;
  Timer? _typingTimer;
  bool isTyping = false;

  Timer? _inactivityTimer;

  var characters;

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    loadScript();
    _startInactivityTimer();
  }

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 20), () {
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
        scenes = jsonResult['scenes'] ?? [];

        characters = {};
        if (jsonResult['characters'] != null) {
          for (var c in jsonResult['characters']) {
            characters[c['id']] = c;
          }
        }
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

  Future<bool> unlockAchievement(Map achievement) async {
    try {
      final response = await api.post(unlockAchievementRoute, context, {
        "slug": widget.novelSlug,
        "achievement": achievement,
      });

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'unlocked') {
          return true;
        }
      }
    } catch (e) {
      print("Unlock error: $e");
    }

    return false;
  }

  Future<void> showAchievement(String name) async {
    setState(() {
      achievementTitle = name;
      showAchievementCard = true;
    });

    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() {
        showAchievementCard = false;
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
  }

  void startTyping(String fullText, {String? voiceUrl}) {
    _typingTimer?.cancel();
    visibleText = '';
    isTyping = true;
    int i = 0;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (i < fullText.length) {
        setState(() {
          visibleText += fullText[i];
        });

        if (voiceUrl != null) {
          final now = DateTime.now();

          if (now.difference(_lastSoundTime).inMilliseconds > 140) {
            _lastSoundTime = now;
            VoicePlayer.play(voiceUrl);
          }
        }

        i++;
      } else {
        timer.cancel();
        isTyping = false;
      }
    });
  }

  void skipTyping(String fullText) {
    _typingTimer?.cancel();
    VoicePlayer.stop();

    setState(() {
      visibleText = fullText;
      isTyping = false;
    });
  }

  void nextDialogue() async {
    final currentScene = scenes[sceneIndex];
    final dialogues = currentScene['dialogues'];

    bool sceneFinished = dialogueIndex == dialogues.length - 1;
    bool lastScene = sceneIndex == scenes.length - 1;

    if (!sceneFinished) {
      setState(() => dialogueIndex++);
      _startInactivityTimer();
      saveProgress();
      return;
    }

    final achievement = currentScene['achievement'];

    if (lastScene) {
      if (achievement != null) {
        final unlocked = await unlockAchievement(achievement);

        if (unlocked) {
          await showAchievement(achievement['name']); // ЖДЁМ
        }
      }

      await finishNovel();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(mode: NovelMode.user),
          ),
        );
      }
    } else {
      if (achievement != null) {
        final unlocked = await unlockAchievement(achievement);
        if (unlocked) {
          showAchievement(achievement['name']);
        }
      }

      setState(() {
        sceneIndex++;
        dialogueIndex = 0;
      });
    }

    _startInactivityTimer();
    saveProgress();
  }

  List<Map<String, String>> getDialogueHistory() {
    List<Map<String, String>> history = [];

    for (int s = 0; s <= sceneIndex; s++) {
      final scene = scenes[s];
      final dialogues = scene['dialogues'];

      int maxDialogue = (s == sceneIndex) ? dialogueIndex : dialogues.length;

      for (int d = 0; d < maxDialogue; d++) {
        final dialogue = dialogues[d];

        final charId = dialogue['characterId'];
        final character = characters[charId];

        history.add({
          "name": character?['name'] ?? '',
          "text": dialogue['text'] ?? '',
        });
      }
    }

    return history;
  }

  Future<void> finishNovel() async {
    try {
      final response = await api.post(finishNovelRoute, context, {
        'slug': widget.novelSlug,
      });

      if (response.statusCode == 200) {
        print("Novel marked as finished!");
      } else {
        print("Failed to finish novel: ${response.body}");
      }
    } catch (e) {
      print("Error finishing novel: $e");
    }
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    saveProgress();
    _typingTimer?.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    if (scenes.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentScene = scenes[sceneIndex];
    final currentDialogue = currentScene['dialogues'][dialogueIndex];
    final charId = currentDialogue['characterId'];
    final character = characters[charId];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_lastTypedText != currentDialogue['text']) {
        _lastTypedText = currentDialogue['text'];
        startTyping(currentDialogue['text'], voiceUrl: character?['voice']);
      }
    });
    final charName = character?['name'] ?? '';
    final charAvatar = character?['avatar'];
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (isPaused) return;
          _startInactivityTimer();

          final currentScene = scenes[sceneIndex];
          final fullText = currentScene['dialogues'][dialogueIndex]['text'];

          if (isTyping) {
            skipTyping(fullText);
          } else {
            nextDialogue();
          }
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

            if (charAvatar != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: FadeInImage(
                  placeholder: const AssetImage(
                    'assets/placeholders/char_placeholder.png',
                  ),
                  image: NetworkImage(charAvatar ?? ''),
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
                          charName,
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
                          visibleText,
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    /// BACK
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),

                    Row(
                      children: [
                        /// HISTORY BUTTON
                        IconButton(
                          onPressed: openHistory,
                          icon: const Icon(
                            Icons.menu_book,
                            color: Colors.white,
                          ),
                        ),

                        /// PAUSE BUTTON
                        IconButton(
                          onPressed: togglePause,
                          icon: Icon(
                            isPaused ? Icons.play_arrow : Icons.pause,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (showAchievementCard)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: showAchievementCard ? 1 : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(48, 37, 62, 0.95),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            achievementTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void openHistory() async {
    _inactivityTimer?.cancel(); // ⭐ остановили авто-выход

    final history = getDialogueHistory();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: ListView.builder(
                controller: controller,
                padding: const EdgeInsets.all(16),
                itemCount: history.length,
                itemBuilder: (_, index) {
                  final item = history[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Color.fromRGBO(48, 37, 62, 1),
                          fontSize: 18,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(
                            text: "${item['name']}: ",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: item['text']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );

    if (!isPaused) {
      _startInactivityTimer();
    }
  }

  bool isPaused = false;

  void togglePause() {
    setState(() {
      isPaused = !isPaused;
    });

    if (isPaused) {
      _typingTimer?.cancel();
      _inactivityTimer?.cancel();
    } else {
      _startInactivityTimer();
    }
  }
}
