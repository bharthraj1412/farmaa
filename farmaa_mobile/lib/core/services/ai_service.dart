import 'package:dio/dio.dart';
import '../api/api_client.dart';

/// Service to handle AI Advisor chat logic
class AIService {
  AIService._();
  static final AIService instance = AIService._();

  final _dio = ApiClient().dio;

  /// Sends a list of messages to the AI backend and returns the response.
  Future<({String content, List<String> suggestions})> getChatResponse(
      List<Map<String, String>> messages) async {
    try {
      final response = await _dio.post('/ai/chat', data: {
        'messages': messages,
      });

      final data = response.data as Map<String, dynamic>;
      return (
        content: data['content'] as String,
        suggestions: List<String>.from(data['suggestions'] ?? []),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return (
          content:
              "I'm having trouble connecting to the Farmaa servers right now. Please check your internet connection.",
          suggestions: <String>["Try again", "Go to offline help"]
        );
      }
      return (
        content: "An error occurred while getting AI response: ${e.message}",
        suggestions: <String>[]
      );
    } catch (e) {
      return (
        content: "Something went wrong. Please try again later.",
        suggestions: <String>[]
      );
    }
  }
}
