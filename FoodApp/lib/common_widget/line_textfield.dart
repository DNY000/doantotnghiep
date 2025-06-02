import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class LineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hitText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool isClear;
  final VoidCallback? onClearPressed;

  const LineTextField(
      {super.key,
      required this.hitText,
      required this.controller,
      this.obscureText = false,
      this.keyboardType,
      this.isClear = false,
      this.onClearPressed,
      required String? Function(String? value) validator});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
            hintText: hitText,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: TColor.gray, width: 0.3),
                borderRadius: const BorderRadius.all(Radius.circular(12))),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: TColor.gray, width: 0.3),
                borderRadius: const BorderRadius.all(Radius.circular(12))),
            suffixIcon: isClear
                ? IconButton(
                    onPressed: () {
                      if (onClearPressed != null) {
                        onClearPressed!();
                      }
                    },
                    icon: Image.asset(
                      "assets/img/cancel.png",
                      width: 15,
                    ))
                : null),
      ),
    );
  }
}

class RoundTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hitText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool isClear;
  final VoidCallback? onClearPressed;
  final Widget? leftIcon;
  const RoundTextField(
      {super.key,
      required this.hitText,
      required this.controller,
      this.obscureText = false,
      this.keyboardType,
      this.isClear = false,
      this.leftIcon,
      this.onClearPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          color: TColor.gray, borderRadius: BorderRadius.circular(15)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
            hintText: hitText,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            prefixIcon: leftIcon,
            suffixIcon: isClear
                ? IconButton(
                    onPressed: () {
                      if (onClearPressed != null) {
                        onClearPressed!();
                      }
                    },
                    icon: Image.asset(
                      "assets/img/cancel.png",
                      width: 15,
                    ))
                : null),
      ),
    );
  }
}
