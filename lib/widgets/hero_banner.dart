import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../theme/app_theme.dart';

class HeroBanner extends StatelessWidget {
  final Movie movie;

  const HeroBanner({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => context.push('/movie/${movie.id}'),
      child: SizedBox(
        height: screenHeight * 0.55,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // backdrop
            movie.backdropUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: movie.backdropUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: AppColors.bg2),
                    errorWidget: (_, __, ___) =>
                        Container(color: AppColors.bg2),
                  )
                : Container(color: AppColors.bg2),

            // gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.bg,
                    AppColors.bg.withOpacity(0.7),
                    AppColors.bg.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),

            // content
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // badges
                  Row(
                    children: [
                      _badge('⭐ ${movie.ratingString}'),
                      const SizedBox(width: 8),
                      _badge(movie.year),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // title
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // overview
                  Text(
                    movie.overview ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.push('/movie/${movie.id}'),
                        icon: const Icon(
                            Icons.play_arrow_rounded, size: 18),
                        label: const Text('Play Trailer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.bg,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: const StadiumBorder(),
                          textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ),

                      const SizedBox(width: 10),

                      OutlinedButton.icon(
                        onPressed: () =>
                            context.push('/movie/${movie.id}'),
                        icon: const Icon(
                            Icons.info_outline_rounded, size: 16),
                        label: const Text('More Info'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: BorderSide(
                            color: AppColors.textPrimary
                                .withOpacity(0.3),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: const StadiumBorder(),
                          textStyle:
                              const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.goldGlow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGold),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.gold,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}