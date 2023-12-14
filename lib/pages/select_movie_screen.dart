import 'package:flutter/material.dart';
import 'package:movies/utils/http_helper.dart';
import 'package:flutter/foundation.dart';

class SelectMovieScreen extends StatefulWidget {
  const SelectMovieScreen({super.key});

  @override
  State<SelectMovieScreen> createState() => _SelectMovieScreenState();
}

class _SelectMovieScreenState extends State<SelectMovieScreen> {
  List<Map<String, dynamic>> movies = [];
  int currentIndex = 0;
  static bool kDebugMode = !kReleaseMode && !kProfileMode;

  @override
  void initState() {
    super.initState();
    printSessionId();
    fetchMovies();
  }

  Future<void> printSessionId() async {
    final sessionId = await HttpHelper.readSessionId();
    if (kDebugMode) {
      print('Session ID: $sessionId');
    }
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

  Future<void> voteMovie(bool vote) async {
    var movieId = movies[currentIndex]['id'];

    try {
      final data = await HttpHelper.voteMovie(movieId, vote);

      if (data['data'] == null || data['data']['match'] == null) {
        throw Exception('Error: no data');
      }

      if (kDebugMode) {
        print(data);
        print('movieId: $movieId');
      }

      if (data['data']['match']) {
        final movieId = int.parse(data['data']['movie_id']);
        final movieData = await HttpHelper.fetchMovie(movieId);
        var movieTitle = movieData['title'];
        var moviePosterPath = movieData['poster_path'];
        var movieDescription = movieData['overview'];
        // ignore: use_build_context_synchronously
        showDialog(
          context: context,
          // Show the modal when the movie matches
          builder: (context) => AlertDialog(
            title: Text('Movie Match: $movieTitle'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.network(
                    moviePosterPath.isNotEmpty
                        ? 'https://image.tmdb.org/t/p/w500$moviePosterPath'
                        : 'assets/images/placeholder.png',
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
      if (kDebugMode) {
        print('Failed to vote movie: $error');
      }
    }

    setState(() {
      currentIndex++;
    });

    if (currentIndex == movies.length - 1) {
      await fetchMoreMovies();
    }

    movieId = null;
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
                voteMovie(false);
              } else if (direction == DismissDirection.startToEnd) {
                voteMovie(true);
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
                    child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/placeholder.png',
                      image: movie['poster_path'] != null &&
                              movie['poster_path'].isNotEmpty
                          ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                          : 'assets/images/placeholder.png',
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
