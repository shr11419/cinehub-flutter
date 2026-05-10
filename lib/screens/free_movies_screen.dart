import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class FreeMovie {
  final String identifier;
  final String title;
  final String? year;

  FreeMovie({
    required this.identifier,
    required this.title,
    this.year,
  });

  String get thumbUrl =>
      'https://archive.org/services/img/$identifier';

  String get watchUrl =>
      'https://archive.org/embed/$identifier';
}

class FreeMoviesScreen extends StatefulWidget {
  const FreeMoviesScreen({super.key});

  @override
  State<FreeMoviesScreen> createState() => _FreeMoviesScreenState();
}

class _FreeMoviesScreenState extends State<FreeMoviesScreen> {
  List<FreeMovie> movies = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uri = Uri.parse(
        'https://archive.org/advancedsearch.php'
        '?q=mediatype:movies+AND+subject:(feature+film)+AND+language:English'
        '&fl=identifier,title,year'
        '&sort[]=downloads+desc'
        '&output=json&rows=30&start=0',
      );

      final res = await http.get(uri);
      final data = json.decode(res.body);
      final docs = data['response']['docs'] as List;

      setState(() {
        movies = docs.map((d) => FreeMovie(
          identifier: d['identifier'] ?? '',
          title: d['title'] ?? 'Unknown',
          year: d['year']?.toString(),
        )).toList();
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> _openMovie(FreeMovie movie) async {
    final url = Uri.parse(
        'https://archive.org/details/${movie.identifier}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
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

  title: const Text('Free Movies'),
),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: movies.length,
              itemBuilder: (_, i) => _freeCard(movies[i]),
            ),
    );
  }

  Widget _freeCard(FreeMovie movie) {
    return GestureDetector(
      onTap: () => _openMovie(movie),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bg3,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: movie.thumbUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(
                  Icons.movie_rounded,
                  color: AppColors.textTertiary,
                  size: 40,
                ),
              ),
            ),

            // gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.bg.withOpacity(0.95),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // info
            Positioned(
              bottom: 10, left: 10, right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FREE badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.green.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'FREE',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  if (movie.year != null)
                    Text(
                      movie.year!,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),

            // play icon center
            const Center(
              child: Icon(
                Icons.play_circle_outline_rounded,
                color: Colors.white54,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}