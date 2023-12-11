import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class HttpHelper {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/session.json');
  }

  static Future<File> writeSessionId(String sessionId) async {
    final file = await _localFile;
    return file.writeAsString(jsonEncode({'sessionId': sessionId}));
  }

  static Future<String> readSessionId() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      final jsonData = jsonDecode(contents);
      return jsonData['sessionId'];
    } catch (error) {
      return Future.value(null);
    }
  }

  static Future<Map<String, dynamic>> startOrJoinSession(String deviceId,
      [int? code]) async {
    Map<String, dynamic>? data = null;

    if (code != null) {
      try {
        data = await joinSession(deviceId, code);
      } catch (e) {
        print('Failed to join session: $e');
      }
    }

    if (data == null) {
      final response = await http.get(
        Uri.parse(
            'https://movie-night-api.onrender.com/start-session?device_id=$deviceId'),
      );

      if (response.statusCode == 200) {
        data = json.decode(response.body);
        if (data != null &&
            data['data'] != null &&
            data['data']['session_id'] != null) {
          await writeSessionId(data['data']['session_id']);
        } else {
          throw Exception('Invalid response format');
        }
      } else {
        throw Exception('Failed to start session');
      }
    }

    if (data == null) {
      throw Exception('Failed to start or join session');
    }

    return data;
  }

  static Future<Map<String, dynamic>> joinSession(
      String deviceId, int code) async {
    final response = await http.get(
      Uri.parse(
          'https://movie-night-api.onrender.com/join-session?device_id=$deviceId&code=$code'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await writeSessionId(data['data']['session_id']);
      return data;
    } else {
      throw Exception('Failed to join session: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> voteMovie(int movieId, bool liked) async {
    if (liked == null) {
      throw ArgumentError('liked must not be null');
    }

    final sessionId = await readSessionId();
    const deviceId = 'device_id';

    final url = Uri.https('movie-night-api.onrender.com', '/vote-movie', {
      'session_id': sessionId,
      'movie_id': movieId.toString(),
      'vote': liked.toString(),
    });

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to vote for movie: ${response.statusCode}');
      }
    } catch (error) {
      print('Failed to vote for movie: $error');
      return {};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchMovies(int page) async {
    const apiKey = '70c3d0c62aaefffac0005625f1c2de14';
    final url =
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&page=$page';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      return data['results'].cast<Map<String, dynamic>>();
    } catch (error) {
      print('Failed to fetch movies: $error');
      return [];
    }
  }
}
