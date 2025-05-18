import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/data/repositories/food_repository.dart';
import 'package:foodapp/data/repositories/order_repository.dart';
import 'package:foodapp/data/repositories/restaurant_repository.dart';
import 'package:foodapp/routes/page_router.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:foodapp/data/repositories/user_repository.dart';
import 'package:foodapp/core/firebase_options.dart'
    if (kIsWeb) 'package:foodapp/core/firebase_web_options.dart';
import 'package:foodapp/viewmodels/simple_providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/notifications_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Cấu hình toàn diện hơn cho status bar
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Đảm bảo hiển thị status bar nhưng trong suốt
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await dotenv.load(fileName: ".env");

  await Future.wait<void>([
    TLocalStorage.init('food_app'),
    Firebase.initializeApp(
      options: kIsWeb
          ? FirebaseOptions(
              apiKey: dotenv.env["API_KEY"] ?? "",
              authDomain: "foodapp-daade.firebaseapp.com",
              projectId: "foodapp-daade",
              storageBucket: "foodapp-daade.appspot.com",
              messagingSenderId: "44206956684",
              appId: dotenv.env['APP_ID'] ?? "",
              measurementId: "G-ZCRF80FGZ6")
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
        ChangeNotifierProvider(
          create: (_) => UserViewModel(UserRepository()),
        ),
      ],
      child: const SimpleProviders(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationsService.initialize(context);

    return MaterialApp.router(
      title: 'Food App',
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.white,
        fontFamily: "Quicksand",
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
          ),
        ),
      ),
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: child!,
        );
      },
    );
  }
}
