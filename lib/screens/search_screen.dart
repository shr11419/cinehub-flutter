import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<Movie> results = [];
  bool loading = false;
  bool searched = false;

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    setState(() { loading = true; searched = true; });
    try {
      final r = await TmdbService.searchMovies(query);
      setState(() { results = r; loading = false; });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg2,
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Search films...',
            hintStyle: TextStyle(color: AppColors.textTertiary),
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : searched && results.isEmpty
              ? const Center(
                  child: Text('No results found',
                      style: TextStyle(color: AppColors.textSecondary)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.55,
                  ),
                  itemCount: results.length,
                  itemBuilder: (_, i) => MovieCard(
                    movie: results[i],
                    width: double.infinity,
                  ),
                ),
    );
  }
}