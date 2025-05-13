import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/firebase_options.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/shipper_viewmodel.dart';
import 'package:admin/data/repositories/shipper_repository.dart';
import 'package:admin/viewmodels/restaurant_viewmodel.dart';
import 'package:admin/data/repositories/restaurant_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ShipperRepository()),
        ChangeNotifierProvider(
          create:
              (context) => ShipperViewModel(context.read<ShipperRepository>()),
        ),
        Provider(create: (_) => RestaurantRepository()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  RestaurantViewModel(context.read<RestaurantRepository>()),
        ),
        ChangeNotifierProvider(create: (context) => MenuAppController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ShipperRepository()),
        ChangeNotifierProvider(
          create:
              (context) => ShipperViewModel(context.read<ShipperRepository>()),
        ),
        Provider(create: (_) => RestaurantRepository()),
        ChangeNotifierProvider(
          create:
              (context) =>
                  RestaurantViewModel(context.read<RestaurantRepository>()),
        ),
        ChangeNotifierProvider(create: (context) => MenuAppController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Admin Panel',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          // textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
          //     .apply(bodyColor: Colors.white),
          // canvasColor: secondaryColor,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
