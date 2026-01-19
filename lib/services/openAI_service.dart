import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String> generateText(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/responses');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-5-mini',
          'input': [
            {
              "role": "system",
              "content": [
                {
                  "type": "input_text",
                  "text": "You are a helpful assistant that plans travel and returns strict JSON only. Do not include markdown, extra text, or code fences."
                }
              ]
            },
            {
              "role": "user",
              "content": [
                {"type": "input_text", "text": prompt}
              ]
            },
          ],
          'max_output_tokens': 10000, 
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));

        final outputText = responseBody['output_text'];
        if (outputText is String && outputText.isNotEmpty) {
          return outputText.trim();
        }

        final output = responseBody['output'];
        if (output is List) {
          for (final item in output) {
            if (item is Map && item['content'] is List) {
              for (final part in item['content']) {
                if (part is Map && part['text'] is String) {
                  return (part['text'] as String).trim();
                }
              }
            }
          }
        }
        throw Exception('Unexpected response format from OpenAI');
      } else {
        print('Failed to generate text. Status code: ${response.statusCode}. Response body: ${response.body}');
        throw Exception('Failed to generate text. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception caught: $e');
      throw Exception('Error occurred while generating text: $e');
    }
  }
}
