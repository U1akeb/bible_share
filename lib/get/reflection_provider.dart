import 'package:flutter/material.dart';
import 'package:bible_share/get/crud_api.dart';

class ReflectionProvider with ChangeNotifier {
  List<ReflectionPost> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<ReflectionPost> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ReflectionProvider() {
    loadPosts();
  }

  Future<void> loadPosts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); 

    try {
      _posts = await CrudApi.fetchReflections();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); 
    }
  }

  Future<void> createPost(ReflectionPost post) async {
    _isLoading = true;
    notifyListeners();
    try {
      await CrudApi.createReflection(post);
      await loadPosts(); 
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow; 
    }
  }

  Future<void> updatePost(ReflectionPost post) async {
    _isLoading = true;
    notifyListeners();
    try {
      await CrudApi.updateReflection(post);
      await loadPosts(); 
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    _isLoading = true;
    notifyListeners();
    try {
      await CrudApi.deleteReflection(id);
      await loadPosts(); 
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
