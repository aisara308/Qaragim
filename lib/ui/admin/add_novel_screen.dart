import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/admin/models.dart';
import 'package:qaragim/ui/home_page.dart';

/// ================= SCREEN =================

enum EditorMode { manual, json }

class AddNovelEditorScreen extends StatefulWidget {
  const AddNovelEditorScreen({super.key});

  @override
  State<AddNovelEditorScreen> createState() => _AddNovelEditorScreenState();
}

class _AddNovelEditorScreenState extends State<AddNovelEditorScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final slugController = TextEditingController();
  final coverController = TextEditingController();
  final tagController = TextEditingController();
  final achievementController = TextEditingController();

  final api = ApiClient();

  List<String> tags = [];
  List<Character> characters = [];
  List<Scene> scenes = [];
  EditorMode editorMode = EditorMode.manual;

  final jsonController = TextEditingController();

  final List<Map<String, String>> availableVoices = [
    {'label': 'Қыз 1', 'value': 'voices/girl1.wav'},
    {'label': 'Қыз 2', 'value': 'voices/girl2.wav'},
    {'label': 'Қыз 3', 'value': 'voices/girl3.wav'},
    {'label': 'Бала 1', 'value': 'voices/child1.wav'},
    {'label': 'Бала 2', 'value': 'voices/child2.wav'},
    {'label': 'Ұл 1', 'value': 'voices/man1.wav'},
    {'label': 'Ұл 2', 'value': 'voices/man2.wav'},
    {'label': 'Ұл 3', 'value': 'voices/man3.wav'},
  ];

  @override
  void initState() {
    super.initState();
    _ensureAuthorCharacter();
  }

  void _ensureAuthorCharacter() {
    final authorExists = characters.any((c) => c.id == 'author');
    if (!authorExists) {
      setState(() {
        characters.insert(
          0, // вставляем в начало
          Character(
            id: 'author',
            name: 'Автор',
            avatar:
                '', // можно оставить пустым или поставить стандартный аватар
            voice: 'voices/man3.wav',
          ),
        );
      });
    }
  }

  /// ================= BUILD SCRIPT =================

  Map<String, dynamic> buildScript() {
    return {
      "characters": characters.map((c) => c.toJson()).toList(),
      "scenes": scenes.map((s) => s.toJson()).toList(),
    };
  }

  /// ================= SAVE =================

  Future<void> saveNovel() async {
    if (titleController.text.isEmpty ||
        descController.text.isEmpty ||
        slugController.text.isEmpty ||
        coverController.text.isEmpty ||
        characters.isEmpty ||
        scenes.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Бар ақпаратты толтырыңыз")));
      return;
    }
    for (var scene in scenes) {
      if (scene.dialogues.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Актте кемінде 1 диалог болуы қажет")),
        );
        return;
      }

      for (var d in scene.dialogues) {
        if (d.text.trim().isEmpty || d.characterId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Диалогтар бос қалмауы тиіс")),
          );
          return;
        }
      }
    }

    final body = {
      "title": titleController.text,
      "description": descController.text,
      "tags": tags,
      "cover": coverController.text,
      "slug": slugController.text,
      "script": buildScript(),
    };

    final response = await api.post(createNovelUrl, context, body);

    if (response.statusCode == 201) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(mode: NovelMode.user)),
      );
    }
  }

  /// ================= CHARACTER EDITOR =================

  void openCharacterEditor() {
    final nameController = TextEditingController();
    final avatarController = TextEditingController();
    final player = AudioPlayer();
    String? selectedVoice = availableVoices.last['value'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Кейіпкер қосу"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Аты"),
            ),
            TextField(
              controller: avatarController,
              decoration: const InputDecoration(labelText: "Аватар URL"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedVoice,
              decoration: const InputDecoration(labelText: "Дыбыс"),
              items: availableVoices.map((v) {
                return DropdownMenuItem(
                  value: v['value'],
                  child: Text(v['label']!),
                );
              }).toList(),
              onChanged: (v) => selectedVoice = v,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                if (selectedVoice != null) {
                  player.play(AssetSource(selectedVoice!)); // проиграть голос
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text("Тыңдау"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (nameController.text.isEmpty ||
                  avatarController.text.isEmpty ||
                  selectedVoice == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Деректерді толық енгізіңіз")),
                );
                return;
              }

              setState(() {
                characters.add(
                  Character(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    avatar: avatarController.text,
                    voice: selectedVoice!,
                  ),
                );
              });

              Navigator.pop(context);
            },
            child: const Text("Қосу"),
          ),
        ],
      ),
    );
  }

  /// ================= DIALOGUE EDITOR =================

  void openDialogueEditor(Dialogue d) {
    String? selectedCharacterId = d.characterId;
    final textController = TextEditingController(text: d.text);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Диалог"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: selectedCharacterId!.isEmpty ? null : selectedCharacterId,
              hint: const Text("Кейіпкерді таңдаңыз"),
              items: characters.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage(c.avatar)),
                      const SizedBox(width: 10),
                      Text(c.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                selectedCharacterId = v;
              },
            ),
            TextField(
              controller: textController,
              decoration: const InputDecoration(labelText: "Реплика"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              d.characterId = selectedCharacterId ?? '';
              d.text = textController.text;
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// ================= ACHIEVEMENT EDITOR =================

  void openAchievementEditor(Scene scene) {
    final nameController = TextEditingController();
    final slugController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Жетістік қосу"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Атауы"),
            ),
            TextField(
              controller: slugController,
              decoration: const InputDecoration(labelText: "Slug"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: "Сипаттама (25 сөзге дейін)",
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final slug = slugController.text.trim();
              final desc = descController.text.trim();

              if (name.isEmpty || slug.isEmpty || desc.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Все поля обязательны")),
                );
                return;
              }

              if (!isDescriptionValid(desc)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Описание должно быть до 25 слов"),
                  ),
                );
                return;
              }

              setState(() {
                scene.achievement = Achievement(
                  name: name,
                  slug: slug,
                  description: desc,
                );
              });

              Navigator.pop(context);
            },
            child: const Text("Создать"),
          ),
        ],
      ),
    );
  }

  /// ================= SCENE CARD =================
  Widget _sceneCard(Scene scene, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.08)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Акт ${index + 1}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    scene.expanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () =>
                      setState(() => scene.expanded = !scene.expanded),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() => scenes.removeAt(index));
                  },
                ),
              ],
            ),
          ),

          if (scene.expanded) ...[
            _niceField(scene.backgroundController, "Акт суреті URL"),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scene.dialogues.length,
              itemBuilder: (context, i) {
                final d = scene.dialogues[i];

                final char = characters.firstWhere(
                  (c) => c.id == d.characterId,
                  orElse: () => Character(id: '', name: 'Атаусыз', avatar: ''),
                );

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F2F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: char.avatar.isNotEmpty
                          ? NetworkImage(char.avatar)
                          : null,
                      child: char.avatar.isEmpty
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(char.name),
                    subtitle: Text(d.text.isEmpty ? "..." : d.text),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => openDialogueEditor(d),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() => scene.dialogues.removeAt(i));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (characters.isEmpty) return;
                  final newDialogue = Dialogue();
                  setState(() => scene.dialogues.add(newDialogue));
                  openDialogueEditor(newDialogue);
                },
                style: _mainButton(),
                child: const Text("Диалог қосу"),
              ),
            ),
            const SizedBox(height: 10),
            if (scene.achievement == null)
              ElevatedButton(
                style: _mainButton(),
                onPressed: () => openAchievementEditor(scene),
                child: const Text("Жетістік қосу"),
              ),
            if (scene.achievement != null)
              Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0D9F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "🏆 ${scene.achievement!.name}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("Slug: ${scene.achievement!.slug}"),
                    Text(scene.achievement!.description),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() => scene.achievement = null);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// ================= UI =================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF30253E),
        ),
      ),
    );
  }

  Widget _glassCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.08)),
        ],
      ),
      child: child,
    );
  }

  Widget _niceField(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF4F2F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  ButtonStyle _mainButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF6C5DD3),
      foregroundColor: Colors.white, // ⭐ FIX
      textStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F2F8),
      appBar: AppBar(
        elevation: 5,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Новелла жасау",
          style: TextStyle(
            color: Color(0xFF30253E),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ====== BASIC INFO ======
            _sectionTitle("Негізгі ақпарат"),

            _glassCard(
              Column(
                children: [
                  _niceField(titleController, "Атауы"),
                  _niceField(descController, "Сипаттамасы"),
                  _niceField(slugController, "Slug"),
                  _niceField(coverController, "Сырт суреті URL"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle("Тегтер"),

            _glassCard(
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: tagController,
                          decoration: const InputDecoration(
                            labelText: "Тег қосу",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (tagController.text.isNotEmpty) {
                            setState(() {
                              tags.add(tagController.text);
                              tagController.clear();
                            });
                          }
                        },
                        style: _mainButton(),
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      return Chip(
                        label: Text(t),
                        backgroundColor: const Color(0xFFE0D9F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// ====== CHARACTERS ======
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle("Кейіпкерлер"),
                ElevatedButton.icon(
                  onPressed: openCharacterEditor,
                  icon: const Icon(Icons.add),
                  label: const Text("Қосу"),
                  style: _mainButton(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: characters.map((c) {
                return Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 6,
                            color: Colors.black.withOpacity(0.08),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(backgroundImage: NetworkImage(c.avatar)),
                          const SizedBox(width: 8),
                          Text(c.name),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            characters.removeWhere((char) => char.id == c.id);
                          });
                        },
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.red,
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            /// ====== SCENES ======
            _sectionTitle("Акттар"),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scenes.length,
              itemBuilder: (context, index) {
                return _sceneCard(scenes[index], index);
              },
            ),

            const SizedBox(height: 10),

            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => scenes.add(Scene(dialogues: [])));
                },
                icon: const Icon(Icons.movie_creation_outlined),
                label: const Text("Акт қосу"),
                style: _mainButton(),
              ),
            ),

            const SizedBox(height: 40),

            /// ===== SAVE =====
            Center(
              child: ElevatedButton(
                onPressed: saveNovel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFF30253E),
                ),
                child: const Text(
                  "Новелланы сақтау",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
