import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/category_viewmodel.dart';
import 'package:foodapp/viewmodels/home_viewmodel.dart';
import 'package:foodapp/view/authentication/viewmodel/signup_viewmodel.dart';
import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:foodapp/viewmodels/review_viewmodel.dart';
import 'package:foodapp/viewmodels/favorite_viewmodel.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:foodapp/viewmodels/notification_viewmodel.dart';

class SimpleProviders extends StatelessWidget {
  final Widget child;

  const SimpleProviders({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CategoryViewModel()),
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => ReviewViewModel()),
        ChangeNotifierProvider(create: (_) => FavoriteViewModel()),
        ChangeNotifierProvider(create: (context) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
      ],
      child: child,
    );
  }
}
