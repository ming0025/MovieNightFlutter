import 'package:flutter/material.dart';
import 'package:movies/pages/WelcomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Night App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.teal[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
        ),
        primarySwatch: Colors.deepPurple,
        colorScheme: ThemeData().colorScheme.copyWith(
              secondary: Colors.tealAccent,
            ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 72.0,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple),
          titleLarge: TextStyle(
              fontSize: 36.0,
              fontStyle: FontStyle.normal,
              color: Colors.deepPurple),
          bodyMedium: TextStyle(
              fontSize: 14.0, fontFamily: 'Hind', color: Colors.deepPurple),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.tealAccent,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
