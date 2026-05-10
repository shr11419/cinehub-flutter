import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import 'package:go_router/go_router.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>().watchlist;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
  backgroundColor: AppColors.bg2,

  leading: IconButton(
    onPressed: () => context.go('/'),
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
      color: AppColors.textPrimary,
      size: 18,
    ),
  ),

  title: const Text('My Watchlist'),
),
      body: watchlist.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🎬',
                      style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 16),
                  const Text('Your watchlist is empty',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  const Text('Save movies to watch later',
                      style: TextStyle(color: AppColors.textTertiary)),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.55,
              ),
              itemCount: watchlist.length,
              itemBuilder: (_, i) => MovieCard(
                movie: watchlist[i],
                width: double.infinity,
              ),
            ),
    );
  }
}