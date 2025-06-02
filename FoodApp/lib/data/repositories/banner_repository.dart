import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/banner_model.dart';

class BannerRepository {
  static final BannerRepository instance = BannerRepository._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  BannerRepository._internal();

  Future<List<BannerModel>> getListBanner() async {
    try {
      final snapshot = await _firestore.collection('banner').get();
      return snapshot.docs.map(
        (e) {
          final data = e.data();
          return BannerModel.fromMap(data, e.id);
        },
      ).toList();
    } catch (e) {
      throw "Faile $e";
    }
  }
}
