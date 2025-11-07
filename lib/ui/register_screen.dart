import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/ui/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? errorMessage = '';
  bool _obscure = true;

  Future<bool> registerUser() async {
    if (_formKey.currentState!.validate()) {
      var regBody = {
        "name": nameController.text,
        "email": emailController.text,
        "password": passwordController.text,
      };

      var responce = await http.post(
        Uri.parse(registration),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      var jsonResponce = jsonDecode(responce.body);
      print(jsonResponce);

      if (responce.statusCode == 200) {
        var myToken = jsonResponce['token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', myToken);

        context.read<AuthProvider>().setToken(myToken);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeOverlay()),
        );
        return true;
      } else {
        setState(() {
          errorMessage = "Registration erroe: ${responce.body}";
        });
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Атыңызды енгізіңіз";
    }
    if (value.trim().length < 2) {
      return "Атыңыз тым қысқа";
    }
    return null;
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
                  "Тіркелу",
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
                  controller: nameController,
                  validator: _validateName,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color.fromARGB(194, 60, 57, 103),
                    ),
                    labelText: "Аты",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: emailController,
                  validator: _validateEmail,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.email,
                      color: Color.fromARGB(194, 60, 57, 103),
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
                  validator: _validatePassword,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Color.fromARGB(194, 60, 57, 103),
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      bool success = await registerUser();
                      if (success) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeOverlay(),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      "Tіркелу",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Row(
                //   children: [
                //     const Expanded(
                //       child: Divider(
                //         thickness: 1,
                //         color: Color.fromRGBO(48, 37, 62, 1),
                //       ),
                //     ),
                //     const Padding(
                //       padding: EdgeInsets.symmetric(horizontal: 10),
                //       child: Text(
                //         "немесе",
                //         style: TextStyle(color: Color.fromRGBO(48, 37, 62, 1)),
                //       ),
                //     ),
                //     const Expanded(
                //       child: Divider(
                //         thickness: 1,
                //         color: Color.fromRGBO(48, 37, 62, 1),
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
                //     "Google арқылы тіркелу",
                //     style: TextStyle(color: Colors.black),
                //   ),
                //   icon: Image.asset('../assets/images/google.png', width: 30),
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
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Аккаунтыңыз бар ма?"),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
