import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class SummarizerService {
  final Dio _dio = Dio();
  final apiKey = dotenv.env['GEMINI_API_KEY'];

  Future<String?> summarizeText(String text) async {
    if (apiKey == null) {
      throw Exception('Gemini API key not found in environment variables');
    }

final prompt = """
Summarize the following text in a clear, structured, and concise manner.

- Extract the main points and organize them under headings.
- Use bullet points or numbered lists when appropriate.
- Format the summary as raw HTML.
- DO NOT include Markdown code blocks like \`\`\`html or \`\`\`.
- Just return the raw HTML content. No explanation or additional text.

Here is the text to summarize:

$text
""";


    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';
    final payload = {
      "contents": [
        {
          "parts": [
            {"text": prompt},
          ],
        },
      ],
      // 'prompt': text,
      // 'max_tokens': 1000,
      // 'temperature': 0.5,
    };
    try {
      final response = await _dio.post(url, data: payload);
      // Logger().i("response: ${cleanHtml(response.data['candidates'][0]['content']['parts'][0]['text'])}");
      return cleanHtml(response.data['candidates'][0]['content']['parts'][0]['text']);
    } catch (e) {
      return null;
    }
  }


  String cleanHtml(String response) {
  final htmlPattern = RegExp(r'```html\s*([\s\S]*?)\s*```', multiLine: true);
  final match = htmlPattern.firstMatch(response);
  return match != null ? match.group(1)?.trim() ?? response : response;
}

}
