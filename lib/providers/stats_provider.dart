import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class WatchedMovie {
  final Movie movie;
  final DateTime watchedAt;

  WatchedMovie({required this.movie, required this.watchedAt});
}

class StatsProvider extends ChangeNotifier {
  List<WatchedMovie> _watched = [];

  List<WatchedMovie> get watched => _watched;

  StatsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cinehub_watched');
    if (data != null) {
      final list = json.decode(data) as List;
      _watched = list.map((item) => WatchedMovie(
        movie: Movie.fromJson(item['movie']),
        watchedAt: DateTime.parse(item['watchedAt']),
      )).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _watched.map((w) => {
      'movie': w.movie.toJson(),
      'watchedAt': w.watchedAt.toIso8601String(),
    }).toList();
    await prefs.setString('cinehub_watched', json.encode(list));
  }

  void logWatch(Movie movie) {
    if (_watched.any((w) => w.movie.id == movie.id)) return;
    _watched.add(WatchedMovie(movie: movie, watchedAt: DateTime.now()));
    notifyListeners();
    _save();
  }

  void clearStats() {
    _watched.clear();
    notifyListeners();
    _save();
  }

  int get totalMovies => _watched.length;

  int get totalMinutes =>
      _watched.fold(0, (sum, w) => sum + (w.movie.runtime ?? 0));

  double get avgRating {
    if (_watched.isEmpty) return 0;
    final total = _watched.fold<double>(
      0, (sum, w) => sum + (w.movie.voteAverage ?? 0));
    return total / _watched.length;
  }

  Map<String, int> get genreCounts {
    final counts = <String, int>{};
    for (final w in _watched) {
      for (final g in w.movie.genres) {
        counts[g.name] = (counts[g.name] ?? 0) + 1;
      }
    }
    return counts;
  }

  String get topGenre {
    if (genreCounts.isEmpty) return '—';
    return genreCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}