import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/common_widget/shimmer/shimmer_main_tab.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/view/farvorites/farvorite_view.dart';
import 'package:foodapp/view/order/order_view.dart';
import 'package:foodapp/view/profile/my_profile_view.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';
import '../home/home_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int _currentIndex = 0;
  bool _isLoading = true; // Add loading state

  final List<Widget> _pages = const [
    HomeView(),
    OrderView(),
    FarvoriteView(),
    MyProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _pages.length, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderViewModel>(context,
          listen: false); // hoặc gọi hàm nào đó ở đây
    });
    // Ensure system UI is properly configured for bottom navigation bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top], // Only show status bar
    );

    // Simulate loading for shimmer effect
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
    }
  }

  Tab _buildTab({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    Widget tabIcon = Icon(
      icon,
      color: isSelected ? Colors.orange : TColor.gray,
    );

    // Add notification badge to Order tab (index 1)
    if (index == 1) {
      return Tab(
        icon: Consumer<OrderViewModel>(
          builder: (context, orderViewModel, child) {
            final ongoingOrders = orderViewModel.orders
                .where((order) => order.status != OrderState.delivered)
                .length;
            return Badge(
              label: Text(
                '$ongoingOrders',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              isLabelVisible: ongoingOrders > 0,
              child: tabIcon,
            );
          },
        ),
        text: label,
      );
    }

    return Tab(
      icon: tabIcon,
      text: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading // Show shimmer while loading
          ? ShimmerMainTabViewContent(
              tabController: _tabController, // Pass the main tab controller
            )
          : TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: TColor.gray,
            labelPadding: EdgeInsets.zero,
            indicatorColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            tabs: [
              _buildTab(
                  icon: Icons.home_outlined, label: "Trang chủ", index: 0),
              _buildTab(
                  icon: Icons.receipt_long_outlined,
                  label: "Đơn hàng",
                  index: 1),
              _buildTab(
                  icon: Icons.favorite_border_outlined,
                  label: "Yêu thích",
                  index: 2),
              _buildTab(
                  icon: Icons.person_outline, label: "Tài khoản", index: 3),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
