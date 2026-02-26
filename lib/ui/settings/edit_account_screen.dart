import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:provider/provider.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/ui/reset_password_screen.dart';
import 'dart:convert';

import '../../utils/edit_item.dart';
import '../../utils/auth_provider.dart';
import 'package:qaragim/config.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  String? gender = "";
  late TextEditingController nameController;
  late TextEditingController emailController;
  late ApiClient api;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    nameController = TextEditingController(text: auth.name ?? '');
    emailController = TextEditingController(text: auth.email ?? '');
    gender = auth.gender ?? "";
    api = ApiClient();
  }

  Future<void> _updateAccount(AuthProvider auth) async {
    final newName = nameController.text.trim();
    final newEmail = emailController.text.trim();
    final newGender = gender;

    if (newName == auth.name &&
        newEmail == auth.email &&
        newGender == auth.gender) {
      Navigator.pop(context);
      return;
    }

    if (!mounted) return;
    setState(() => _isUpdating = true);

    try {
      final responce = await api.put(updateUser, context, {
        'name': newName,
        'email': newEmail,
        'gender': gender,
      });
      if (!mounted) return;
      setState(() => _isUpdating = false);

      if (responce.statusCode == 200) {
        final data = jsonDecode(responce.body);

        if (data['token'] != null) {
          auth.setToken(data['token']);
        }

        auth.setName(data['user']['name']);
        auth.setEmail(data['user']['email']);
        auth.setGender(data['user']['gender']);

        if (mounted) Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Қате: ${responce.body}")));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Желі қатесі: $e")));
    }
  }

  Future<void> _pickBirthday(BuildContext context, AuthProvider auth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2008),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('kk', 'KZ'),
    );

    if (picked != null) {
      var formatted =
          "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
      await _sendBirthday(auth, formatted);
    }
  }

  Future<void> _sendBirthday(AuthProvider auth, String birthdayDate) async {
    try {
      final body = jsonEncode({'birthday': birthdayDate});
      var response = await api.put(updateUser, context, body);

      if (response.statusCode == 200) {
        auth.setBirthday(birthdayDate);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Birthday date saved")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error while saving the birthday date")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: ${e}")));
    }
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
              onPressed: _isUpdating
                  ? null
                  : () => _updateAccount(authProvider),
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
                    // TextButton(
                    //   onPressed: () {},
                    //   child: const Text(
                    //     "Сурет қосу",
                    //     style: TextStyle(
                    //       color: Color.fromRGBO(48, 37, 62, 1),
                    //       decoration: TextDecoration.underline,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              EditItem(
                widget: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Аты",
                  ),
                ),
                title: "Аты",
              ),
              const SizedBox(height: 40),
              EditItem(
                title: "Гендер",
                widget: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => gender = "Қыз"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          gender == "Қыз"
                              ? Colors.pinkAccent
                              : Colors.grey.shade200,
                        ),
                        fixedSize: MaterialStateProperty.all(
                          const Size(50, 50),
                        ),
                      ),
                      icon: Icon(
                        Ionicons.female,
                        color: gender == "Қыз" ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () => setState(() => gender = "Ұл"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          gender == "Ұл"
                              ? Colors.deepPurple
                              : Colors.grey.shade200,
                        ),
                        fixedSize: MaterialStateProperty.all(
                          const Size(50, 50),
                        ),
                      ),
                      icon: Icon(
                        Ionicons.male,
                        color: gender == "Ұл" ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      onPressed: () => setState(() => gender = "Басқа"),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          gender == "Басқа"
                              ? Colors.blueGrey
                              : Colors.grey.shade200,
                        ),
                        fixedSize: MaterialStateProperty.all(
                          const Size(50, 50),
                        ),
                      ),
                      icon: Icon(
                        Ionicons.person,
                        color: gender == "Басқа" ? Colors.white : Colors.black,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Жас",
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 107, 106, 106),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 5,
                    child: authProvider.age != null
                        ? Text(authProvider.age.toString())
                        : Row(
                            children: [
                              Text("Белгісіз"),
                              TextButton(
                                onPressed: () =>
                                    _pickBirthday(context, authProvider),
                                child: const Text(
                                  "(Туған күн қосу)",
                                  style: TextStyle(
                                    color: Color.fromRGBO(48, 37, 62, 1),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              EditItem(
                widget: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Электрондық пошта",
                  ),
                ),
                title: "Пошта",
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResetPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Құпиясөзді өзгерту",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(99, 136, 114, 1),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
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
