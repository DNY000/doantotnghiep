import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/core/services/connected_internet.dart';
import 'package:foodapp/viewmodels/banner_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await dotenv.load(fileName: ".env");
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

    // Khởi tạo NetworkStatusService
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NetworkStatusService().initialize();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    NetworkStatusService().dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Khi app quay trở lại foreground, kiểm tra lại kết nối
    if (state == AppLifecycleState.resumed) {
      // Delay một chút để đảm bảo kết nối ổn định
      Future.delayed(const Duration(milliseconds: 300), () {
        // Trigger kiểm tra kết nối bằng cách gọi connectivity check
        Connectivity().checkConnectivity();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          surfaceTintColor: Colors.transparent,
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const NetworkStatusOverlay(),
          ],
        );
      },
    );
  }
}

class NetworkStatusOverlay extends StatefulWidget {
  const NetworkStatusOverlay({super.key});

  @override
  State<NetworkStatusOverlay> createState() => _NetworkStatusOverlayState();
}

class _NetworkStatusOverlayState extends State<NetworkStatusOverlay> {
  bool _isDialogShowing = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkStatusService().connectionState,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data! && !_isDialogShowing) {
          _isDialogShowing = true;
          Future.delayed(Duration.zero, () {
            if (mounted) {
              _showConnectionDialog();
            }
          });
        } else if (snapshot.hasData && snapshot.data! && _isDialogShowing) {
          _isDialogShowing = false;
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showConnectionDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _isDialogShowing = false;
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) {
      _isDialogShowing = false;
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.red, size: 24),
                SizedBox(width: 8),
                Text(
                  'Mất kết nối',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng của bạn.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _isDialogShowing = false;
                  await NetworkStatusService().retryConnection();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 4),
                    Text('Thử lại'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _isDialogShowing = false;
                  SystemNavigator.pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exit_to_app, size: 18),
                    SizedBox(width: 4),
                    Text('Thoát'),
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
