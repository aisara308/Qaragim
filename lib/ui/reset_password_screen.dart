import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qaragim/api_client.dart';
import 'package:qaragim/config.dart';
import 'package:qaragim/ui/home_page.dart';
import 'package:qaragim/utils/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ResetPasswordScreen extends StatefulWidget {
  final bool fromSettings;

  const ResetPasswordScreen({super.key, this.fromSettings = false});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  late bool isFromSettings;
  late ApiClient api;
  bool isVerified = false;
  bool _obscure = true;
  bool codeSent = false;
  bool isCodeButtonPressed = false;
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    api = ApiClient();
    isFromSettings = widget.fromSettings;
  }

  void switchToResetMode() {
    setState(() {
      isFromSettings = false;
    });
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

  Future<void> sendCode(AuthProvider auth) async {
    if (emailController.text.isEmpty) return;

    setState(() {
      isCodeButtonPressed = true;
    });

    var body = {"email": emailController.text};

    try {
      var response = await api.post(sendResetCode, context, body);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          auth.setEmail(emailController.text);
          codeSent = true;
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Код жіберілді")));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Қате: $e")));
    } finally {
      setState(() {
        isCodeButtonPressed = false;
      });
    }
  }

  Future<void> verifyCodeAndReset() async {
    if (!_formKey.currentState!.validate()) return;

    var body = {
      "email": emailController.text,
      "code": codeController.text,
      "newPassword": passwordController.text,
    };

    try {
      var response = await api.put(verifyResetCode, context, body);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Құпиясөз жаңартылды")));
        String email = context.read<AuthProvider>().email ?? "";

        if (email.isNotEmpty) {
          await loginUser(email, passwordController.text);
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Қате: $e")));
    }
  }

  Future<void> changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    var body = {
      "oldPassword": oldPasswordController.text,
      "newPassword": passwordController.text,
    };

    try {
      var response = await api.put(changePasswordEndpoint, context, body);
      var jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Құпиясөз өзгертілді")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Қате: ${jsonResponse['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Қате орын алды: $e")));
    }
  }

  Future<bool> loginUser(String email, String password) async {
    var regBody = {"email": email, "password": password};

    var response = await api.post(login, context, regBody);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', jsonResponse['token']);
      await prefs.setString('refreshToken', jsonResponse['refreshToken']);

      context.read<AuthProvider>().setToken(jsonResponse['token']);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(mode: NovelMode.user)),
      );
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(149, 199, 180, 1),
      appBar: AppBar(
        title: Text(
          isFromSettings
              ? "Құпиясөзді ауыстыру"
              : (codeSent ? "Растау" : "Код жіберу"),
        ),
        backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // -------------------------
              // 1️⃣ Сброс по email (код ещё не отправлен)
              // -------------------------
              if (!isFromSettings && !codeSent) ...[
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Пошта",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Поштаны енгізіңіз" : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isCodeButtonPressed
                      ? null
                      : () => sendCode(authProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: isCodeButtonPressed
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: const Color.fromRGBO(
                              48,
                              37,
                              62,
                              1,
                            ),
                            disabledForegroundColor: const Color.fromRGBO(
                              48,
                              37,
                              62,
                              1,
                            ),
                            backgroundColor: const Color.fromRGBO(
                              48,
                              37,
                              62,
                              1,
                            ),
                            foregroundColor: const Color.fromRGBO(
                              48,
                              37,
                              62,
                              1,
                            ),
                          ),
                          child: CircularProgressIndicator(
                            backgroundColor: const Color.fromRGBO(
                              48,
                              37,
                              62,
                              1,
                            ),
                          ),
                          onPressed: () {},
                        )
                      : const Text("Код жіберу"),
                ),
              ],

              // -------------------------
              // 2️⃣ Сброс по email (код отправлен)
              // -------------------------
              if (!isFromSettings && codeSent) ...[
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: "Код",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Кодты енгізіңіз" : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: "Жаңа құпиясөз",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: verifyCodeAndReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Құпиясөзді жаңарту"),
                ),
              ],

              // -------------------------
              // 3️⃣ Изменение пароля в настройках
              // -------------------------
              if (isFromSettings) ...[
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: "Ескі құпиясөз",
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: "Жаңа құпиясөз",
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscure = !_obscure;
                        });
                      },
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Құпиясөзді ауыстыру"),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: switchToResetMode,
                  child: const Text("Құпиясөзді ұмыттыңыз ба?"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
