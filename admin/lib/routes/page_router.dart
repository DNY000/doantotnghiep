import 'package:admin/dashborad_view.dart';
import 'package:admin/main.dart';
import 'package:admin/routes/name_router.dart';
import 'package:admin/screens/authentication/srceen/login_screen.dart';
import 'package:admin/screens/authentication/srceen/register_screen.dart';
import 'package:admin/screens/category/category_screen.dart';
import 'package:admin/screens/notifications/notification_screen.dart';
import 'package:admin/screens/restaurant/restaurant_scree.dart';
import 'package:go_router/go_router.dart';

final GoRouter goRouter = GoRouter(
  navigatorKey: navigatorKey,
  //     redirect: (context, state) {
  // final authViewModel = Provider.of<LoginViewModel>(context, listen: false);
  // final loggedIn = authViewModel.isLoggedIn;
  // final isLogin = state.matchedLocation == '/login';

  // if (!loggedIn && !isLogin) return '/login';
  // if (loggedIn && isLogin) return '/';
  // return null;
  // },
  initialLocation: NameRouter.login,
  routes: [
    // Màn hình onboarding
    GoRoute(
      path: NameRouter.dashboard,
      builder: (context, state) => const DashboardView(),
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
    GoRoute(
      path: NameRouter.notifications,
      builder: (context, state) => const NotificationScreen(),
    ),
  ],
);
