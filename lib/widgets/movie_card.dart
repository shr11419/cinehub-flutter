import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../providers/watchlist_provider.dart';
import '../theme/app_theme.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final double width;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 130,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnim = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final watchlist = context.watch<WatchlistProvider>();
    final saved = watchlist.isInWatchlist(widget.movie.id);

    return GestureDetector(
      onTap: () => context.push('/movie/${widget.movie.id}'),
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: widget.movie.posterUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: widget.movie.posterUrl,
                            width: widget.width,
                            height: widget.width * 1.45,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              width: widget.width,
                              height: widget.width * 1.45,
                              color: AppColors.bg3,
                            ),
                            errorWidget: (_, __, ___) => Container(
                              width: widget.width,
                              height: widget.width * 1.45,
                              color: AppColors.bg3,
                              child: const Icon(Icons.movie_rounded,
                                  color: AppColors.textTertiary),
                            ),
                          )
                        : Container(
                            width: widget.width,
                            height: widget.width * 1.45,
                            color: AppColors.bg3,
                            child: const Icon(Icons.movie_rounded,
                                color: AppColors.textTertiary),
                          ),
                  ),

                  // rating badge
                  Positioned(
                    bottom: 6,
                    left: 8,
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 12),
                        const SizedBox(width: 3),
                        Text(
                          widget.movie.ratingString,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // bookmark
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () =>
                          watchlist.toggleWatchlist(widget.movie),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.bg.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: saved
                                ? AppColors.borderGold
                                : AppColors.border,
                          ),
                        ),
                        child: Icon(
                          saved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: saved
                              ? AppColors.gold
                              : AppColors.textSecondary,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                widget.movie.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                widget.movie.year,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}