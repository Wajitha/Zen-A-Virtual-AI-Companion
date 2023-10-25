
import 'dart:convert';

import 'package:zen/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> messages = [];

  String generateEmpatheticResponse(String message) {
    message = message.toLowerCase();

    if (message.contains('sad') ||
        message.contains('upset') ||
        message.contains('depressed')) {
      return "I'm sorry to hear that you're feeling down. Remember, it's okay to feel sad sometimes. I'm here to listen.";
    } else if (message.contains('happy') ||
        message.contains('joy') ||
        message.contains('excited')) {
      return "That's great to hear! I'm glad you're feeling happy. Keep up the positive vibes!";
    } else if (message.contains('tired') ||
        message.contains('exhausted') ||
        message.contains('drained')) {
      return "It sounds like you could use a break. Don't forget to take care of yourself and get some rest.";
    } else if (message.contains('stressed') ||
        message.contains('anxious') ||
        message.contains('overwhelmed')) {
      return "I'm sorry you're feeling stressed. Remember to take deep breaths and try to focus on one task at a time."
          " It's important to find ways to manage stress.";
    } else {
      return "I'm here to listen and support you. Let me know if there's anything specific you'd like to talk about.";
    }
  }

  Future<String> isArtPromptAPI(String prompt) async {
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              'role': 'user',
              'content':
              'Does this message want to generate an AI picture, image, art? $prompt . Simply answer with a yes or no.',
            }
          ],
          "max_tokens": 100,
        }),
      );
      print(res.body);
      if (res.statusCode == 200) {
        String content =
        jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'Yes':
          case 'yes':
          case 'Yes.':
          case 'yes.':
            final res = await dallEAPI(prompt);
            return res;
          default:
            final res = await chatGPTAPI(prompt);
            return res;
        }
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> chatGPTAPI(String prompt) async {
    // Generate an empathetic response
    final empatheticResponse = generateEmpatheticResponse(prompt);

    messages.add({
      'role': 'user',
      'content': prompt,
    });

    // Add the empathetic response to the message list
    messages.add({
      'role': 'assistant',
      'content': empatheticResponse,
    });

    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": messages,
          "max_tokens": 100,
        }),
      );

      if (res.statusCode == 200) {
        String content =
        jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
        return content;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> dallEAPI(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try {
      final res = await http.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          'prompt': prompt,
          'n': 1,
        }),
      );

      if (res.statusCode == 200) {
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occurred';
    } catch (e) {
      return e.toString();
    }
  }
}
