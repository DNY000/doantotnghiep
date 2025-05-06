# 🍔 App Đặt Đồ Ăn - PRD

## 1. Mục tiêu

- Hiển thị các quán ăn theo vị trí người dùng,
- Cho phép người dùng đặt nhiều món ăn từ quán khác nhau, theo dõi đơn hàng, - - - thanh toán và đánh giá món ăn.
- Ui mượt mà tối ưu , hạn chế sử dụng animation
- Responsive cho app sử dụng (flutter_screenUitl)
- Xây dựng widget tái sử dụng
- Phải đảm bảo đúng cấu trúc của firebase ( database)

## 2. Các chức năng chính

Đối với người dùng(user):

- Đăng nhập / Đăng ký bằng số điện thoại (OTP), email -password
- Hiển thị danh sách món ăn theo danh mục (bán chạy , gà rán, cơm ,phở..)
- Hiển thị danh sách quán ăn mới
- Hiển thị danh sách quán ăn 5\*
- Xem quán ăn gần vị trí, món ăn bán chạy, món ăn đánh giá tốt nhất ( dùng tabbar trong flutter)
- Tìm kiếm món ăn
- Thêm món ăn vào giỏ hàng
- Thanh toán qua COD / ví điện tử
- Xem lịch sử đơn hàng
- Đánh giá món ăn
- Nhắn tin trực tiếp với shipper

## 3. Người dùng

- Khách hàng (Customer)
- Chủ quán (Seller)
- Người giao hàng (shipper)
- Admin (Web quản trị)

## 5. Công nghệ

- Flutter (UI)
- Firebase (Auth, Firestore, Storage)
- google_maps_flutter:
- MVVM
- Provider
- Flutter (UI)
- Firebase:
  - FirebaseAuth (OTP, email/password)
  - Cloud Firestore (dữ liệu người dùng, món ăn, đơn hàng,...)
  - Firebase Storage (ảnh món ăn)
  - Firebase Cloud Messaging (thông báo)
- Provider (State Management)
- google_maps_flutter (hiển thị vị trí quán ăn, shipper)
- geolocator (lấy vị trí người dùng)
- cloud_functions (nếu xử lý logic server-side)
- socket.io hoặc Firebase Realtime Database (nếu muốn realtime chat)
