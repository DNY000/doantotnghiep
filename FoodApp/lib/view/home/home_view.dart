import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/appbar/t_appbar.dart';
import 'package:foodapp/core/location_service.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/view/home/widgets/list_banner.dart';
import 'package:foodapp/view/home/widgets/list_best_seller_food.dart';
import 'package:foodapp/view/home/widgets/list_category.dart';
import 'package:foodapp/view/home/widgets/list_restaurant_new.dart';
import 'package:foodapp/view/home/widgets/restaurant_tab_view.dart';
import 'package:foodapp/view/notifications/notification_view.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import '../../common_widget/selection_text_view.dart';
import '../../viewmodels/category_viewmodel.dart';
import 'package:foodapp/viewmodels/home_viewmodel.dart';
import 'package:foodapp/view/search/food_search_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(),
      child: const _HomeViewContent(),
    );
  }
}

class _HomeViewContent extends StatefulWidget {
  const _HomeViewContent({Key? key}) : super(key: key);

  @override
  State<_HomeViewContent> createState() => _HomeViewContentState();
}

class _HomeViewContentState extends State<_HomeViewContent>
    with SingleTickerProviderStateMixin {
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController trong HomeViewModel
    context.read<HomeViewModel>().initTabController(this);

    // Khởi tạo data khi widget được build lần đầu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodViewModel>().loadFoods();
      context.read<CategoryViewModel>().loadCategories();
      context.read<RestaurantViewModel>().getNewRestaurants();
      context.read<UserViewModel>().loadCurrentUser();
    });

    _loadCurrentAddress();
  }

  Future<void> _loadCurrentAddress() async {
    final position = await LocationService.getCurrentLocation(context);
    if (position != null) {
      final address = await LocationService.getAddressFromPosition(position);
      if (mounted) {
        setState(() {
          _currentAddress = address ?? 'Không xác định';
        });
      }
    } else {
      setState(() {
        _currentAddress = 'Không xác định';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final viewModel = context.watch<HomeViewModel>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: TColor.bg,
        body: DefaultTabController(
          length: 3,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: TAppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Selector<UserViewModel, String>(
                      selector: (context, user) => user.currentUser?.name ?? '',
                      builder: (context, name, child) => Text(
                        'Xin chào, $name',
                        style: TextStyle(
                          color: TColor.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      _currentAddress ?? 'Đang lấy vị trí...',
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                // showBackArrow: isSelectCity,

                action: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      size: 24,
                      color: TColor.text,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotificationsView()),
                      );
                    },
                  ),
                ],
              )),
              SliverAppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                pinned: false,
                floating: true,
                primary: false,
                // không hiển thị back button
                automaticallyImplyLeading: false,
                title: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FoodSearchView()),
                    );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: TColor.gray),
                        const SizedBox(width: 8),
                        Text(
                          'Tìm kiếm món ăn...',
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: ListBanner(),
              ),
              const SliverToBoxAdapter(
                child: ListCategory(),
              ),
              const SliverToBoxAdapter(
                child: ListFoodYouMaybeLike(),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    SelectionTextView(
                      title: "Khám phá quán mới",
                      onSeeAllTap: () {},
                    ),
                    const ListRestaurantNew(),
                  ],
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: 20,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height *
                      0.6, // 60% chiều cao màn hình
                  child: const RestaurantTabView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
