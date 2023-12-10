import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies/utils/http_helper.dart';

class SelectMovieScreen extends StatefulWidget {
  const SelectMovieScreen({super.key});

  @override
  State<SelectMovieScreen> createState() => _SelectMovieScreenState();
}

class _SelectMovieScreenState extends State<SelectMovieScreen> {
  List<Map<String, dynamic>> movies = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    printSessionId();
    fetchMovies();
  }

  Future<void> printSessionId() async {
    final sessionId = await HttpHelper.readSessionId();
    print('Session ID: $sessionId');
  }

  Future<void> fetchMovies() async {
    final newMovies = await HttpHelper.fetchMovies(1);

    setState(() {
      movies = newMovies;
    });
  }

  Future<void> fetchMoreMovies() async {
    final newMovies = await HttpHelper.fetchMovies(2);

    setState(() {
      movies.addAll(newMovies);
    });
  }

  Future<void> voteMovie(bool liked, String movieTitle, String moviePosterPath,
      String movieDescription) async {
    final movieId = movies[currentIndex]['id'];

    try {
      final data = await HttpHelper.voteMovie(movieId, liked);

      if (data['data'] == null || data['data']['match'] == null) {
        throw Exception('Response from server does not include a match field');
      }
      print(data['data']['match']);
      if (data['data']['match']) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Movie match: $movieTitle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    'https://image.tmdb.org/t/p/w500$moviePosterPath',
                    width: 200.0,
                    height: 300.0,
                  ),
                  const SizedBox(height: 20.0),
                  Text(movieDescription)
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      print('Failed to vote movie: $error');
    }

    setState(() {
      currentIndex++;
      print('Number of movies: ${movies.length}');
    });

    if (currentIndex == movies.length - 1) {
      await fetchMoreMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final movie = movies[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Movie'),
      ),
      body: Center(
        child: SizedBox(
          width: 350.0,
          height: 600.0,
          child: Dismissible(
            key: Key(movie['id'].toString()),
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                voteMovie(false, movie['title'], movie['poster_path'],
                    movie['overview']);
              } else if (direction == DismissDirection.startToEnd) {
                voteMovie(true, movie['title'], movie['poster_path'],
                    movie['overview']);
              }
            },
            background: Container(
              child: const Icon(
                Icons.thumb_up,
                color: Colors.purple,
                size: 100.0,
              ),
            ),
            secondaryBackground: Container(
              child: const Icon(
                Icons.thumb_down,
                color: Colors.purple,
                size: 100.0,
              ),
            ),
            child: SizedBox(
              width: 350.0,
              height: 600.0,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.network(
                      'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Vote Average: ${movie['vote_average']}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Release date: ${movie['release_date']}',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
