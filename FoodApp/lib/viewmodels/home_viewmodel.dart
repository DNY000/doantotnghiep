import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final TextEditingController searchController = TextEditingController();
  TabController? tabController;
  bool isSelectCity = false;

  void initTabController(TickerProvider vsync) {
    tabController?.dispose();
    tabController = TabController(length: 3, vsync: vsync);
  }

  @override
  void dispose() {
    searchController.dispose();
    tabController?.dispose();
    super.dispose();
  }
}
