import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/shimmer/shimmer_effect.dart';

/// Shimmer cho trang Home
class ShimmerHomeView extends StatelessWidget {
  const ShimmerHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderShimmer(),
          _buildSearchBarShimmer(),
          _buildCategoriesShimmer(),
          _buildPopularRestaurantsShimmer(),
          _buildRecommendedFoodsShimmer(),
        ],
      ),
    );
  }

  Widget _buildHeaderShimmer() {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 40, 16, 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TShimmerBox(
                  width: 180,
                  height: 24,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: 8),
                TShimmerBox(
                  width: 140,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
            TShimmerCircle(size: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBarShimmer() {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesShimmer() {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TShimmerBox(
                  width: 120,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                TShimmerBox(
                  width: 60,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 80,
                  child: const Column(
                    children: [
                      TShimmerCircle(size: 60),
                      SizedBox(height: 8),
                      TShimmerBox(
                        width: 60,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRestaurantsShimmer() {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TShimmerBox(
                  width: 150,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                TShimmerBox(
                  width: 60,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TShimmerBox(
                        width: 260,
                        height: 120,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TShimmerBox(
                              width: 140,
                              height: 16,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                            SizedBox(height: 4),
                            TShimmerBox(
                              width: 200,
                              height: 12,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(4)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedFoodsShimmer() {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TShimmerBox(
                  width: 160,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                TShimmerBox(
                  width: 60,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    TShimmerBox(
                      width: 80,
                      height: 80,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TShimmerBox(
                            width: 130,
                            height: 16,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          SizedBox(height: 8),
                          TShimmerBox(
                            width: double.infinity,
                            height: 12,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          SizedBox(height: 4),
                          TShimmerBox(
                            width: 80,
                            height: 12,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TShimmerBox(
                                width: 60,
                                height: 16,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              Row(
                                children: [
                                  TShimmerBox(
                                    width: 40,
                                    height: 16,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4)),
                                  ),
                                  SizedBox(width: 4),
                                  TShimmerCircle(size: 16),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Shimmer cho Orders View
class ShimmerOrderView extends StatelessWidget {
  const ShimmerOrderView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildTabs(),
          Expanded(
            child: _buildEmptyOrderView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          for (int i = 0; i < 4; i++)
            Expanded(
              child: Center(
                child: TShimmerBox(
                  width: 60 + (i * 5),
                  height: 14,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrderView() {
    return Column(
      children: [
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TShimmerCircle(size: 100),
                SizedBox(height: 20),
                TShimmerBox(
                  width: 180,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: 8),
                TShimmerBox(
                  width: 280,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                SizedBox(height: 4),
                TShimmerBox(
                  width: 260,
                  height: 14,
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ],
            ),
          ),
        ),
        _buildRecommendationSection(),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      children: [
        const SizedBox(height: 16),
        const TShimmerBox(
          width: 180,
          height: 18,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 2,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  TShimmerBox(
                    width: 100,
                    height: 100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TShimmerBox(
                          width: 180,
                          height: 16,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        SizedBox(height: 8),
                        TShimmerBox(
                          width: 140,
                          height: 14,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        SizedBox(height: 4),
                        TShimmerBox(
                          width: 120,
                          height: 14,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        SizedBox(height: 8),
                        TShimmerBox(
                          width: 80,
                          height: 24,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

/// Shimmer cho Favorites View
class ShimmerFavoritesView extends StatelessWidget {
  const ShimmerFavoritesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: _buildFavoritesList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      color: Colors.white,
      child: const Row(
        children: [
          TShimmerCircle(size: 30),
          SizedBox(width: 8),
          TShimmerBox(
            width: 140,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: const TShimmerBox(
        width: double.infinity,
        height: 46,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              TShimmerBox(
                width: 80,
                height: 80,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TShimmerBox(
                      width: 140,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 8),
                    TShimmerBox(
                      width: 200,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 4),
                    TShimmerBox(
                      width: 100,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TShimmerBox(
                          width: 70,
                          height: 22,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                        TShimmerCircle(size: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shimmer cho Notifications View
class ShimmerNotificationsView extends StatelessWidget {
  const ShimmerNotificationsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildNotificationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      color: Colors.white,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TShimmerBox(
            width: 130,
            height: 26,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          TShimmerCircle(size: 30),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TShimmerBox(
                width: 60,
                height: 60,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TShimmerBox(
                      width: 220,
                      height: 16,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 8),
                    TShimmerBox(
                      width: double.infinity,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 4),
                    TShimmerBox(
                      width: 160,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 8),
                    TShimmerBox(
                      width: 100,
                      height: 12,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Shimmer cho Profile View
class ShimmerProfileView extends StatelessWidget {
  const ShimmerProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TShimmer(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          _buildProfileHeader(),
          _buildMenuItems(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 50, 16, 30),
      color: Colors.white,
      child: Column(
        children: [
          const TShimmerCircle(size: 100),
          const SizedBox(height: 16),
          const TShimmerBox(
            width: 160,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          const SizedBox(height: 8),
          const TShimmerBox(
            width: 200,
            height: 16,
            borderRadius: BorderRadius.all(Radius.circular(4)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < 3; i++)
                const Column(
                  children: [
                    TShimmerBox(
                      width: 40,
                      height: 20,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    SizedBox(height: 8),
                    TShimmerBox(
                      width: 70,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          children: [
            for (int i = 0; i < 5; i++)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: const Row(
                  children: [
                    TShimmerCircle(size: 40),
                    SizedBox(width: 16),
                    TShimmerBox(
                      width: 140,
                      height: 18,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    Spacer(),
                    TShimmerCircle(size: 24),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer MainTabView (Simplified)
class ShimmerMainTabViewContent extends StatefulWidget {
  final int initialIndex;
  final Function(bool isLoading)? onLoadingChanged;
  final Duration loadingDuration;
  final TabController tabController;

  const ShimmerMainTabViewContent({
    Key? key,
    required this.tabController, // Nhận TabController từ MainTabView
    this.initialIndex = 0,
    this.onLoadingChanged,
    this.loadingDuration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<ShimmerMainTabViewContent> createState() =>
      _ShimmerMainTabViewContentState();
}

class _ShimmerMainTabViewContentState extends State<ShimmerMainTabViewContent>
    with TickerProviderStateMixin {
  late TabController
      _internalTabController; // Sử dụng tab controller nội bộ cho shimmer
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Tạo tab controller nội bộ chỉ để đồng bộ index với main tab controller
    _internalTabController = TabController(
      length: 4, // Đảm bảo length khớp với số tab
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    // Đồng bộ index từ main tab controller
    widget.tabController.addListener(() {
      if (widget.tabController.index != _internalTabController.index) {
        _internalTabController.index = widget.tabController.index;
        // Có thể thêm logic setState nếu cần cập nhật UI ngay lập tức khi index đổi
      }
    });

    // Simulating initial loading
    Future.delayed(widget.loadingDuration, () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (widget.onLoadingChanged != null) {
          widget.onLoadingChanged!(false);
        }
      }
    });
  }

  @override
  void dispose() {
    _internalTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Chỉ build TabBarView cho shimmer content
    return TabBarView(
      controller: _internalTabController, // Sử dụng internal controller
      physics: const NeverScrollableScrollPhysics(), // Disable swiping
      children: [
        // Hiển thị shimmer view tương ứng với tab hiện tại
        if (_internalTabController.index == 0)
          const ShimmerHomeView()
        else
          Container(),
        if (_internalTabController.index == 1)
          const ShimmerOrderView()
        else
          Container(),
        if (_internalTabController.index == 2)
          const ShimmerFavoritesView()
        else
          Container(),
        if (_internalTabController.index == 3)
          const ShimmerProfileView()
        else
          Container(),
      ],
    );
  }
}
