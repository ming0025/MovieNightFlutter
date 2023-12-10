import 'dart:io';
import 'package:flutter/material.dart';
import 'package:movies/utils/http_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:movies/pages/SelectMovieScreen.dart';

class JoinSession extends StatefulWidget {
  const JoinSession({super.key});

  @override
  State<JoinSession> createState() => _JoinSessionState();
}

class _JoinSessionState extends State<JoinSession> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  void _submitCode() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? deviceId;

    // Checking if platform is Android or iOS
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
    }

    if (deviceId != null) {
      try {
        // Join session
        final data =
            await HttpHelper.joinSession(deviceId, int.parse(_controller.text));

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SelectMovieScreen()),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to join session, try again.'),
          ),
        );
      }
    } else {
      print('Device ID is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Session'),
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    icon: Icon(Icons.password_rounded),
                    hintText: 'Enter your 4-digit code',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter some digits';
                    } else if (value.length != 4) {
                      return 'Enter exactly 4 digits';
                    } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Enter only digits';
                    }
                    return null;
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitCode();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
