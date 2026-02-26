import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/ui/settings/edit_account_screen.dart';
import 'package:qaragim/utils/auth_provider.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback onPickBirthday;
  final bool isLoading;

  const ProfileHeader({
    super.key,
    required this.onPickBirthday,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const HomePage(mode: NovelMode.user),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_back,
                  color: Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
            ],
          ),
          Row(
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
                              builder: (context) => const EditAccountScreen(),
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
                  SizedBox(height: 15),
                  Row(
                    children: [
                      if (isLoading)
                        const CircularProgressIndicator()
                      else if (auth.birthday != null &&
                          auth.birthday!.isNotEmpty)
                        Row(
                          children: [
                            const Icon(Icons.cake),
                            Text(auth.birthday!),
                          ],
                        )
                      else
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Color.fromRGBO(48, 37, 62, 1),
                            backgroundColor: Color.fromRGBO(128, 185, 177, 1),
                            elevation: 2,
                            padding: EdgeInsets.all(8),
                          ),
                          onPressed: () {
                            onPickBirthday();
                          },
                          child: Row(
                            children: [
                              const Icon(Icons.cake),
                              const Text(
                                "Туған күн қосу",
                                style: TextStyle(
                                  color: Color.fromRGBO(48, 37, 62, 1),
                                ),
                              ),
                            ],
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
    );
  }
}

class ProfileService {
  final ApiClient api = ApiClient();

  Future<void> updateBirthday(BuildContext context, String birthday) async {
    final responce = await api.put(updateUser, context, {'birthday': birthday});
    var jsonResponce = jsonDecode(responce.body);
    var myToken = jsonResponce['token'];
    context.read<AuthProvider>().setToken(myToken);
  }
}
