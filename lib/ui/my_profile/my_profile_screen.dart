import 'package:flutter/material.dart';
import 'package:qaragim/ui/my_profile/my_achievments.dart';
import 'package:qaragim/ui/my_profile/my_novels.dart';
import 'package:qaragim/ui/my_profile/my_titles.dart';
import 'package:qaragim/ui/my_profile/profile_header.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProfileService service = ProfileService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  Future<void> _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('kk', 'KZ'),
    );

    if (picked != null) {
      final formatted =
          "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      final confirmed = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Таңдауыңызды растаңыз",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.normal,
              ),
              children: [
                const TextSpan(text: "Сіздің туған күніңіз: "),
                TextSpan(
                  text: formatted,
                  style: const TextStyle(color: Colors.red),
                ),
                const TextSpan(
                  text: "\nРастаудан кейін таңдауды өзгертуге болмайды",
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Жоқ', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Иә', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      setState(() => _isLoading = true);

      await service.updateBirthday(context, formatted);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(148, 199, 180, 1),
      body: Column(
        children: [
          ProfileHeader(onPickBirthday: _pickBirthday, isLoading: _isLoading),

          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Жетістіктер"),
              Tab(text: "Новеллалар"),
              Tab(text: "Атақтар"),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                MyAchievementsTab(),
                MyNovelsTab(),
                MyTitlesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
