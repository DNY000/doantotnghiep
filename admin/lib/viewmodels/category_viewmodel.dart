import 'package:admin/models/category_model.dart';
import 'package:flutter/foundation.dart';
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

  Future<void> deleteCategory(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.deleteCategory(id);
      _categories.removeWhere((category) => category.id == id);

      if (kDebugMode) {
        print('Deleted category with id: $id');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error deleting category: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCategory(String id, CategoryModel category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateCategory(id, category);
      _categories.removeWhere((category) => category.id == id);
      _categories.add(category);

      if (kDebugMode) {
        print('Updated category with id: $id');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating category: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.addCategory(category);
      _categories.add(category);

      if (kDebugMode) {
        print('Added category: ${category.name}');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error adding category: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
