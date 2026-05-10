import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import '../services/chat_service.dart';
import '../theme/app_theme.dart';
import '../widgets/movie_card.dart';

const moods = [
  {'emoji': '😢', 'label': 'Feeling Sad',
   'prompt': 'deeply emotional and healing movies'},
  {'emoji': '😂', 'label': 'Want to Laugh',
   'prompt': 'hilarious comedy movies'},
  {'emoji': '😱', 'label': 'Thrill Me',
   'prompt': 'edge-of-your-seat thriller and horror movies'},
  {'emoji': '🥰', 'label': 'Romance',
   'prompt': 'beautiful romantic love story movies'},
  {'emoji': '🤯', 'label': 'Mind-Bending',
   'prompt': 'complex psychological sci-fi movies'},
  {'emoji': '🚀', 'label': 'Adventure',
   'prompt': 'epic adventure and action movies'},
  {'emoji': '😴', 'label': 'Background',
   'prompt': 'easy comfortable relaxing movies'},
  {'emoji': '👨‍👩‍👧', 'label': 'Family',
   'prompt': 'wholesome family-friendly movies'},
];

class MoodPickerScreen extends StatefulWidget {
  const MoodPickerScreen({super.key});

  @override
  State<MoodPickerScreen> createState() => _MoodPickerScreenState();
}

class _MoodPickerScreenState extends State<MoodPickerScreen> {
  String? selectedMood;
  List<Movie> movies = [];
  String aiMessage = '';
  bool loading = false;

  Future<void> _pickMood(Map mood) async {
    setState(() {
      selectedMood = mood['label'] as String;
      loading = true;
      movies = [];
      aiMessage = '';
    });

    try {
      final result = await ChatService.getMoodMovies(
        mood: mood['label'] as String,
        prompt: mood['prompt'] as String,
      );

      final titles = List<String>.from(result['movies'] ?? []);
      final msg = result['message'] ?? '';

      // search TMDB for each title
      final movieResults = await Future.wait(
        titles.map((title) => TmdbService.searchMovies(title)
            .then((r) => r.isNotEmpty ? r.first : null)
            .catchError((_) => null)),
      );

      setState(() {
        aiMessage = msg;
        movies = movieResults.whereType<Movie>().toList();
        loading = false;
      });
    } catch (e) {
      setState(() { loading = false; });
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

  title: const Text("What's your mood"),
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // mood grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.85,
              ),
              itemCount: moods.length,
              itemBuilder: (_, i) {
                final mood = moods[i];
                final active = selectedMood == mood['label'];
                return GestureDetector(
                  onTap: () => _pickMood(mood),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: active ? AppColors.goldGlow : AppColors.bg3,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: active ? AppColors.gold : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(mood['emoji']!,
                            style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 6),
                        Text(
                          mood['label']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: active
                                ? AppColors.gold
                                : AppColors.textSecondary,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            if (loading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.gold),
                    SizedBox(height: 12),
                    Text('Finding perfect movies...',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),

            if (aiMessage.isNotEmpty && !loading) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg3,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderGold),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🤖', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        aiMessage,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (movies.isNotEmpty && !loading) ...[
              const Text(
                'Picked for you',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.55,
                ),
                itemCount: movies.length,
                itemBuilder: (_, i) => MovieCard(
                  movie: movies[i],
                  width: double.infinity,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}