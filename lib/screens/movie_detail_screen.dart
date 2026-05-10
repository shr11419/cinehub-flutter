import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../providers/watchlist_provider.dart';
import '../providers/stats_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_row.dart';
import '../widgets/video_player_sheet.dart';
import '../widgets/ai_companion_sheet.dart';

class MovieDetailScreen extends StatefulWidget {
  final int movieId;

  const MovieDetailScreen({
    super.key,
    required this.movieId,
  });

  @override
  State<MovieDetailScreen> createState() =>
      _MovieDetailScreenState();
}

class _MovieDetailScreenState
    extends State<MovieDetailScreen> {
  Movie? movie;
  String? trailerKey;
  List<CastMember> cast = [];
  List<Movie> similar = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([
        TmdbService.getMovieDetails(widget.movieId),
        TmdbService.getTrailerKey(widget.movieId),
        TmdbService.getMovieCredits(widget.movieId),
        TmdbService.getSimilarMovies(widget.movieId),
      ]);

      setState(() {
        movie = results[0] as Movie;
        trailerKey = results[1] as String?;
        cast = results[2] as List<CastMember>;
        similar = results[3] as List<Movie>;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  void _playTrailer() {
    if (trailerKey == null) return;

    if (movie != null) {
      context.read<StatsProvider>().logWatch(movie!);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          VideoPlayerSheet(videoKey: trailerKey!),
    );
  }

  void _openCompanion() {
    if (movie == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiCompanionSheet(movie: movie!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.gold,
          ),
        ),
      );
    }

    if (movie == null) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Text(
                'Movie not found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: AppColors.gold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final watchlist =
        context.watch<WatchlistProvider>();

    final saved =
        watchlist.isInWatchlist(movie!.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          if (movie!.backdropUrl.isNotEmpty)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: movie!.backdropUrl,
                fit: BoxFit.cover,
              ),
            ),

          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 10,
                sigmaY: 10,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),

          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.bg.withOpacity(0.3),
                    AppColors.bg.withOpacity(0.9),
                    AppColors.bg,
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),

          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                leading: IconButton(
                  onPressed: () => context.pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.bg3
                          .withOpacity(0.8),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color:
                          AppColors.textPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          if (movie!
                              .posterUrl
                              .isNotEmpty)
                            ClipRRect(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          12),
                              child:
                                  CachedNetworkImage(
                                imageUrl:
                                    movie!
                                        .posterUrl,
                                width: 120,
                                height: 180,
                                fit:
                                    BoxFit.cover,
                              ),
                            ),

                          const SizedBox(
                              width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  movie!.title,
                                  style:
                                      const TextStyle(
                                    fontSize:
                                        22,
                                    fontWeight:
                                        FontWeight
                                            .w900,
                                    color:
                                        AppColors
                                            .textPrimary,
                                    height:
                                        1.2,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        8),

                                Wrap(
                                  spacing: 12,
                                  children: [
                                    _metaChip(
                                      '⭐ ${movie!.ratingString}',
                                      color:
                                          AppColors
                                              .gold,
                                    ),
                                    _metaChip(
                                        movie!
                                            .year),
                                    if (movie!
                                        .runtimeString
                                        .isNotEmpty)
                                      _metaChip(
                                        movie!
                                            .runtimeString,
                                      ),
                                  ],
                                ),

                                const SizedBox(
                                    height:
                                        12),

                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children:
                                      movie!
                                          .genres
                                          .take(
                                              3)
                                          .map(
                                            (
                                              g,
                                            ) =>
                                                _genreChip(
                                              g.name,
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                          height: 24),

                      Text(
                        movie!.overview ??
                            '',
                        style:
                            const TextStyle(
                          fontSize: 14,
                          color: AppColors
                              .textSecondary,
                          height: 1.7,
                        ),
                      ),

                      const SizedBox(
                          height: 24),

                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            ElevatedButton.icon(
                          onPressed:
                              trailerKey !=
                                      null
                                  ? _playTrailer
                                  : null,
                          icon: const Icon(
                            Icons
                                .play_arrow_rounded,
                          ),
                          label: Text(
                            trailerKey !=
                                    null
                                ? 'Play Trailer'
                                : 'No Trailer Available',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors
                                    .gold,
                            foregroundColor:
                                AppColors
                                    .bg,
                            padding:
                                const EdgeInsets.symmetric(
                              vertical:
                                  14,
                            ),
                            shape:
                                const StadiumBorder(),
                          ),
                        ),
                      ),

                      const SizedBox(
                          height: 12),

                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed: () {
                                watchlist
                                    .toggleWatchlist(
                                  movie!,
                                );
                              },
                              icon: Icon(
                                saved
                                    ? Icons
                                        .bookmark_rounded
                                    : Icons
                                        .bookmark_border_rounded,
                              ),
                              label: Text(
                                saved
                                    ? 'Saved'
                                    : 'Watchlist',
                              ),
                            ),
                          ),

                          const SizedBox(
                              width: 10),

                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed:
                                  _openCompanion,
                              icon:
                                  const Icon(
                                Icons
                                    .smart_toy_rounded,
                              ),
                              label:
                                  const Text(
                                'Ask AI',
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (cast.isNotEmpty) ...[
                        const SizedBox(
                            height: 30),

                        const Text(
                          'Cast',
                          style:
                              TextStyle(
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .w700,
                            color:
                                AppColors
                                    .textPrimary,
                          ),
                        ),

                        const SizedBox(
                            height: 12),

                        SizedBox(
                          height: 100,
                          child:
                              ListView.separated(
                            scrollDirection:
                                Axis.horizontal,
                            itemCount:
                                cast.length,
                            separatorBuilder:
                                (_, __) =>
                                    const SizedBox(
                              width: 14,
                            ),
                            itemBuilder:
                                (_, i) =>
                                    _castMember(
                              cast[i],
                            ),
                          ),
                        ),
                      ],

                      if (similar
                          .isNotEmpty) ...[
                        const SizedBox(
                            height: 28),

                        MovieRow(
                          title:
                              'Similar Movies',
                          movies:
                              similar,
                        ),
                      ],

                      const SizedBox(
                          height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(
    String text, {
    Color? color,
  }) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color:
            color ??
            AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _genreChip(String name) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 11,
          color:
              AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _castMember(
      CastMember member) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor:
                AppColors.bg3,
            backgroundImage:
                member.photoUrl
                        .isNotEmpty
                    ? CachedNetworkImageProvider(
                        member.photoUrl,
                      )
                    : null,
            child:
                member.photoUrl.isEmpty
                    ? const Icon(
                        Icons
                            .person_rounded,
                        color: AppColors
                            .textTertiary,
                      )
                    : null,
          ),

          const SizedBox(height: 6),

          Text(
            member.name,
            maxLines: 2,
            textAlign:
                TextAlign.center,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              color:
                  AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}