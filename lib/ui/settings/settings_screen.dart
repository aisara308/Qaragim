import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qaragim/ui/login_screen.dart';
import 'package:qaragim/ui/my_profile/my_profile_screen.dart';
import 'package:qaragim/ui/settings/edit_account_screen.dart';
import 'package:qaragim/ui/settings/settings_item.dart';
import 'package:qaragim/ui/settings/settings_switch.dart';
import '../icon_widget.dart';
import './forward_button.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isNotificationsEnabled = true;
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
              SettingsItem(
                name: "Тіл",
                definition: "Қазақша",
                iconColor: Colors.orange,
                iconBGColor: Colors.orange.shade100,
                onPressed: Placeholder.new,
                icon: Ionicons.earth,
              ),
              const SizedBox(height: 20),
              SettingsSwitch(
                name: "Хабарламалар",
                icon: Ionicons.notifications,
                iconBGColor: Colors.blue.shade100,
                iconColor: Colors.blue,
                value: isNotificationsEnabled,
                onPressed: (value) {
                  setState(() {
                    isNotificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              SettingsItem(
                name: "Көмек",
                definition: "",
                icon: Ionicons.nuclear,
                iconBGColor: Colors.red.shade100,
                iconColor: Colors.red,
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Clicked Report Button')),
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
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Clicked Feedback')));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLogout() => SimpleSettingsTile(
    title: 'Logout',
    subtitle: '',
    leading: IconWidget(icon: Icons.logout, color: Colors.blueAccent),
    onTap: () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    },
  );
}
