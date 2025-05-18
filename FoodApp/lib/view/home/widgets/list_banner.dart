import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ListBanner extends StatelessWidget {
  const ListBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final sizeContainer = MediaQuery.of(context).size.width * 0.5;
    List bannerArr = [
      {
        "image": "assets/images/f2.png",
        "title": "Special Offer!",
        "subtitle": "Get 20% off on your first order"
      },
      {
        "image": "assets/images/f3.png",
        "title": "New Arrivals",
        "subtitle": "Check out our latest menu items"
      },
      {
        "image": "assets/images/f4.png",
        "title": "Weekend Special",
        "subtitle": "Free delivery on orders above \$50"
      }
    ];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: CarouselSlider.builder(
        itemCount: bannerArr.length,
        itemBuilder: (context, index, realIndex) {
          return Container(
            width: MediaQuery.of(context).size.width - 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: AssetImage(bannerArr[index]["image"] as String),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    bannerArr[index]["title"] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bannerArr[index]["subtitle"] as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: sizeContainer,
          viewportFraction: 1,
          initialPage: 0,
          enableInfiniteScroll: true,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 3),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayCurve: Curves.fastOutSlowIn,
          enlargeCenterPage: false,
          enlargeFactor: 0.0,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
  }
}
