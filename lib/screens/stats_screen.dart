import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';
import 'package:go_router/go_router.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    if (stats.watched.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          backgroundColor: AppColors.bg2,
          title: const Text('My Stats'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('📊', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text('No watch history yet',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 16)),
              SizedBox(height: 8),
              Text('Watch movies to see your stats',
                  style: TextStyle(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }

    final genres = stats.genreCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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

  title: const Text('My Stats'),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // stat cards
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
              children: [
                _statCard('${stats.totalMovies}', 'Movies Watched'),
                _statCard('${stats.totalMinutes ~/ 60}h',
                    'Total Watch Time'),
                _statCard('⭐ ${stats.avgRating.toStringAsFixed(1)}',
                    'Avg Rating'),
                _statCard(stats.topGenre, 'Top Genre'),
              ],
            ),

            const SizedBox(height: 28),

            // genre breakdown
            if (genres.isNotEmpty) ...[
              const Text(
                'Genre Breakdown',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              ...genres.take(6).map((entry) => _genreBar(
                    entry.key,
                    entry.value,
                    stats.totalMovies,
                  )),
            ],

            const SizedBox(height: 28),

            // recently watched
            const Text(
              'Recently Watched',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: stats.watched.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final w = stats.watched.reversed.toList()[i];
                  return MovieCard(movie: w.movie);
                },
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _statCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _genreBar(String genre, int count, int total) {
    final percent = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(genre,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13)),
              Text('$count',
                  style: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.bg4,
              valueColor: const AlwaysStoppedAnimation(AppColors.gold),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}