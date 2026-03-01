import 'package:flutter/material.dart';

/// ================= MODELS =================

class Character {
  String id;
  String name;
  String avatar;
  String? voice;

  Character({
    required this.id,
    required this.name,
    required this.avatar,
    this.voice,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "avatar": avatar,
    "voice": voice,
  };
}

class Dialogue {
  String characterId;
  String text;

  Dialogue({this.characterId = '', this.text = ''});

  Map<String, dynamic> toJson() => {"characterId": characterId, "text": text};
}

class Scene {
  String background;
  List<Dialogue> dialogues;
  Achievement? achievement;
  bool expanded;

  late TextEditingController backgroundController;

  Scene({
    this.background = '',
    this.dialogues = const [],
    this.achievement,
    this.expanded = true,
  }) {
    backgroundController = TextEditingController(text: background);
  }

  Map<String, dynamic> toJson() => {
    "background": backgroundController.text,
    "dialogues": dialogues.map((d) => d.toJson()).toList(),
    if (achievement != null) "achievement": achievement!.toJson(),
  };
}

class Achievement {
  String name;
  String slug;
  String description;

  Achievement({this.name = '', this.slug = '', this.description = ''});

  Map<String, dynamic> toJson() => {
    "name": name,
    "slug": slug,
    "description": description,
  };
}

bool isDescriptionValid(String text) {
  return text.trim().split(RegExp(r'\s+')).length <= 25;
}
