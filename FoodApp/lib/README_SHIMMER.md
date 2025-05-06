# Shimmer Effect trong ứng dụng FoodApp

Ứng dụng này đã tích hợp các hiệu ứng Shimmer để cải thiện trải nghiệm người dùng trong quá trình tải dữ liệu. Shimmer effect cung cấp một cảm giác mượt mà và chuyên nghiệp khi dữ liệu đang được tải.

## Các component có sẵn

Dự án này cung cấp các component shimmer sau đây:

### 1. TShimmer

Class chính để tạo hiệu ứng shimmer. Có thể được sử dụng để bọc bất kỳ widget nào để tạo hiệu ứng shimmer.

```dart
// Sử dụng constructor chính
TShimmer(
  child: YourWidget(),
  baseColor: Colors.grey.shade300,
  highlightColor: Colors.grey.shade100,
  direction: ShimmerDirection.ltr,
  enabled: true,
)

// Hoặc sử dụng các factory constructors
TShimmer.primary(child: YourWidget())
TShimmer.dark(child: YourWidget())
```

### 2. Các Widgets cơ bản

- **TShimmerBox**: Một hình chữ nhật với hiệu ứng shimmer, thường dùng cho các placeholder của text, buttons, etc.
- **TShimmerCircle**: Một hình tròn với hiệu ứng shimmer, thường dùng cho avatar, icons, etc.

```dart
const TShimmerBox(
  width: 200,
  height: 20,
  borderRadius: BorderRadius.all(Radius.circular(4)),
)

const TShimmerCircle(size: 60)
```

### 3. Các Shimmer View cho MainTabView

- **ShimmerHomeView**: Shimmer cho tab Trang chủ
- **ShimmerOrderView**: Shimmer cho tab Đơn hàng
- **ShimmerFavoritesView**: Shimmer cho tab Yêu thích
- **ShimmerNotificationsView**: Shimmer cho tab Thông báo
- **ShimmerProfileView**: Shimmer cho tab Tài khoản
- **ShimmerMainTabView**: Một TabView hoàn chỉnh có shimmer effect

## Cách tích hợp Shimmer vào màn hình hiện có

Để sử dụng shimmer trong các màn hình khác, bạn có thể tham khảo mẫu code sau:

```dart
// 1. Khai báo trạng thái loading
bool _isLoading = true;

// 2. Trong initState, giả lập thời gian tải
@override
void initState() {
  super.initState();

  // Giả lập thời gian tải dữ liệu
  Future.delayed(const Duration(milliseconds: 1500), () {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  });
}

// 3. Trong build method, kiểm tra trạng thái loading
@override
Widget build(BuildContext context) {
  if (_isLoading) {
    return ShimmerYourScreenView(); // Thay thế bằng shimmer view tương ứng
  }

  // Hiển thị nội dung thật khi đã tải xong
  return YourActualScreen();
}
```

## Cách tạo thêm Shimmer Views mới

Để tạo thêm shimmer views cho các màn hình khác, bạn có thể tham khảo các views hiện có và làm theo các bước sau:

1. Tạo một `StatelessWidget` mới
2. Sử dụng các thành phần `TShimmerBox` và `TShimmerCircle` để xây dựng giao diện shimmer tương tự với giao diện thực tế
3. Đảm bảo kích thước và bố cục của shimmer view phù hợp với giao diện thực tế

```dart
class ShimmerYourScreenView extends StatelessWidget {
  const ShimmerYourScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TShimmer.primary(
      child: Column(
        children: [
          // Tạo bố cục tương tự màn hình thực tế
          // sử dụng TShimmerBox và TShimmerCircle
        ],
      ),
    );
  }
}
```

## Tùy chỉnh Shimmer Effect

Bạn có thể tùy chỉnh hiệu ứng shimmer bằng cách thay đổi các tham số sau:

- **baseColor**: Màu nền cơ bản của shimmer
- **highlightColor**: Màu highlight khi hiệu ứng shine di chuyển qua
- **direction**: Hướng di chuyển của hiệu ứng (ltr, rtl, ttb, btt)
- **duration**: Thời gian để hoàn thành một chu kỳ shimmer

```dart
TShimmer(
  baseColor: Colors.grey.shade200,
  highlightColor: Colors.white,
  direction: ShimmerDirection.rtl,
  duration: const Duration(milliseconds: 1200),
  child: YourWidget(),
)
```
