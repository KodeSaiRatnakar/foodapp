import 'package:flutter/material.dart';
import 'package:foodapp/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      theme: MyTheme.lightTheme(),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: const Color(0xff828282),
      textTheme: const TextTheme(
        bodySmall: TextStyle(
          fontFamily: 'Vazirmatn',
          color:  Color(0xff828282),
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(
            Color(0xffB4DC2F),
          ),
        ),
      ),
    );
  }
}
