import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'package:go_router/go_router.dart';
import '../../common_widget/round_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView>
    with SingleTickerProviderStateMixin {
  bool isFirstTime = false;
  int selectPage = 0;
  final PageController pageController = PageController();
  final TLocalStorage storage = TLocalStorage.instance();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> infoArr = [
    {
      "title": "Món ăn đa dạng",
      "sub_title": "Vô vàn món ăn hấp dẫn chờ bạn khám phá",
      "image": "assets/images/food/ganran_on.png" // Placeholder image
    },
    {
      "title": "Giao hàng nhanh chóng",
      "sub_title": "Vừa đặt đơn đã có hàng ngay",
      "image": "assets/images/onboarding/giaohang1.png" // Placeholder image
    },
    {
      "title": "Ưu đãi hấp dẫn",
      "sub_title": "Trải nghiệm ngay",
      "image": "assets/images/onboarding/uudai1.png" // Placeholder image
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            Brightness.dark, // Changed to dark based on image background
      ),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Check if it's the first time or not, then forward animation.
    isFirstTime = storage.readData<bool>("isFirstTime") ?? true;

    // if (!isFirstTime) {
    //   // If not first time, navigate directly to login after a small delay
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) {
    //       FlutterNativeSplash.remove();
    //       context.go('/login');
    //     }
    //   });
    // } else {
    //   _animationController.forward();
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     FlutterNativeSplash.remove();
    //   });
    // }
    FlutterNativeSplash.remove();
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    const primaryOrange = Color(0xFFFF8C00);
    const lightOrange = Color(0xFFFFAB40);
    const yellowBackground = Color(0xFFFFF2CC);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background yellow circle/area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: media.height * 0.6, // Adjust height as needed
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white, // Use light yellow
                borderRadius: BorderRadius.only(
                  bottomLeft:
                      Radius.circular(media.width * 0.5), // Large radius
                  bottomRight:
                      Radius.circular(media.width * 0.5), // Large radius
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () {
                      pageController.animateToPage(
                        infoArr.length - 1,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Bỏ qua",
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: infoArr.length,
                    onPageChanged: (index) {
                      setState(() {
                        selectPage = index;
                      });
                      _animationController.reset();
                      _animationController.forward();
                    },
                    itemBuilder: (context, index) {
                      final iObj = infoArr[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: Image.asset(
                                      iObj["image"]!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text(
                                    iObj["title"]!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0),
                                  child: Text(
                                    iObj["sub_title"]!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                // Dots and Button Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      // Smooth page indicator
                      SmoothPageIndicator(
                        controller: pageController,
                        count: infoArr.length,
                        effect: const ExpandingDotsEffect(
                          activeDotColor: primaryOrange,
                          dotColor: lightOrange,
                          dotHeight: 8,
                          dotWidth: 8,
                          spacing: 8,
                          expansionFactor: 3,
                        ),
                        onDotClicked: (index) {
                          pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      if (selectPage < infoArr.length - 1)
                        InkWell(
                          onTap: () {
                            pageController.animateToPage(
                              selectPage + 1,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          borderRadius: BorderRadius.circular(30.0),
                          child: Container(
                            width: 60.0,
                            height: 60.0,
                            decoration: BoxDecoration(
                              color: primaryOrange,
                              borderRadius: BorderRadius.circular(30.0),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 30.0,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: RoundButton(
                              title: "BẮT ĐẦU NGAY",
                              backgroundColor: primaryOrange,
                              onPressed: () {
                                storage.saveData("isFirstTime", false);
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
