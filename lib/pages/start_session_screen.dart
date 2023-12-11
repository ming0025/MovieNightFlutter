import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:movies/utils/http_helper.dart';
import 'package:movies/pages/select_movie_screen.dart';

class StartSession extends StatefulWidget {
  const StartSession({super.key});

  @override
  State<StartSession> createState() => _StartSessionState();
}

class _StartSessionState extends State<StartSession> {
  String? code;

  @override
  void initState() {
    super.initState();
    startOrJoinSession();
  }

  Future<void> startOrJoinSession([int? sessionCode]) async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String? deviceId;
      bool kDebugMode = !kReleaseMode && !kProfileMode;

      // Checking if platform is Android or iOS
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      }
      // Create or join session
      if (deviceId != null) {
        var data = await HttpHelper.startOrJoinSession(deviceId, sessionCode);

        setState(() {
          code = data['data']['code'];
        });
        if (kDebugMode) {
          print(data['data']['session_id']);
        }
      } else {
        throw Exception('Failed to obtain device ID');
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Session'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your session code:'),
            Text(
              code ?? 'Loading...',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SelectMovieScreen()),
                );
              },
              child: const Text('Go to Select Movie Screen'),
            ),
          ],
        ),
      ),
    );
  }
}
