import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class AddCartButton extends StatelessWidget {
  final Function onPressed;
  final double? size;

  const AddCartButton({
    super.key,
    required this.onPressed,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPressed(),
        borderRadius: BorderRadius.circular(size ?? 20),
        child: Container(
          width: size ?? 40,
          height: size ?? 40,
          decoration: BoxDecoration(
            color: TColor.color3,
            borderRadius: BorderRadius.circular(size ?? 20),
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
