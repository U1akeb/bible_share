import 'dart:convert';
import 'package:http/http.dart' as http;

class ReflectionPost {
  String? id;
  final String title;
  final String verseText;
  final String verseReference;
  final String reflection;

  ReflectionPost({
    this.id,
    required this.title,
    required this.verseText,
    required this.verseReference,
    required this.reflection,
  });

  factory ReflectionPost.fromJson(Map<String, dynamic> json) {
    return ReflectionPost(
      id: json['id'],
      title: json['title'],
      verseText: json['verseText'],
      verseReference: json['verseReference'],
      reflection: json['reflection'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'verseText': verseText,
      'verseReference': verseReference,
      'reflection': reflection,
    };
  }
}

class CrudApi {
  static const String baseUrl =
      'https://6a0b71545aa893e1015a422e.mockapi.io/reflections';

  static Future<List<ReflectionPost>> fetchReflections() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => ReflectionPost.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load reflections');
    }
  }

  static Future<void> createReflection(ReflectionPost post) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create reflection: ${response.statusCode}');
    }
  }

  static Future<void> updateReflection(ReflectionPost post) async {
    if (post.id == null) return;
    final response = await http.put(
      Uri.parse('$baseUrl/${post.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(post.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to update reflection: ${response.statusCode}');
    }
  }

  static Future<void> deleteReflection(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete reflection: ${response.statusCode}');
    }
  }
}
