import 'package:admin/dashborad_view.dart';
import 'package:admin/screens/banner/banner_screen.dart';
import 'package:admin/screens/category/category_screen.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/main/main_screen.dart';
import 'package:admin/screens/notifications/notification_screen.dart';
import 'package:admin/screens/restaurant/restaurant_screen.dart';
import 'package:admin/screens/setting/setting_screen.dart';
import 'package:admin/screens/shipper/shipper_screen.dart';
import 'package:admin/screens/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:admin/routes/name_router.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(child: Image.asset("assets/images/logo.png")),
          DrawerListTile(
            title: "Dashboard",
            svgSrc: "assets/icons/menu_dashboard.svg",
            press: () {
              context.go(NameRouter.dashboard);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Category",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              context.go(NameRouter.categories);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Restaurant",
            svgSrc: "assets/icons/menu_task.svg",
            press: () {
              context.go(NameRouter.restaurants);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Shipper",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              context.go(NameRouter.shippers);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "User",
            svgSrc: "assets/icons/menu_store.svg",
            press: () {
              context.go(NameRouter.users);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Notifications",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () {
              context.go(NameRouter.notifications);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Banner",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              context.go(NameRouter.banner);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {
              context.go(NameRouter.settings);
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
          DrawerListTile(
            title: "Logout",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {
              if (Scaffold.of(context).isDrawerOpen) {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: const ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(title, style: const TextStyle(color: Colors.white54)),
    );
  }
}
