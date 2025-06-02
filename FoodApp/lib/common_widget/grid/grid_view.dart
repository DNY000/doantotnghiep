import 'package:flutter/material.dart';

class TGrid<T> extends StatelessWidget {
  final List<T> items;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool shrinkWrap;
  final bool scrollable;
  final bool showHeight;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final Widget Function(T item) itemBuilder;
  final Function(T item)? onTap;

  const TGrid({
    super.key,
    required this.items,
    required this.crossAxisCount,
    this.childAspectRatio = 1.0,
    this.mainAxisSpacing = 10,
    this.crossAxisSpacing = 10,
    this.shrinkWrap = false,
    this.scrollable = true,
    this.showHeight = false,
    this.scrollDirection = Axis.vertical,
    this.padding,
    required this.itemBuilder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: shrinkWrap,
      scrollDirection: scrollDirection,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisExtent: showHeight ? 120 : null,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: onTap != null ? () => onTap!(item) : null,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: itemBuilder(item),
          ),
        );
      },
    );
  }
}
