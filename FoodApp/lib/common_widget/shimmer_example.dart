import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/common_widget/shimmer/shimmer_effect.dart';

/// Ví dụ về cách sử dụng Shimmer trong các màn hình khác nhau
class ShimmerExampleScreen extends StatefulWidget {
  const ShimmerExampleScreen({Key? key}) : super(key: key);

  @override
  State<ShimmerExampleScreen> createState() => _ShimmerExampleScreenState();
}

class _ShimmerExampleScreenState extends State<ShimmerExampleScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Mô phỏng việc tải dữ liệu
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shimmer Examples'),
        actions: [
          IconButton(
            icon: Icon(_isLoading ? Icons.hourglass_full : Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = !_isLoading;
              });
            },
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              labelColor: TColor.orange5,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Món ăn'),
                Tab(text: 'Nhà hàng'),
                Tab(text: 'Thông báo'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildFoodTab(),
                  _buildRestaurantTab(),
                  _buildNotificationTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodTab() {
    if (_isLoading) {
      return const TShimmerFoodList(itemCount: 5);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.amber,
                  image: const DecorationImage(
                    image: AssetImage('assets/img/l1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Món ăn ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mô tả ngắn về món ăn ${index + 1}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(index + 1) * 20000}đ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColor.color3,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '4.${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantTab() {
    if (_isLoading) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildShimmerRestaurantCard(),
              const SizedBox(height: 16),
              _buildShimmerRestaurantCard(),
              const SizedBox(height: 16),
              _buildShimmerRestaurantCard(),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(
                  'assets/img/l${index + 1}.png',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant,
                          size: 20,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Nhà hàng ${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${2 + index} km từ vị trí của bạn',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${15 + (index * 5)}-${25 + (index * 5)} phút',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${4 + (index * 0.2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${100 * (index + 1)}+)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: TColor.color3,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Giảm ${10 * (index + 1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: TColor.color3,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    );
  }

  Widget _buildNotificationTab() {
    if (_isLoading) {
      return ListView.separated(
        itemCount: 5,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) => _buildShimmerNotification(),
      );
    }

    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/img/l${(index % 3) + 1}.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            'Thông báo ${index + 1}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Chi tiết thông báo ${index + 1}',
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerRestaurantCard() {
    return TShimmer.color3(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            // Banner
            TShimmerBox(
              width: double.infinity,
              height: 150,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên nhà hàng
                  Row(
                    children: [
                      TShimmerCircle(size: 20),
                      SizedBox(width: 8),
                      TShimmerBox(
                        width: 180,
                        height: 18,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Vị trí
                  Row(
                    children: [
                      TShimmerCircle(size: 16),
                      SizedBox(width: 8),
                      TShimmerBox(
                        width: 140,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),

                  // Thời gian
                  Row(
                    children: [
                      TShimmerCircle(size: 16),
                      SizedBox(width: 8),
                      TShimmerBox(
                        width: 120,
                        height: 14,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Đánh giá và giảm giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          TShimmerCircle(size: 18),
                          SizedBox(width: 6),
                          TShimmerBox(
                            width: 80,
                            height: 16,
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ],
                      ),
                      TShimmerBox(
                        width: 80,
                        height: 24,
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerNotification() {
    return TShimmer.color3(
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh thumbnail
            TShimmerBox(
              width: 60,
              height: 60,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            SizedBox(width: 16),

            // Nội dung
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  TShimmerBox(
                    width: 180,
                    height: 18,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  SizedBox(height: 8),

                  // Dòng 1 mô tả
                  TShimmerBox(
                    width: double.infinity,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  SizedBox(height: 4),

                  // Dòng 2 mô tả
                  TShimmerBox(
                    width: 100,
                    height: 14,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  SizedBox(height: 8),

                  // Thời gian
                  TShimmerBox(
                    width: 80,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
