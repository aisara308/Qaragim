import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/home_page.dart';
import 'auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qaragim/ui/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isNotValidate = false;
  String? errorMessage = '';
  bool _obscure = true;

  Future<bool> loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };
      var responce = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );
      var jsonResponce = jsonDecode(responce.body);
      print(jsonResponce);

      if (responce.statusCode == 200) {
        var myToken = jsonResponce['token'];
        context.read<AuthProvider>().setToken(myToken);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeOverlay()),
        );
        return true;
      } else {
        setState(() {
          errorMessage = "Login error: ${responce.body}";
        });
        return false;
      }
    } else {
      setState(() {
        _isNotValidate = true;
      });
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(149, 199, 180, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Кіру",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                "Бізге қосылып, қазақ ертегілерін\nөз басыңыздан кешіп өтіңіз",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color.fromRGBO(48, 37, 62, 1),
                ),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Color.fromRGBO(48, 37, 62, 1),
                  ),
                  labelText: "Пошта",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorStyle: TextStyle(color: Colors.white),
                  errorText: _isNotValidate
                      ? "Дұрыс пошта мекенжайын енгізіңіз"
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Color.fromRGBO(48, 37, 62, 1),
                  ),
                  labelText: "Құпиясөз",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  errorStyle: TextStyle(color: Colors.white),
                  errorText: _isNotValidate ? "Дұрыс құпиясөз енгізіңіз" : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      color: Color.fromARGB(194, 60, 57, 103),
                      _obscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                    color: Color.fromARGB(194, 60, 57, 103),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await loginUser();
                      },
                      child: const Text("Кіру", style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color.fromRGBO(60, 57, 103, 1),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "немесе",
                            style: TextStyle(
                              color: Color.fromRGBO(60, 57, 103, 1),
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(
                            thickness: 1,
                            color: Color.fromRGBO(60, 57, 103, 1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      label: const Text(
                        "Google арқылы кіру",
                        style: TextStyle(color: Colors.black),
                      ),
                      icon: Image.asset(
                        '../assets/images/google.png',
                        width: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeOverlay(),
                          ),
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text("Аккаунтыңыз жоқ па?"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
