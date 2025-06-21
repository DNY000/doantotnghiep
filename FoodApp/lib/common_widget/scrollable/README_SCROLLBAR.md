# Hướng dẫn sử dụng Scrollbar Widgets

## Vấn đề

Trên các thiết bị Redmi/Xiaomi, khi chụp màn hình dài (long screenshot), các nút cuộn (scroll indicators) có thể bị ẩn đi do cách hệ thống MIUI xử lý chụp màn hình.

## Giải pháp

Sử dụng các widget tùy chỉnh trong thư mục `scrollable/` để hiển thị scrollbar rõ ràng hơn và đảm bảo nó không bị ẩn khi chụp màn hình.

## Các Widget có sẵn

### 1. TScrollableWidget

Widget tùy chỉnh cho SingleChildScrollView với scrollbar rõ ràng.

```dart
import 'package:foodapp/common_widget/scrollable/scrollable_widget.dart';

TScrollableWidget(
  child: Column(
    children: [
      // Your content here
    ],
  ),
)
```

### 2. TListView

Widget tùy chỉnh cho ListView với scrollbar rõ ràng.

```dart
import 'package:foodapp/common_widget/scrollable/scrollable_widget.dart';

TListView(
  children: [
    // Your list items here
  ],
)
```

### 3. TListViewBuilder

Widget tùy chỉnh cho ListView.builder với scrollbar rõ ràng.

```dart
import 'package:foodapp/common_widget/scrollable/scrollable_widget.dart';

TListViewBuilder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return YourListItem(item: items[index]);
  },
)
```

### 4. TGridView

Widget tùy chỉnh cho GridView với scrollbar rõ ràng.

```dart
import 'package:foodapp/common_widget/scrollable/scrollable_widget.dart';

TGridView(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.0,
  ),
  children: [
    // Your grid items here
  ],
)
```

### 5. TGridViewBuilder

Widget tùy chỉnh cho GridView.builder với scrollbar rõ ràng.

```dart
import 'package:foodapp/common_widget/scrollable/scrollable_widget.dart';

TGridViewBuilder(
  itemCount: items.length,
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    childAspectRatio: 1.0,
  ),
  itemBuilder: (context, index) {
    return YourGridItem(item: items[index]);
  },
)
```

## Tính năng đặc biệt

### Scrollbar luôn hiển thị

- `thumbVisibility: true` - Luôn hiển thị thumb của scrollbar
- `trackVisibility: true` - Luôn hiển thị track của scrollbar
- `thickness: 6.0` - Độ dày của scrollbar (có thể tùy chỉnh)
- `radius: const Radius.circular(3.0)` - Bo góc của scrollbar

### Tương thích với chụp màn hình

Các widget này được thiết kế để đảm bảo scrollbar vẫn hiển thị khi chụp màn hình dài trên các thiết bị Redmi/Xiaomi.

## Cách thay thế

### Thay thế SingleChildScrollView

```dart
// Thay vì:
SingleChildScrollView(
  child: YourContent(),
)

// Sử dụng:
TScrollableWidget(
  child: YourContent(),
)
```

### Thay thế ListView

```dart
// Thay vì:
ListView(
  children: yourChildren,
)

// Sử dụng:
TListView(
  children: yourChildren,
)
```

### Thay thế ListView.builder

```dart
// Thay vì:
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => YourItem(items[index]),
)

// Sử dụng:
TListViewBuilder(
  itemCount: items.length,
  itemBuilder: (context, index) => YourItem(items[index]),
)
```

## Lưu ý

- Các widget này tương thích với tất cả các thuộc tính của widget gốc
- Scrollbar sẽ luôn hiển thị, giúp người dùng dễ dàng nhận biết vị trí cuộn
- Đặc biệt hữu ích cho việc chụp màn hình dài trên các thiết bị Redmi/Xiaomi
