import 'package:flutter/foundation.dart';
import '../data/models/category_model.dart';
import '../data/repositories/category_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _repository = CategoryRepository();
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _categories = await _repository.getCategories();

      if (kDebugMode) {
        print('Loaded ${_categories.length} categories');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading categories: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
