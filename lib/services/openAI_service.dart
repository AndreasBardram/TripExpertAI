import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAIService {
  final String apiKey;

  OpenAIService(this.apiKey);

  Future<String> generateText(String prompt) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',  // or 'gpt-3.5-turbo'
          'messages': [
            {"role": "system", "content": "You are a helpful assistant, that helps users plan their next travel"},
            {"role": "user", "content": prompt},
          ],
          'temperature': 0.6,
          'max_tokens': 4000, 
          'top_p': 0.8,
          'frequency_penalty': 0.0,  
          'presence_penalty': 0.0, 
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(utf8.decode(response.bodyBytes));
        return responseBody['choices'][0]['message']['content'].trim();
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
