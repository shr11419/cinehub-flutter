import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/movie.dart';

class TmdbService {
  static String get _base =>
      dotenv.env['TMDB_BASE'] ?? 'https://api.themoviedb.org/3';
  static String get _key => dotenv.env['TMDB_KEY'] ?? '';

  static Future<Map<String, dynamic>> _get(
    String endpoint, {
    Map<String, String>? extra,
  }) async {
    final params = {
      'api_key': _key,
      'language': 'en-US',
      ...?extra,
    };
    final uri = Uri.parse('$_base$endpoint')
        .replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    throw Exception('TMDB error: ${res.statusCode}');
  }

  static Future<List<Movie>> getTrending() async {
    final data = await _get('/trending/movie/week');
    return (data['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();
  }

  static Future<List<Movie>> getTopRated() async {
    final data = await _get('/movie/top_rated');
    return (data['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();
  }

  static Future<List<Movie>> getNowPlaying() async {
    final data = await _get('/movie/now_playing');
    return (data['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();
  }

  static Future<List<Movie>> getPopular() async {
    final data = await _get('/movie/popular');
    return (data['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();
  }

  static Future<Movie> getMovieDetails(int id) async {
    final data = await _get('/movie/$id');
    return Movie.fromJson(data);
  }

  static Future<List<CastMember>> getMovieCredits(int id) async {
    final data = await _get('/movie/$id/credits');
    return (data['cast'] as List)
        .take(10)
        .map((c) => CastMember.fromJson(c))
        .toList();
  }

  static Future<List<Movie>> getSimilarMovies(int id) async {
    final data = await _get('/movie/$id/similar');
    return (data['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();
  }

  static Future<List<Movie>> searchMovies(
    String query, {
    int page = 1,
  }) async {
    final data = await _get('/search/movie', extra: {
      'query': query,
      'page': page.toString(),
    });
    return (data['results'] as List)
        .map((m) => Movie.fromJson(m))
        .toList();
  }

  static Future<String?> getTrailerKey(int id) async {
    final data = await _get('/movie/$id/videos');
    final results = data['results'] as List;
    final trailer = results.firstWhere(
      (v) => v['type'] == 'Trailer' && v['site'] == 'YouTube',
      orElse: () => null,
    );
    return trailer?['key'];
  }
}