import 'package:admin/main.dart';
import 'package:admin/routes/name_router.dart';
import 'package:admin/screens/authentication/srceen/login_screen.dart';
import 'package:admin/screens/authentication/srceen/register_screen.dart';
import 'package:admin/screens/category/category_screen.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/screens/notifications/notification_screen.dart';
import 'package:admin/screens/restaurant/restaurant_screen.dart';
import 'package:admin/screens/restaurant/widget/restaurant_detail_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoRouter goRouter = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: NameRouter.login,
  redirect: (context, state) {
    // Lấy trạng thái đăng nhập từ AuthViewModel hoặc FirebaseAuth
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final isLoginPage = state.uri.toString() == NameRouter.login;

    if (isLoggedIn && isLoginPage) {
      // Nếu đã đăng nhập mà vào trang login thì chuyển sang dashboard
      return NameRouter.dashboard;
    }
    if (!isLoggedIn && !isLoginPage) {
      // Nếu chưa đăng nhập mà vào trang khác login thì chuyển về login
      return NameRouter.login;
    }
    return null;
  },
  routes: [
    // Màn hình onboarding
    GoRoute(
      path: NameRouter.dashboard,
      builder: (context, state) => const MainScreen(),
    ),

    //  Màn hình login
    GoRoute(
      path: NameRouter.login,
      builder: (context, state) => const LoginScreen(),
    ),

    // Màn hình đăng ký
    GoRoute(
      path: NameRouter.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // // Màn hình quên mật khẩu
    // GoRoute(
    //   path: NameRouter.forgotPassword,
    //   builder: (context, state) => const ForgotPasswordView(),
    // ),

    // Home
    GoRoute(
      path: NameRouter.category,
      builder: (context, state) => const CategoryScreen(),
    ),

    // Order
    // GoRoute(
    //   path: NameRouter.order,
    //   builder: (context, state) => const OrderView(),
    // ),

    // Favorites

    // Profile
    // GoRoute(
    //   path: NameRouter.profile,
    //   builder: (context, state) => const MyProfileView(),
    // ),

    // Single Food Detail với tham số truyền vào
    // GoRoute(
    //   path: NameRouter.signleFood,
    //   builder: (context, state) {
    //     final food = state.extra as FoodModel;
    //     return SingleFoodDetail(foodItem: food);
    //   },
    // ),

    // Restaurant Detail với tham số truyền vào
    GoRoute(
      path: NameRouter.restaurant,
      builder: (context, state) => const RestaurantScreen(),
    ),
    // GoRoute(
    //   path: NameRouter.restaurantDetail,
    //   name: 'restaurantDetail',
    //   builder: (context, state) {
    //     final restaurantId = state.pathParameters['id'] ?? '';
    //     return RestaurantDetailScreen(restaurantId: restaurantId);
    //   },
    // ),
    GoRoute(
      path: NameRouter.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);
