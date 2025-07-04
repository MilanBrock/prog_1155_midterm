import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// The OpenAIService is capable of sending a request to the API for a chat completion, which returns a text response based on the prompt.
class OpenAIService {
  final String _apiKey = dotenv.env['OPENAI_API_KEY']!;

  Future<String?> getAdviceFromOpenAI(String tasks) async {
    const url = 'https://api.openai.com/v1/chat/completions';

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4o-mini',
        'messages': [
          {'role': 'system', 'content': 'You are a going to help the user create a step by step plan to tackle their planned tasks. Give them a short guide on which the order the tasks should be finished. Keep in mind the priority and the location. Keep it short and concise'},
          {'role': 'user', 'content': 'These are my tasks: $tasks'}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print('Failed to fetch advice: ${response.body}');
      return null;
    }
  }
}
