import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/ui/my_profile/my_achievments.dart';
import 'package:qaragim/ui/settings/edit_account_screen.dart';
import '../auth_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:qaragim/config.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  bool _isLoading = false;

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
    setState(() => _isLoading = true);

    try {
      var response = await http.put(
        Uri.parse(birthday),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}',
        },
        body: jsonEncode({'birthday': birthdayDate}),
      );

      setState(() => _isLoading = false);

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
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Network error: ${e}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Color.fromRGBO(148, 199, 180, 1),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeOverlay(),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: Color.fromRGBO(48, 37, 62, 1),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                auth.name ?? "no name",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color.fromRGBO(48, 37, 62, 1),
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
                                ),
                              ),
                            ],
                          ),
                          Text(
                            auth.email ?? "no email",
                            style: TextStyle(
                              fontSize: 16,
                              color: Color.fromRGBO(48, 37, 62, 0.5),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                Icons.cake,
                                size: 19.0,
                                color: Color.fromRGBO(48, 37, 62, 1),
                              ),
                              const SizedBox(width: 1),
                              if (_isLoading)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              else if (auth.birthday != null &&
                                  auth.birthday!.isNotEmpty)
                                Text(
                                  auth.birthday!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromRGBO(48, 37, 62, 1),
                                  ),
                                )
                              else
                                TextButton(
                                  onPressed: () => _pickBirthday(context, auth),
                                  child: const Text(
                                    "Туған күн қосу",
                                    style: TextStyle(
                                      color: Color.fromRGBO(48, 37, 62, 1),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          MyAchievments(),
        ],
      ),
    );
  }
}
