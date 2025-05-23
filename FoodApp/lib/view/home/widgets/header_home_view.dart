import 'package:foodapp/common_widget/appbar/t_appbar.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/view/notifications/notification_view.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';

class HeaderHomeView extends StatefulWidget {
  const HeaderHomeView({super.key});

  @override
  State<HeaderHomeView> createState() => _HeaderHomeViewState();
}

class _HeaderHomeViewState extends State<HeaderHomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userVM = Provider.of<UserViewModel>(context);
    final city = userVM.city ?? "Bạn chưa chọn vị trí";
    final address = userVM.address ?? "Bạn chưa chọn vị trí";
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            city,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: TColor.text,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            address,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      // showBackArrow: isSelectCity,

      action: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            size: 24,
            color: TColor.text,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsView()),
            );
          },
        ),
      ],
    );
  }
}
