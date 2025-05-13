import 'package:admin/screens/category/category_screen.dart';
import 'package:admin/screens/notifications/notification_screen.dart';
import 'package:admin/screens/restaurant/restaurant_screen.dart';
import 'package:admin/screens/setting/setting_screen.dart';
import 'package:admin/screens/shipper/shipper_screen.dart';
import 'package:admin/screens/users/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
            press: () {},
          ),
          DrawerListTile(
            title: "Category",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryScreen(),
              ),
            ),
          ),
          DrawerListTile(
            title: "Restaurant",
            svgSrc: "assets/icons/menu_task.svg",
            press: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RestaurantScreen(),
              ),
            ),
          ),
          DrawerListTile(
            title: "Shipper",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ShipperScreen(),
              ),
            ),
          ),
          DrawerListTile(
            title: "User",
            svgSrc: "assets/icons/menu_store.svg",
            press: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UsersScreen()),
            ),
          ),
          DrawerListTile(
            title: "Notifications",
            svgSrc: "assets/icons/menu_notification.svg",
            press: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationScreen(),
              ),
            ),
          ),
          DrawerListTile(
            title: "Profile",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {},
          ),
          DrawerListTile(
            title: "Settings",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingScreen(),
              ),
            ),
          ),
          DrawerListTile(
            title: "Logout",
            svgSrc: "assets/icons/menu_setting.svg",
            press: () {},
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
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
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(title, style: TextStyle(color: Colors.white54)),
    );
  }
}
