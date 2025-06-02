import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/viewmodels/banner_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// App files
import 'package:foodapp/core/firebase_options.dart'
    if (kIsWeb) 'package:foodapp/core/firebase_web_options.dart';
import 'package:foodapp/data/repositories/food_repository.dart';
import 'package:foodapp/data/repositories/order_repository.dart';
import 'package:foodapp/data/repositories/restaurant_repository.dart';
import 'package:foodapp/data/repositories/user_repository.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:foodapp/viewmodels/simple_providers.dart';
import 'package:foodapp/routes/page_router.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'package:foodapp/core/services/notifications_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Tải biến môi trường từ file .env
  await dotenv.load(fileName: ".env");

  // Khởi tạo Firebase và local storage cdsong song
  await Future.wait([
    TLocalStorage.init('food_app'),
    Firebase.initializeApp(
      options: kIsWeb
          ? FirebaseOptions(
              apiKey: dotenv.env["API_KEY"] ?? "",
              authDomain: "foodapp-daade.firebaseapp.com",
              projectId: "foodapp-daade",
              storageBucket: "foodapp-daade.appspot.com",
              messagingSenderId: "44206956684",
              appId: dotenv.env["APP_ID"] ?? "",
              measurementId: "G-ZCRF80FGZ6",
            )
          : DefaultFirebaseOptions.currentPlatform,
    ),
  ]);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FlutterNativeSplash.remove();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FoodViewModel(FoodRepository())),
        ChangeNotifierProvider(
            create: (_) => RestaurantViewModel(RestaurantRepository())),
        ChangeNotifierProvider(
            create: (_) => OrderViewModel(OrderRepository(),
                foodRepository: FoodRepository())),
        ChangeNotifierProvider(create: (_) => UserViewModel(UserRepository())),
        ChangeNotifierProvider(create: (_) => BannerViewmodel()),
      ],
      child: const SimpleProviders(child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        NotificationsService.initialize(context);
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // const overlayStyle = SystemUiOverlayStyle(
    //   statusBarColor: Colors.white, // Status bar có màu nền trắng
    //   statusBarIconBrightness: Brightness.dark, // Icon màu đen
    //   statusBarBrightness: Brightness.light, // Cho iOS
    //   // Navigation bar properties (dù bị ẩn)
    //   systemNavigationBarColor: Colors.transparent,
    //   systemNavigationBarIconBrightness: Brightness.light,
    //   systemNavigationBarDividerColor: Colors.transparent,
    // );

    return MaterialApp.router(
      title: 'Food App',
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.white,
        fontFamily: "Quicksand",
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          // systemOverlayStyle: overlayStyle,
          surfaceTintColor:
              Colors.transparent, // tắt tính năng đổi màu khi vuốt xuống
        ),
      ),
      // builder: (context, child) {
      //   return AnnotatedRegion<SystemUiOverlayStyle>(
      //     value: overlayStyle,
      //     child: MediaQuery(
      //       // CHỈ loại bỏ bottom padding (navigation bar area)
      //       // GIỮ NGUYÊN top padding cho status bar
      //       data: MediaQuery.of(context).copyWith(
      //         padding: MediaQuery.of(context).padding.copyWith(
      //               bottom: 0, // Loại bỏ bottom padding
      //               // top: MediaQuery.of(context).padding.top, // Giữ nguyên top padding
      //             ),
      //       ),
      //       child: child!,
      //     ),
      //   );
      // },
    );
  }
}
