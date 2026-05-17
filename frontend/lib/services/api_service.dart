import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/resource.dart';
import '../models/chat_response.dart';

class ApiService {
  // Change this based on your setup:
  // Android Emulator: http://10.0.2.2:3000
  // Real device on same Wi-Fi: http://192.168.x.x:3000 (your PC IP)
  static const String baseUrl = "http://10.0.2.2:3000";

  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  // Get all resources
  static Future<List<Resource>> getAllResources({
    String? category,
    String? difficulty,
    String? sort,
  }) async {
    try {
      String url = '$baseUrl/api/resources';
      Map<String, String> queryParams = {};

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (difficulty != null && difficulty.isNotEmpty) {
        queryParams['difficulty'] = difficulty;
      }
      if (sort != null && sort.isNotEmpty) {
        queryParams['sort'] = sort;
      }

      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> resourcesJson = jsonData['data'] ?? [];
        return resourcesJson
            .map((json) => Resource.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load resources: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching resources: $e');
      rethrow;
    }
  }

  // Get single resource
  static Future<Resource> getResourceById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/resources/$id'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return Resource.fromJson(jsonData['data']);
      } else {
        throw Exception('Failed to load resource: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching resource: $e');
      rethrow;
    }
  }

  // Create new resource
  static Future<int> createResource(Resource resource) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/resources'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(resource.toJson()),
      );

      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        return jsonData['resourceId'] ?? 0;
      } else {
        throw Exception('Failed to create resource: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating resource: $e');
      rethrow;
    }
  }

  // Chat - ask chatbot a question
  static Future<ChatResponse> askChatbot(String question) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ChatResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to get chat response: ${response.statusCode}');
      }
    } catch (e) {
      print('Error asking chatbot: $e');
      rethrow;
    }
  }

  // Get chat history
  static Future<List<ChatResponse>> getChatHistory({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/chat/history?limit=$limit'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> chatsJson = jsonData['data'] ?? [];
        return chatsJson
            .map((json) => ChatResponse.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load chat history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching chat history: $e');
      rethrow;
    }
  }
}
