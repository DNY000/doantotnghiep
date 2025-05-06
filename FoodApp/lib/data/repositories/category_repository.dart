import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _firestore.collection("categories").get();
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return CategoryModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách danh mục: $e');
    }
  }

  Future<CategoryModel> getCategoryById(String id) async {
    try {
      final snapshot = await _firestore.collection("categories").doc(id).get();
      return CategoryModel.fromMap(snapshot.data() ?? {}, snapshot.id);
    } catch (e) {
      throw Exception('Không thể lấy danh mục theo id: $e');
    }
  }
}
