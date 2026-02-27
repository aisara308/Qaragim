import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/ui/reset_password_screen.dart';
import '../utils/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:qaragim/ui/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage = '';
  bool _obscure = true;
  late ApiClient api;
  Future<bool> loginUser() async {
    if (_formKey.currentState!.validate()) {
      var regBody = {
        "email": emailController.text,
        "password": passwordController.text,
      };
      var responce = await api.post(login, context, regBody);
      if (responce.statusCode == 404) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Пайдаланушы табылмады")));
      }
      if (responce.statusCode == 403) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Қате құпиясөз")));
      }
      if (responce.statusCode == 200) {
        var jsonResponce = jsonDecode(responce.body);
        var myToken = jsonResponce['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', jsonResponce['token']);
        await prefs.setString('refreshToken', jsonResponce['refreshToken']);

        context.read<AuthProvider>().setToken(myToken);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(mode: NovelMode.user),
          ),
        );
        return true;
      } else {
        print(responce.body);
        setState(() {
          errorMessage = "Login error: ${responce.body}";
        });
        return false;
      }
    }
    return false;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Поштаны енгізіңіз";
    }
    String pattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
    if (!RegExp(pattern).hasMatch(value.trim())) {
      return "Дұрыс поштаны енгізіңіз";
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Құпиясөзді енгізіңіз";
    }
    if (value.length < 8) {
      return "Құпиясөз кемінде 8 таңбадан тұруы керек";
    }
    String pattern =
        r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&^(){}[\]<>.,;:~`+=_-]).{8,}$';
    if (!RegExp(pattern).hasMatch(value)) {
      return "Кемінде 1 әріп, 1 сан және 1 арнайы символ болуы керек";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    api = ApiClient();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(149, 199, 180, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
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

                TextFormField(
                  controller: emailController,
                  validator: _validateEmail,
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
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: passwordController,
                  obscureText: _obscure,
                  validator: _validatePassword,
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
                        child: const Text(
                          "Кіру",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ResetPasswordScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              "Құпиясөзді ұмыттыңыз ба?",
                              style: TextStyle(
                                color: Color.fromRGBO(48, 37, 62, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      // Row(
                      //   children: [
                      //     const Expanded(
                      //       child: Divider(
                      //         thickness: 1,
                      //         color: Color.fromRGBO(60, 57, 103, 1),
                      //       ),
                      //     ),
                      //     const Padding(
                      //       padding: EdgeInsets.symmetric(horizontal: 10),
                      //       child: Text(
                      //         "немесе",
                      //         style: TextStyle(
                      //           color: Color.fromRGBO(60, 57, 103, 1),
                      //         ),
                      //       ),
                      //     ),
                      //     const Expanded(
                      //       child: Divider(
                      //         thickness: 1,
                      //         color: Color.fromRGBO(60, 57, 103, 1),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // const SizedBox(height: 40),
                      // OutlinedButton.icon(
                      //   style: OutlinedButton.styleFrom(
                      //     backgroundColor: Colors.white,
                      //     side: const BorderSide(color: Colors.grey),
                      //     padding: const EdgeInsets.symmetric(
                      //       vertical: 12,
                      //       horizontal: 20,
                      //     ),
                      //     shape: RoundedRectangleBorder(
                      //       borderRadius: BorderRadius.circular(15),
                      //     ),
                      //   ),
                      //   label: const Text(
                      //     "Google арқылы кіру",
                      //     style: TextStyle(color: Colors.black),
                      //   ),
                      //   icon: Image.asset(
                      //     '../assets/images/google.png',
                      //     width: 30,
                      //   ),
                      //   onPressed: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => const HomeOverlay(),
                      //       ),
                      //     );
                      //   },
                      // ),
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
      ),
    );
  }
}
