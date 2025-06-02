import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SampleData {
  static List<Map<String, dynamic>> getCategories() {
    return [
      {
        'id': 'pho',
        'name': 'Phở',
        'image': 'assets/img/logo/logo1.jpg',
        'icon': 'bowl_food',
        'description': 'Phở Việt Nam truyền thống',
        'isActive': true,
        'sortOrder': 1,
      },
      {
        'id': 'com',
        'name': 'Cơm',
        'image': 'assets/img/logo/logo2.jpg',
        'icon': 'rice_bowl',
        'description': 'Cơm Việt Nam',
        'isActive': true,
        'sortOrder': 2,
      },
      {
        'id': 'bun',
        'name': 'Bún',
        'image': 'assets/img/logo/logo3.jpg',
        'icon': 'noodles',
        'description': 'Các món bún',
        'isActive': true,
        'sortOrder': 3,
      },
      {
        'id': 'mi',
        'name': 'Mì',
        'image': 'assets/img/logo/logo4.jpg',
        'icon': 'noodles',
        'description': 'Các món mì',
        'isActive': true,
        'sortOrder': 4,
      },
      {
        'id': 'garan',
        'name': 'Gà rán',
        'image': 'assets/img/logo/logo5.jpg',
        'icon': 'noodles',
        'description': 'Các món gà rán',
        'isActive': true,
        'sortOrder': 5,
      },
      {
        'id': 'banhmi',
        'name': 'Bánh mì',
        'image': 'assets/img/logo/logo6.jpg',
        'icon': 'noodles',
        'description': 'Các món bánh mì',
        'isActive': true,
        'sortOrder': 6,
      }
    ];
  }

  static List<Map<String, dynamic>> getRestaurants() {
    return [
      {
        'id': '1',
        'name': 'Tít Mít Quán -  Bún Cá Ốc',
        'description': 'Quán bún cá ốc ngon nổi tiếng Hà Nội',
        'address': '39A Triều Khúc, P. Thanh Xuân Nam',
        'location': const GeoPoint(20.98626004927923, 105.79808926615186),
        'operatingHours': {
          'openTime': '06:00',
          'closeTime': '22:00',
        },
        'rating': 4.5,
        'images': {
          'main': 'assets/img/logo/logo6.jpg',
          'gallery': ['assets/img/logo/logo6.jpg'],
        },
        'status': 'open',
        'minOrderAmount': 30000,
        'createdAt': Timestamp.now(),
        'categories': ['bun', 'pho'],
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now(),
        },
      },
      {
        'id': '2',
        'name': 'Sinry Chicken - Gà Rán & Cơm Trộn Hàn Quốc',
        'description': 'Quán gà rán và cơm trộn Hàn Quốc ngon nhất khu vực',
        'address': '48 Ngõ 42 Triều Khúc',
        'location': const GeoPoint(20.98539794624276, 105.79762799498806),
        'operatingHours': {
          'openTime': '10:00',
          'closeTime': '22:00',
        },
        'rating': 4.7,
        'images': {
          'main': 'assets/img/logo/logo7.jpg',
          'gallery': ['assets/img/logo/logo7.jpg'],
        },
        'status': 'open',
        'minOrderAmount': 50000,
        'createdAt': Timestamp.now(),
        'categories': ['garan', 'com'],
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now(),
        },
      },
      {
        'id': '3',
        'name': 'Cô Vinh Quán - Bánh Mì Chảo',
        'description': 'Bánh mì chảo ngon nức tiếng khu vực',
        'address': '75 Ngõ 66B Triều Khúc',
        'location': const GeoPoint(20.982592480664962, 105.79835233731562),
        'operatingHours': {
          'openTime': '06:00',
          'closeTime': '21:00',
        },
        'rating': 4.6,
        'images': {
          'main': 'assets/img/logo/logo8.jpg',
          'gallery': ['assets/img/logo/logo8.jpg'],
        },
        'status': 'open',
        'minOrderAmount': 25000,
        'createdAt': Timestamp.now(),
        'categories': ['banhmi', 'com'],
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now(),
        },
      },
      {
        'id': '4',
        'name': 'Cơm Gà Phương Thúy',
        'description': 'Cơm gà ngon, phần ăn đầy đặn',
        'address': '7N2 Ngõ 58 Triều Khúc, P. Thanh Xuân Nam',
        'location': const GeoPoint(20.98418519991842, 105.79913554204764),
        'operatingHours': {
          'openTime': '10:00',
          'closeTime': '21:00',
        },
        'rating': 4.4,
        'images': {
          'main': 'assets/img/logo/logo9.jpg',
          'gallery': ['assets/img/logo/logo9.jpg'],
        },
        'status': 'open',
        'minOrderAmount': 35000,
        'createdAt': Timestamp.now(),
        'categories': ['com', 'pho'],
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now(),
        },
      },
      {
        'id': '5',
        'name': 'KTOP Hotdog',
        'description': 'Xúc xích Hàn Quốc ngon chuẩn vị',
        'address': '21 Triều Khúc, Quận Thanh Xuân, Hà Nội',
        'location': const GeoPoint(20.982024098102716, 105.79895552382416),
        'operatingHours': {
          'openTime': '11:00',
          'closeTime': '22:00',
        },
        'rating': 4.3,
        'images': {
          'main': 'assets/img/logo/logo10.jpg',
          'gallery': ['assets/img/logo/logo10.jpg'],
        },
        'status': 'open',
        'minOrderAmount': 40000,
        'createdAt': Timestamp.now(),
        'categories': ['mi', 'pho'],
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now(),
        },
      },
    ];
  }

  static List<Map<String, dynamic>> getFoods() {
    List<Map<String, dynamic>> foods = [];

    // Món phở
    final phoList = [
      {
        'id': 'pho_0001',
        'name': 'Phở Bò Tái',
        'description': 'Phở bò với thịt bò tái mềm, nước dùng đậm đà',
        'price': 45000,
        'discountPrice': 40000,
        'images': ['assets/img/logo/logo1.jpg'],
        'ingredients': ['Bánh phở', 'Thịt bò tái', 'Hành', 'Rau thơm'],
        'category': 'pho',
        'restaurantId': '1',
        'isAvailable': true,
        'rating': 4.5,
        'soldCount': 100,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'pho_0002',
        'name': 'Phở Bò Nạm',
        'description': 'Phở với thịt bò nạm mềm, nước dùng đậm đà',
        'price': 50000,
        'discountPrice': 45000,
        'images': ['assets/img/food/phobo2.jpg'],
        'ingredients': ['Bánh phở', 'Thịt bò nạm', 'Hành', 'Rau thơm'],
        'category': 'pho',
        'restaurantId': '2',
        'isAvailable': true,
        'rating': 4.3,
        'soldCount': 80,
        'createdAt': Timestamp.now(),
      },
    ];
    foods.addAll(phoList);

    // Món cơm
    final comList = [
      {
        'id': 'com_0001',
        'name': 'Cơm Gà Xối Mỡ',
        'description': 'Cơm gà xối mỡ thơm ngon, da giòn rụm',
        'price': 45000,
        'discountPrice': null,
        'images': ['assets/img/food/comga1.jpg'],
        'ingredients': ['Cơm', 'Gà', 'Rau sống', 'Nước mắm'],
        'category': 'com',
        'restaurantId': '9',
        'isAvailable': true,
        'rating': 4.5,
        'soldCount': 150,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'com_0002',
        'name': 'Cơm Tấm Sườn',
        'description': 'Cơm tấm sườn nướng thơm ngon, kèm bì chả',
        'price': 50000,
        'discountPrice': null,
        'images': ['assets/img/food/comtam1.jpg'],
        'ingredients': ['Cơm tấm', 'Sườn nướng', 'Bì', 'Chả'],
        'category': 'com',
        'restaurantId': '9',
        'isAvailable': true,
        'rating': 4.7,
        'soldCount': 200,
        'createdAt': Timestamp.now(),
      },
    ];
    foods.addAll(comList);

    // Món bún
    final bunList = [
      {
        'id': 'bun_0001',
        'name': 'Bún Cá',
        'description': 'Bún cá với nước dùng đậm đà, cá tươi ngon',
        'price': 45000,
        'discountPrice': 40000,
        'images': ['assets/img/food/bunca1.jpg'],
        'ingredients': ['Bún', 'Cá', 'Rau sống', 'Gia vị'],
        'category': 'bun',
        'restaurantId': '6',
        'isAvailable': true,
        'rating': 4.6,
        'soldCount': 120,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'bun_0002',
        'name': 'Bún Ốc',
        'description': 'Bún ốc Hà Nội truyền thống, ốc tươi ngon',
        'price': 40000,
        'discountPrice': null,
        'images': ['assets/img/food/bunoc1.jpg'],
        'ingredients': ['Bún', 'Ốc', 'Rau sống', 'Gia vị'],
        'category': 'bun',
        'restaurantId': '6',
        'isAvailable': true,
        'rating': 4.4,
        'soldCount': 90,
        'createdAt': Timestamp.now(),
      },
    ];
    foods.addAll(bunList);

    // Món gà rán
    final gaRanList = [
      {
        'id': 'garan_0001',
        'name': 'Gà Rán Sốt Cay',
        'description': 'Gà rán sốt cay Hàn Quốc, giòn rụm',
        'price': 65000,
        'discountPrice': 55000,
        'images': ['assets/img/food/garan1.jpg'],
        'ingredients': ['Gà', 'Sốt cay', 'Salad', 'Khoai tây chiên'],
        'category': 'garan',
        'restaurantId': '7',
        'isAvailable': true,
        'rating': 4.8,
        'soldCount': 300,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'garan_0002',
        'name': 'Gà Rán Sốt Phô Mai',
        'description': 'Gà rán sốt phô mai béo ngậy',
        'price': 70000,
        'discountPrice': null,
        'images': ['assets/img/food/garan2.jpg'],
        'ingredients': ['Gà', 'Sốt phô mai', 'Salad', 'Khoai tây chiên'],
        'category': 'garan',
        'restaurantId': '7',
        'isAvailable': true,
        'rating': 4.7,
        'soldCount': 250,
        'createdAt': Timestamp.now(),
      },
    ];
    foods.addAll(gaRanList);

    // Bánh mì
    final banhMiList = [
      {
        'id': 'banhmi_0001',
        'name': 'Bánh Mì Chảo',
        'description': 'Bánh mì chảo nóng hổi, đầy đặn nhân',
        'price': 35000,
        'discountPrice': 30000,
        'images': ['assets/img/food/banhmi1.jpg'],
        'ingredients': ['Bánh mì', 'Thịt bò', 'Trứng', 'Rau sống'],
        'category': 'banhmi',
        'restaurantId': '8',
        'isAvailable': true,
        'rating': 4.6,
        'soldCount': 180,
        'createdAt': Timestamp.now(),
      },
      {
        'id': 'banhmi_0002',
        'name': 'Bánh Mì Thịt Nướng',
        'description': 'Bánh mì thịt nướng thơm ngon',
        'price': 25000,
        'discountPrice': null,
        'images': ['assets/img/food/banhmi2.jpg'],
        'ingredients': ['Bánh mì', 'Thịt nướng', 'Rau sống', 'Gia vị'],
        'category': 'banhmi',
        'restaurantId': '8',
        'isAvailable': true,
        'rating': 4.5,
        'soldCount': 150,
        'createdAt': Timestamp.now(),
      },
    ];
    foods.addAll(banhMiList);

    return foods;
  }

  static List<Map<String, dynamic>> getUsers() {
    return [
      {
        'id': 'user_0001',
        'profile': {
          'name': 'Nguyễn Văn A',
          'email': 'nguyenvana@gmail.com',
          'phoneNumber': '0901234567',
          'avatarUrl': 'assets/images/avatar1.jpg',
          'birthday': Timestamp.fromDate(DateTime(1990, 1, 1)),
          'gender': 'male'
        },
        'contact': {
          'addresses': [
            {
              'id': 'address_0001',
              'name': 'Nhà',
              'address': '123 Nguyễn Văn Cừ',
              'district': 'Quận 5',
              'city': 'TP.HCM',
              'phoneNumber': '0901234567',
              'location': const GeoPoint(10.762622, 106.660172),
              'note': 'Gần trường đại học',
              'isDefault': true
            },
            {
              'id': '2',
              'name': 'Công ty',
              'address': '456 Lê Văn Việt',
              'district': 'Quận 9',
              'city': 'TP.HCM',
              'phoneNumber': '0901234567',
              'location': const GeoPoint(10.841394, 106.790347),
              'note': 'Tòa nhà ABC, tầng 5',
              'isDefault': false
            }
          ],
          'emergencyContact': {
            'name': 'Nguyễn Thị B',
            'phoneNumber': '0909876543',
            'relationship': 'Vợ'
          }
        },
        'preferences': {
          'language': 'vi',
          'notificationSettings': {
            'orderUpdates': true,
            'promotions': true,
            'marketing': false
          },
          'favoriteRestaurants': ['6', '7'],
          'favoriteFoods': ['bun1', 'garan1'],
          'recentOrders': ['order1', 'order2']
        },
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastLogin': Timestamp.now(),
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 30)))
        }
      },
      {
        'id': 'user2',
        'profile': {
          'name': 'Trần Thị B',
          'email': 'tranthib@gmail.com',
          'phoneNumber': '0909876543',
          'avatarUrl': 'assets/images/avatar2.jpg',
          'birthday': Timestamp.fromDate(DateTime(1992, 5, 15)),
          'gender': 'female'
        },
        'contact': {
          'addresses': [
            {
              'id': '3',
              'name': 'Nhà trọ',
              'address': '789 Lý Thường Kiệt',
              'district': 'Quận 10',
              'city': 'TP.HCM',
              'phoneNumber': '0909876543',
              'location': const GeoPoint(10.770912, 106.666039),
              'note': 'Gần chợ',
              'isDefault': true
            }
          ],
          'emergencyContact': {
            'name': 'Trần Văn C',
            'phoneNumber': '0901112222',
            'relationship': 'Anh trai'
          }
        },
        'preferences': {
          'language': 'vi',
          'notificationSettings': {
            'orderUpdates': true,
            'promotions': true,
            'marketing': true
          },
          'favoriteRestaurants': ['8', '9'],
          'favoriteFoods': ['banhmi1', 'com1'],
          'recentOrders': []
        },
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastLogin': Timestamp.now(),
          'createdAt': Timestamp.fromDate(
              DateTime.now().subtract(const Duration(days: 15)))
        }
      }
    ];
  }

  static List<Map<String, dynamic>> getShippers() {
    return [
      {
        'id': 'shipper1',
        'profile': {
          'name': 'Trần Văn B',
          'phoneNumber': '0909876543',
          'email': 'tranvanb@gmail.com',
          'avatarUrl': 'assets/images/avatar_shipper1.jpg',
          'identityCard': '123456789',
          'identityCardImage': 'assets/images/id_shipper1.jpg',
          'vehicleInfo': {
            'type': 'motorcycle',
            'number': '59P1-23456',
            'image': 'assets/images/vehicle_shipper1.jpg'
          }
        },
        'status': 'active',
        'location': const GeoPoint(10.762622, 106.660172),
        'rating': 4.8,
        'totalDeliveries': 150,
        'currentOrderId': 'order1',
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now()
        }
      },
      {
        'id': 'shipper2',
        'profile': {
          'name': 'Nguyễn Thị D',
          'phoneNumber': '0901112222',
          'email': 'nguyenthid@gmail.com',
          'avatarUrl': 'assets/images/avatar_shipper2.jpg',
          'identityCard': '987654321',
          'identityCardImage': 'assets/images/id_shipper2.jpg',
          'vehicleInfo': {
            'type': 'motorcycle',
            'number': '59P1-78901',
            'image': 'assets/images/vehicle_shipper2.jpg'
          }
        },
        'status': 'active',
        'location': const GeoPoint(10.776543, 106.654321),
        'rating': 4.5,
        'totalDeliveries': 80,
        'currentOrderId': null,
        'metadata': {
          'isActive': true,
          'isVerified': true,
          'lastUpdated': Timestamp.now()
        }
      }
    ];
  }

  static List<Map<String, dynamic>> getReviews() {
    return [
      {
        'id': 'review_0001',
        'userId': 'user_0001',
        'targetId': '1', // restaurantId
        'targetType': 'restaurant',
        'rating': 4.5,
        'comment': 'Phở rất ngon, nước dùng đậm đà',
        'images': ['assets/images/review1.jpg'],
        'createdAt':
            Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 5)))
      },
      {
        'id': 'review_0002',
        'userId': 'user_0001',
        'targetId': '3', // restaurantId
        'targetType': 'restaurant',
        'rating': 4.7,
        'comment': 'Cơm tấm ngon, phần ăn lớn',
        'images': [],
        'createdAt':
            Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2)))
      },
      {
        'id': 'review_0003',
        'userId': 'user_0001',
        'targetId': '4', // foodId
        'targetType': 'food',
        'rating': 4.8,
        'comment': 'Sườn nướng thơm, cơm dẻo',
        'images': ['assets/images/review3.jpg'],
        'createdAt':
            Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1)))
      }
    ];
  }

  static List<Map<String, dynamic>> getNotifications() {
    return [
      {
        'id': 'notif_0001',
        'userId': 'user_0001',
        'title': 'Đơn hàng đã được xác nhận',
        'content': 'Đơn hàng #order1 của bạn đã được nhà hàng xác nhận',
        'type': 'order',
        'data': {'orderId': 'order1'},
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(hours: 1))),
        'isRead': false
      },
      {
        'id': 'notif2',
        'userId': 'user1',
        'title': 'Đơn hàng đang được giao',
        'content': 'Đơn hàng #order1 của bạn đang được giao đến',
        'type': 'order',
        'data': {'orderId': 'order1'},
        'createdAt': Timestamp.fromDate(
            DateTime.now().subtract(const Duration(minutes: 30))),
        'isRead': false
      },
    ];
  }

  // Helper methods để tạo dữ liệu động

  // Tạo timestamp từ chuỗi thời gian "HH:MM"
  static Timestamp timeStringToTimestamp(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length != 2) return Timestamp.now();

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;

      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, hour, minute);

      return Timestamp.fromDate(dateTime);
    } catch (e) {
      return Timestamp.now();
    }
  }

  // Tạo Timestamp từ DateTime với offset ngày
  static Timestamp getTimestampWithDayOffset(int days) {
    final now = DateTime.now();
    return Timestamp.fromDate(now.add(Duration(days: days)));
  }

  // Tạo random orders để testing
  static List<Map<String, dynamic>> generateRandomOrders(int count) {
    final List<Map<String, dynamic>> orders = [];
    final List<String> statuses = [
      'pending',
      'confirmed',
      'preparing',
      'on_the_way',
      'delivered',
      'cancelled'
    ];
    final List<String> restaurants = ['1', '2', '3', '4', '5'];
    final Map<String, String> restaurantNames = {
      '1': 'Phở Hà Nội',
      '2': 'Bún Bò Huế Thanh',
      '3': 'Cơm Tấm Sài Gòn',
      '4': 'Phở 24',
      '5': 'Bún Đậu Mắm Tôm',
    };
    final Map<String, String> restaurantImages = {
      '1': 'assets/images/restaurant1.jpg',
      '2': 'assets/images/restaurant2.jpg',
      '3': 'assets/images/restaurant3.jpg',
      '4': 'assets/images/restaurant4.jpg',
      '5': 'assets/images/restaurant5.jpg',
    };
    final Random random = Random();

    for (int i = 0; i < count; i++) {
      final String restaurantId =
          restaurants[random.nextInt(restaurants.length)];
      final String status = statuses[random.nextInt(statuses.length)];
      final int daysAgo = random.nextInt(10);
      final Timestamp orderTime = Timestamp.fromDate(DateTime.now()
          .subtract(Duration(days: daysAgo, hours: random.nextInt(24))));

      final items = getFoods()
          .where((food) => food['restaurantId'] == restaurantId)
          .take(1 + random.nextInt(2))
          .map((food) => {
                'foodId': food['id'],
                'foodName': food['name'],
                'foodImage': food['images'][0],
                'category': food['category'],
                'quantity': 1 + random.nextInt(3),
                'price': food['price'],
                'discountPrice': food['discountPrice'],
                'options': {},
                'note': ''
              })
          .toList();

      // Tính tổng giá
      double subtotal = 0;
      for (var item in items) {
        final price = (item['discountPrice'] ?? item['price']) as double;
        subtotal += price * (item['quantity'] as int);
      }

      final deliveryFee = (random.nextInt(3) + 1) * 5000.0;
      final discount = random.nextBool() ? random.nextInt(5) * 10000.0 : 0.0;
      final totalPrice = subtotal + deliveryFee - discount;

      orders.add({
        'id': 'order${100 + i}',
        'customerId': 'user${1 + random.nextInt(3)}',
        'restaurantId': restaurantId,
        'restaurantName': restaurantNames[restaurantId],
        'restaurantImage': restaurantImages[restaurantId],
        'shipperId': random.nextBool() ? 'shipper1' : 'shipper2',
        'items': items,
        'deliveryAddress':
            '123 Đường ABC, Quận ${1 + random.nextInt(12)}, TP.HCM',
        'deliveryFee': deliveryFee,
        'discount': discount,
        'totalPrice': totalPrice,
        'paymentMethod': random.nextBool() ? 'cash' : 'card',
        'note': '',
        'orderTime': orderTime,
        'estimatedDeliveryTime': Timestamp.fromDate(
            orderTime.toDate().add(Duration(minutes: 30 + random.nextInt(30)))),
        'status': status,
      });

      // Nếu đã giao hàng, thêm thời gian giao hàng thực tế
      if (status == 'delivered') {
        orders.last['actualDeliveryTime'] = Timestamp.fromDate(
            orderTime.toDate().add(Duration(minutes: 25 + random.nextInt(35))));
      }
    }

    return orders;
  }
}
