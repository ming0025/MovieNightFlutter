import 'package:flutter/material.dart';
import 'package:movies/pages/StartSessionScreen.dart';
import 'package:movies/pages/JoinSessionScreen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Night!'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StartSession()),
                );
              },
              child: const Text('Get a Code to Share'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinSession()),
                );
              },
              child: const Text('Enter Code'),
            ),
          ],
        ),
      ),
    );
  }
}
