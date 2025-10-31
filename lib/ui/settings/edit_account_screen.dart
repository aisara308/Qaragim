import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/ui/settings/edit_item.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String gender = "Қыз";
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    nameController = TextEditingController(text: auth.name ?? '');
    emailController = TextEditingController(text: auth.email ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: Color.fromRGBO(148, 199, 180, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(128, 185, 177, 1),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Ionicons.chevron_back_outline),
        ),
        leadingWidth: 80,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeOverlay()),
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: Color.fromRGBO(99, 136, 114, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                fixedSize: Size(60, 50),
                elevation: 3,
              ),
              icon: Icon(Ionicons.checkmark, color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Аккаунт',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Фото",
                widget: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/avatar.png'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Сурет қосу",
                        style: TextStyle(
                          color: Color.fromRGBO(48, 37, 62, 1),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              EditItem(
                widget: TextField(
                  controller: TextEditingController(
                    text: authProvider.name ?? '',
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Аты",
                  ),
                ),
                title: "Аты",
              ),
              const SizedBox(height: 40),
              EditItem(
                widget: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          gender = "Қыз";
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: gender == "Қыз"
                            ? Colors.pinkAccent
                            : Colors.grey.shade200,
                        fixedSize: const Size(50, 50),
                      ),
                      icon: Icon(
                        Ionicons.female,
                        color: gender == "Қыз" ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          gender = "Ұл";
                        });
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: gender == "Ұл"
                            ? Colors.deepPurple
                            : Colors.grey.shade200,
                        fixedSize: const Size(50, 50),
                      ),
                      icon: Icon(
                        Ionicons.male,
                        color: gender == "Ұл" ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                title: "Гендер",
              ),
              const SizedBox(height: 40),
              EditItem(widget: TextField(), title: "Жас"),
              const SizedBox(height: 40),
              EditItem(
                widget: TextField(
                  controller: TextEditingController(
                    text: authProvider.email ?? '',
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Электрондық пошта",
                  ),
                ),
                title: "Пошта",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
