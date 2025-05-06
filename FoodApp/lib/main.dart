import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/data/repositories/food_repository.dart';
import 'package:foodapp/data/repositories/order_repository.dart';
import 'package:foodapp/data/repositories/restaurant_repository.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
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

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");
  await TLocalStorage.init('food_app');

  await Firebase.initializeApp(
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
  );
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
    return MaterialApp.router(
      title: 'Food App',
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
      theme: ThemeData(
        primaryColor: TColor.primary,
        fontFamily: "Quicksand",
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: TColor.primary),
        ),
      ),
    );
  }
}
