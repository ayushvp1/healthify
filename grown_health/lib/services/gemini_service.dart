import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image/image.dart' as img;
import '../models/calorie_analysis_result.dart';
import '../models/chat_message.dart';

class GeminiService {
  static GenerativeModel? _model;
  static String? _apiKey;

  // Placeholder key - in production use environment variables
  static const String _defaultApiKey =
      'AIzaSyCQeJbiQICBtBlT17DJ8VGWqfe0GqOAtJI';

  static void initialize({String? apiKey}) {
    _apiKey =
        apiKey ??
        const String.fromEnvironment(
          'GEMINI_API_KEY',
          defaultValue: _defaultApiKey,
        );
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey!);
  }

  static Future<String> chatWithAI(
    String userMessage, {
    List<ChatMessage>? history,
  }) async {
    try {
      if (_model == null) initialize();

      // Build conversation context
      String context = '';
      if (history != null && history.isNotEmpty) {
        context = 'Previous conversation history:\n';
        final recentMessages = history.length > 6
            ? history.sublist(history.length - 6)
            : history;

        for (final msg in recentMessages) {
          context += '${msg.isUser ? "User" : "Assistant"}: ${msg.text}\n';
        }
        context += '\n';
      }

      final prompt =
          '''
You are a helpful nutrition and wellness assistant for the "Grown Health" app.
$context
User: $userMessage

Please provide a helpful, conversational response about health, nutrition, or fitness.
- Keep it concise (2-4 sentences).
- Focus on practical, evidence-based advice.
- If the question is unrelated to health/fitness, politely redirect the user.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ??
          "I'm sorry, I couldn't process that. How else can I help you with your health goals?";
    } catch (e) {
      return "I'm having a bit of trouble connecting right now. Let's try again in a moment!";
    }
  }

  static Future<CalorieAnalysisResult> analyzeFood(File imageFile) async {
    try {
      if (_model == null) initialize();

      // For food analysis we want JSON output
      final jsonModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey!,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      // Read and process the image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Could not decode image');
      }

      // Resize image to reduce API costs while maintaining quality
      final resizedImage = img.copyResize(image, width: 512);
      final resizedBytes = img.encodeJpg(resizedImage);

      // Create the prompt for food analysis
      const prompt = '''
You are a nutrition analysis assistant. Analyze the provided food image and RETURN VALID JSON ONLY that strictly conforms to the schema below. Do not include any extra text, explanations, markdown, or code fences. Numbers must be plain numbers (not strings). Keys must match exactly.

{
  "food_items": [
    {
      "name": "Food name",
      "calories": 0,
      "description": "Brief description of the food"
    }
  ],
  "total_calories": 0,
  "analysis_confidence": 0,
  "recommendations": "Brief healthy eating recommendations",
  "warning": "Any dietary warnings or notes or null"
}

Rules:
- Identify all visible food items in the image and estimate calories per realistic portion in kcal.
- "total_calories" must be the estimated total kcal for the entire plate. 
- "analysis_confidence" must be an integer 0-100.
- Respond with the JSON object ONLY.
''';

      // Create content with image and prompt
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', Uint8List.fromList(resizedBytes)),
        ]),
      ];

      // Generate response
      final response = await jsonModel.generateContent(content);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('Empty response from Gemini API');
      }

      // Parse the JSON response
      return CalorieAnalysisResult.fromGeminiResponse(response.text!);
    } catch (e) {
      throw Exception('Failed to analyze food: ${e.toString()}');
    }
  }

  static Future<String> generateFoodRecommendations() async {
    try {
      if (_model == null) initialize();

      const prompt =
          "Provide a single, daily, practical nutrition tip for someone looking to maintain a healthy lifestyle. Keep it under 20 words and making it sound encouraging.";

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text?.trim() ??
          "Stay hydrated! Drinking water throughout the day keeps your energy levels high.";
    } catch (e) {
      return "Focus on whole foods for sustained energy today!";
    }
  }

  static Future<String> generateFoodPlan({
    required int mealsPerDay,
    required String goal,
  }) async {
    try {
      if (_model == null) initialize();

      final jsonModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey!,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );

      final prompt =
          '''
Generate a daily meal plan for $mealsPerDay meals with the goal: $goal.
The plan should be diverse, healthy, and tailored to the goal.

RETURN VALID JSON ONLY:
{
  "total_calories": 2000,
  "goal_summary": "Encouraging summary about the goal",
  "meals": [
    {
      "name": "Breakfast",
      "time": "08:00 AM",
      "calories": 450,
      "items": [
        {"name": "Item Name", "description": "Quick description or portion"}
      ]
    }
  ]
}
''';

      final content = [Content.text(prompt)];
      final response = await jsonModel.generateContent(content);

      return response.text ?? "";
    } catch (e) {
      throw Exception('Failed to generate food plan');
    }
  }

  static Future<String> analyzeHealthAssessment({
    required Map<String, int> scores,
    required List<Map<String, dynamic>> recommendations,
    required int totalAnswered,
  }) async {
    try {
      if (_model == null) initialize();

      final scoreDetails = scores.entries
          .map((e) => '- ${e.key}: ${e.value}%')
          .join('\n');
      final recDetails = recommendations
          .map((r) => '- [${r['category']}] ${r['title']}: ${r['description']}')
          .join('\n');

      final prompt =
          '''
You are a senior health and wellness consultant for the "Grown Health" app.
Analyze the following health assessment results for a user:

SCORES BY CATEGORY:
$scoreDetails

EXISTING RECOMMENDATIONS:
$recDetails

TOTAL QUESTIONS ANSWERED: $totalAnswered

TASK:
Provide a comprehensive, encouraging, and highly personalized health deeper dive.
1. Highlight their greatest strength.
2. Identify the most critical area for improvement.
3. Provide 3 specific, actionable "Power Moves" they can start TODAY based on their data.
4. Explain WHY these moves will help them specifically, based on their score balance.

CONTRAINTS:
- Keep the tone professional, empathetic, and motivating.
- Use healthy "coaching" language.
- Format with clear headings and bullet points.
- Maximum 250 words.
''';

      final content = [Content.text(prompt)];
      final response = await _model!.generateContent(content);

      return response.text ??
          "I couldn't generate the analysis right now. Please try again later!";
    } catch (e) {
      return "There was an error generating your AI Health Report. Let's try again in a moment!";
    }
  }
}
