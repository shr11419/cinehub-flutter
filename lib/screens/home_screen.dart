import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hero_banner.dart';
import '../widgets/movie_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {

  List<Movie> trending = [];
  List<Movie> topRated = [];
  List<Movie> nowPlaying = [];
  List<Movie> popular = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final results = await Future.wait([
        TmdbService.getTrending(),
        TmdbService.getTopRated(),
        TmdbService.getNowPlaying(),
        TmdbService.getPopular(),
      ]);

      setState(() {
        trending = results[0];
        topRated = results[1];
        nowPlaying = results[2];
        popular = results[3];
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.gold,
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  toolbarHeight: 70,
                  backgroundColor:
                      AppColors.bg2.withOpacity(0.9),
                  flexibleSpace:
                      _navbar(context),
                ),

                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      if (trending.isNotEmpty)
                        HeroBanner(
                          movie: trending.first,
                        ),

                      const SizedBox(height: 24),

                      MovieRow(
                        title:
                            'Trending this week',
                        movies: trending,
                      ),

                      const SizedBox(height: 28),

                      MovieRow(
                        title: 'Now Playing',
                        movies: nowPlaying,
                      ),

                      const SizedBox(height: 28),

                      MovieRow(
                        title: 'Top Rated',
                        movies: topRated,
                      ),

                      const SizedBox(height: 28),

                      MovieRow(
                        title: 'Popular',
                        movies: popular,
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),

      bottomNavigationBar:
          _bottomNav(context),
    );
  }

  Widget _navbar(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 18,
      ),
      child: Row(
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.w900,
                fontFamily: 'Georgia',
              ),
              children: [
                TextSpan(
                  text: 'Cine',
                  style: TextStyle(
                    color:
                        AppColors.textPrimary,
                  ),
                ),
                TextSpan(
                  text: 'Hub',
                  style: TextStyle(
                    color:
                        AppColors.gold,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
          Container(
  decoration: BoxDecoration(
    color: AppColors.bg3,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppColors.border,
    ),
  ),
  child: IconButton(
    onPressed: () => context.push('/search'),
    icon: const Icon(
      Icons.search_rounded,
      color: AppColors.gold,
      size: 22,
    ),
  ),
),
          
        ],
      ),
    );
  }

  Widget _bottomNav(
      BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.bg2,
        border: Border(
          top: BorderSide(
            color: AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          _navItem(
            context,
            Icons.home_rounded,
            'Home',
            '/',
          ),

          _navItem(
            context,
            Icons.movie_filter_rounded,
            'Free',
            '/free',
          ),

          _navItem(
            context,
            Icons.mood_rounded,
            'Mood',
            '/mood',
          ),

          _navItem(
            context,
            Icons.bookmark_rounded,
            'Watchlist',
            '/watchlist',
          ),

          _navItem(
            context,
            Icons.bar_chart_rounded,
            'Stats',
            '/stats',
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {

    final current =
        GoRouterState.of(context)
            .uri
            .toString();

    final active = current == route;

    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.go(route),
        behavior:
            HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: active
                  ? AppColors.gold
                  : AppColors
                      .textTertiary,
              size: 22,
            ),

            const SizedBox(height: 3),

            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: active
                    ? AppColors.gold
                    : AppColors
                        .textTertiary,
                fontWeight: active
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}