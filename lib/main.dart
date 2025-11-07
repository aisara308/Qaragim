import 'package:flutter/material.dart';
import 'package:qaragim/ui/login_screen.dart';
import 'package:provider/provider.dart';
import './ui/auth_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qaragim/ui/home_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  await authProvider.loadTokenFromPrefs();
  
  runApp(
    ChangeNotifierProvider.value(
      value: authProvider,
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      return HomeOverlay();
    } else {
      return const LoginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Qaragim',
      locale: const Locale('kk', 'KZ'),
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ru', 'RU'),
        Locale('kk', 'KZ'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: FutureBuilder(
        future: _getStartScreen(),
        builder: (context, snapshot){
          if(snapshot.connectionState==ConnectionState.waiting){
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }else{
            return snapshot.data!;
          }
        }
      ),
    );
  }
}
