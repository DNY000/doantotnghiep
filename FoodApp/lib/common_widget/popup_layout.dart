import 'dart:ui';

import 'package:flutter/material.dart';

class PopupLayout extends ModalRoute {
  EdgeInsets? margin;
  Color? bgColor;
  final Widget child;

  @override
  Color? get barrierColor => bgColor ?? Colors.black.withOpacity(0.5);

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    margin ??= EdgeInsets.zero;

    return Material(
      type: MaterialType.transparency,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          margin: margin,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  @override
  bool get maintainState => false;

  @override
  bool get opaque => false;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 100);

  PopupLayout({Key? key, this.bgColor, required this.child, this.margin});

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
