import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qaragim/ui/login_screen.dart';
import 'package:qaragim/ui/my_profile/my_profile_screen.dart';
import 'package:qaragim/ui/settings/edit_account_screen.dart';
import 'package:qaragim/ui/settings/settings_item.dart';
// import 'package:qaragim/ui/settings/settings_switch.dart';
// import '../icon_widget.dart';
import './forward_button.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationsEnabled = true;

  Future<void> openTelegramChat(String username, String message) async {
    final Uri telegramUrl = Uri.parse(
      "https://t.me/$username?text=${Uri.encodeComponent(message)}",
    );
    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Telegram ашу мүмкін болмады';
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool firstConfirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Назар аударыңыз"),
        content: Text("Сіз аккаунтты жойғыңыз келетініне сенімдісіз бе?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Жоқ"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Иә"),
          ),
        ],
      ),
    );

    if (firstConfirm != true) return;

    bool secondConfirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Соңғы растама"),
        content: Text(
          "Бұл әрекет қайтарылмайды! Аккаунт пен деректер толық жойылады.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Бас тарту"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Иә, жою"),
          ),
        ],
      ),
    );

    if (secondConfirm == true) {
      bool deleted = await authProvider.deleteAccount();
      if (deleted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Қате орын алды, кейінірек көріңіз")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(128, 185, 177, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(99, 136, 114, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Баптаулар',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Аккаунт',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              authProvider.name ?? 'No name',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: const Color.fromRGBO(48, 37, 62, 1),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditAccountScreen(),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Color.fromRGBO(48, 37, 62, 1),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          authProvider.email ?? 'No email',
                          style: TextStyle(
                            fontSize: 16,
                            color: const Color.fromRGBO(48, 37, 62, 0.7),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    forward_button(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                "Баптаулар",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
              const SizedBox(height: 20),
              // SettingsItem(
              //   name: "Тіл",
              //   definition: "Қазақша",
              //   iconColor: Colors.orange,
              //   iconBGColor: Colors.orange.shade100,
              //   onPressed: Placeholder.new,
              //   icon: Ionicons.earth,
              // ),
              // const SizedBox(height: 20),
              // SettingsSwitch(
              //   name: "Хабарламалар",
              //   icon: Ionicons.notifications,
              //   iconBGColor: Colors.blue.shade100,
              //   iconColor: Colors.blue,
              //   value: isNotificationsEnabled,
              //   onPressed: (value) {
              //     setState(() {
              //       isNotificationsEnabled = value;
              //     });
              //   },
              // ),
              const SizedBox(height: 20),
              SettingsItem(
                name: "Көмек",
                definition: "",
                icon: Ionicons.nuclear,
                iconBGColor: Colors.red.shade100,
                iconColor: Colors.red,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "FAQ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        content: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ақпарат жиналуда...",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Егер сізде сұрақтар болса, төмендегі батырманы басыңыз.",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await openTelegramChat(
                                "Insomniac747",
                                "Сәлем! Мен көмек сұрағым келеді.",
                              );
                            },
                            child: const Text(
                              "Бағдарламашымен байланысу",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 40),
              Text(
                "Кері байланыс",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
              const SizedBox(height: 20),
              SettingsItem(
                name: "Баг табылды",
                definition: "",
                iconBGColor: Colors.teal.shade100,
                iconColor: Colors.teal,
                onPressed: () {
                  openTelegramChat(
                    "Insomniac747",
                    "Сәлем! Мен қолданбада баг таптым.",
                  );
                },
                icon: Ionicons.bug,
              ),
              const SizedBox(height: 15),
              SettingsItem(
                name: "Пікір қалдыру",
                definition: "",
                iconBGColor: Colors.purple.shade100,
                iconColor: Colors.purple,
                icon: Ionicons.thumbs_up,
                onPressed: () {
                  openTelegramChat(
                    "Insomniac747",
                    "Сәлем! Мен пікір қалдырғым келеді.",
                  );
                },
              ),
              SizedBox(height: 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade700,
                      foregroundColor: Colors.white,
                      minimumSize: Size(100, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.logout),
                    label: Text(
                      "Шығу",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () async {
                      await authProvider.clearTokenAndPrefs();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      minimumSize: Size(100, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.delete_forever),
                    label: Text(
                      "Аккаунтты жою",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _showDeleteConfirmation(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
