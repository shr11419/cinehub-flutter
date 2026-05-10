import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';

class WatchlistProvider extends ChangeNotifier {
  List<Movie> _watchlist = [];

  List<Movie> get watchlist => _watchlist;

  WatchlistProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cinehub_watchlist');
    if (data != null) {
      final list = json.decode(data) as List;
      _watchlist = list.map((m) => Movie.fromJson(m)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'cinehub_watchlist',
      json.encode(_watchlist.map((m) => m.toJson()).toList()),
    );
  }

  bool isInWatchlist(int id) => _watchlist.any((m) => m.id == id);

  void toggleWatchlist(Movie movie) {
    if (isInWatchlist(movie.id)) {
      _watchlist.removeWhere((m) => m.id == movie.id);
    } else {
      _watchlist.add(movie);
    }
    notifyListeners();
    _save();
  }
}