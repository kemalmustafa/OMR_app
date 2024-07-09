import 'package:flutter/material.dart';
import 'package:optiread/locale/tr_TR.dart';
import 'package:optiread/splash/splash_screen.dart';
import 'package:optiread/pages/page_main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

const splashScreen = SplashScreen();
const mainMenu = MainMenu();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initSplashScreen();
  }

  _initSplashScreen() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _showSplash ? splashScreen : mainMenu,
    );
  }
}
