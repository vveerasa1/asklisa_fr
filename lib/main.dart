import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'const/theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0E21),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AskLisaApp());
}

class AskLisaApp extends StatelessWidget {
  const AskLisaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AskLisa - AI Health Assistant',
      debugShowCheckedModeBanner: false,
      theme: AskLisaTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
