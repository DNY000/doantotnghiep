import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'package:go_router/go_router.dart';
import '../../common_widget/round_button.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView>
    with SingleTickerProviderStateMixin {
  bool isFirstTime = true;
  int selectPage = 0;
  final CarouselSliderController carouselController =
      CarouselSliderController();
  final TLocalStorage storage = TLocalStorage.instance();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> infoArr = [
    {
      "title": "Đặt món ăn yêu thích",
      "sub_title": "Chọn từ hàng ngàn món ăn ngon tuyệt",
      "icon": "assets/img/1.png"
    },
    {
      "title": "Giao hàng nhanh chóng",
      "sub_title": "Giao hàng tận nơi chỉ trong vài phút",
      "icon": "assets/img/2.png"
    },
    {
      "title": "Theo dõi đơn hàng",
      "sub_title": "Biết chính xác món ăn của bạn đang ở đâu",
      "icon": "assets/img/3.png"
    },
    {
      "title": "Thanh toán dễ dàng",
      "sub_title": "Nhiều phương thức thanh toán tiện lợi",
      "icon": "assets/img/4.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
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

    _animationController.forward();
    FlutterNativeSplash.remove();

    isFirstTime = storage.readData<bool>("isFirstTime") ?? true;

    if (!isFirstTime) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    const primaryOrange = Color(0xFFFF8C00);
    const lightOrange = Color(0xFFFFAB40);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  if (selectPage < infoArr.length - 1)
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () {
                          carouselController.animateToPage(infoArr.length - 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Bỏ qua",
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 56),
                  Expanded(
                    child: CarouselSlider(
                      carouselController: carouselController,
                      options: CarouselOptions(
                        height: media.height,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            selectPage = index;
                          });
                          _animationController.reset();
                          _animationController.forward();
                        },
                      ),
                      items: infoArr.map((iObj) {
                        return Builder(
                          builder: (BuildContext context) {
                            return AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Hero(
                                          tag:
                                              'onboarding_image_${infoArr.indexOf(iObj)}',
                                          child: Image.asset(
                                            iObj["icon"]!,
                                            width: media.width * 0.7,
                                            height: media.width * 0.7,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        Text(
                                          iObj["title"]!,
                                          style: TextStyle(
                                            color: primaryOrange,
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          iObj["sub_title"]!,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 16,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        SmoothPageIndicator(
                          controller: PageController(initialPage: selectPage),
                          count: infoArr.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: primaryOrange,
                            dotColor: lightOrange.withOpacity(0.3),
                            dotHeight: 8,
                            dotWidth: 8,
                            spacing: 8,
                            expansionFactor: 3,
                          ),
                          onDotClicked: (index) {
                            carouselController.animateToPage(index);
                          },
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: RoundButton(
                            title: selectPage == infoArr.length - 1
                                ? "Bắt đầu"
                                : "Tiếp theo",
                            backgroundColor: primaryOrange,
                            onPressed: () {
                              if (selectPage < infoArr.length - 1) {
                                carouselController
                                    .animateToPage(selectPage + 1);
                              } else {
                                storage.saveData("isFirstTime", false);
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              }
                            },
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
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
