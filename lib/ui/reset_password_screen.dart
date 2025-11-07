import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qaragim/config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isVerified = false;
  bool _obscure = true;

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

  // Future<void> verifyFingerprint() async {
  //   try {
  //     final isSupported = await auth.isDeviceSupported();
  //     final canCheck = await auth.canCheckBiometrics;

  //     print("Supported: $isSupported, canCheck: $canCheck");

  //     if (!isSupported || !canCheck) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Саусақ ізі бұл құрылғыда қолжетімсіз")),
  //       );
  //       return;
  //     }

  //     final didAuthenticate = await auth.authenticate(
  //       localizedReason: 'Құпиясөзді өзгерту үшін саусақ ізімен растаңыз',
  //         biometricOnly: true,
  //     );

  //     if (didAuthenticate) {
  //       setState(() => isVerified = true);
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text("Саусақ ізі расталды ✅")));
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Саусақ ізі расталмады ❌")),
  //       );
  //     }
  //   } on PlatformException catch (e) {
  //     print("Ошибка биометрии: ${e.message}");
  //   }
  // }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    var body = {
      "name": nameController.text,
      "email": emailController.text,
      "newPassword": passwordController.text,
    };

    try {
      var responce = await http.put(
        Uri.parse(resetpassword),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      var jsonResponce = jsonDecode(responce.body);

      if (responce.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Құпиясөз жаңартылды")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Қате: ${jsonResponce['message']}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Қате орын алды: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(149, 199, 180, 1),
      appBar: AppBar(
        title: const Text("Құпиясөзді қалпына келтіру"),
        backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Атыңыз",
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) =>
                    value!.isEmpty ? "Атыңызды енгізіңіз" : null,
              ),
              const SizedBox(height: 20),
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
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(48, 37, 62, 1),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Құпиясөзді жаңарту"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
