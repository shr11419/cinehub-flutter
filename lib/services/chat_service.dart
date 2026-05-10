import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';
import '../models/movie.dart';

class ChatService {
  static String get _base =>
      dotenv.env['API_BASE'] ?? 'http://10.0.2.2:3001';

  static Future<String> sendMessage({
    required List<ChatMessage> messages,
    Movie? movieContext,
  }) async {
    final body = <String, dynamic>{
      'messages': messages.map((m) => m.toJson()).toList(),
      if (movieContext != null)
        'movieContext': {
          'title': movieContext.title,
          'year': movieContext.year,
          'rating': movieContext.voteAverage,
          'overview': movieContext.overview ?? '',
          'genres': movieContext.genreNames,
        },
    };

    final res = await http.post(
      Uri.parse('$_base/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );

    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      return data['reply'] ?? "Sorry, I couldn't respond!";
    }
    throw Exception('Chat API error: ${res.statusCode}');
  }

  static Future<Map<String, dynamic>> getMoodMovies({
    required String mood,
    required String prompt,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/api/mood'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'mood': mood, 'prompt': prompt}),
    );

    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    throw Exception('Mood API error');
  }
}