import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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
    return TShimmer.color3(
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

/// Shimmer MainTabView
class ShimmerMainTabView extends StatefulWidget {
  final int initialIndex;
  final Function(bool isLoading)? onLoadingChanged;
  final Duration loadingDuration;

  const ShimmerMainTabView({
    Key? key,
    this.initialIndex = 0,
    this.onLoadingChanged,
    this.loadingDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<ShimmerMainTabView> createState() => _ShimmerMainTabViewState();
}

class _ShimmerMainTabViewState extends State<ShimmerMainTabView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _isLoading = true;
        });

        if (widget.onLoadingChanged != null) {
          widget.onLoadingChanged!(true);
        }

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
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(), // Disable swiping
        children: [
          _isLoading && _tabController.index == 0
              ? const ShimmerHomeView()
              : Container(), // Will be replaced with actual HomeView

          _isLoading && _tabController.index == 1
              ? const ShimmerOrderView()
              : Container(), // Will be replaced with actual OrderView

          _isLoading && _tabController.index == 2
              ? const ShimmerFavoritesView()
              : Container(), // Will be replaced with actual FavoritesView

          _isLoading && _tabController.index == 3
              ? const ShimmerNotificationsView()
              : Container(), // Will be replaced with actual NotificationsView

          _isLoading && _tabController.index == 4
              ? const ShimmerProfileView()
              : Container(), // Will be replaced with actual ProfileView
        ],
      ),
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                spreadRadius: 1,
                blurRadius: 10,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.orange,
            unselectedLabelColor: TColor.gray,
            labelStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            indicatorColor: Colors.transparent,
            tabs: const [
              Tab(
                icon: Icon(Icons.home_outlined),
                text: "Trang chủ",
              ),
              Tab(
                icon: Icon(Icons.receipt_long_outlined),
                text: "Đơn hàng",
              ),
              Tab(
                icon: Icon(Icons.favorite_border_outlined),
                text: "Yêu thích",
              ),
              Tab(
                icon: Icon(Icons.notifications_outlined),
                text: "Thông báo",
              ),
              Tab(
                icon: Icon(Icons.person_outline),
                text: "Tài khoản",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
