import 'package:flutter/material.dart';
import 'package:foodapp/data/models/banner_model.dart';
import 'package:foodapp/data/repositories/banner_repository.dart';

class BannerViewmodel extends ChangeNotifier {
  List<BannerModel> listBanner = [];
  bool isLoading = false;
  final bannerRepository = BannerRepository.instance;
  Future<void> getListBanner() async {
    try {
      isLoading = true;
      notifyListeners();
      listBanner = await bannerRepository.getListBanner();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      throw "Fail $e";
    }
  }
}
