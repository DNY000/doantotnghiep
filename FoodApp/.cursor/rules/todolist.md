# cursor.todo.md

## App: Ứng dụng đặt đồ ăn

### Kiến trúc:

- Flutter + MVVM + Provider
- Firebase: Auth, Firestore, Storage, Cloud Messaging
- GoRouter cho định tuyến
- Firebase OTP cho xác thực

---

### Người dùng

- Customer: đặt món, đánh giá, theo dõi đơn hàng
- Seller: quản lý món ăn, xác nhận đơn
- Shipper: nhận và giao đơn hàng, chat với khách
- Admin: quản lý hệ thống (qua web)

---

### Tính năng chính:

#### Auth

- Đăng nhập bằng số điện thoại (OTP)
- Đăng ký / Đăng nhập email-password

#### Món ăn

- Xem danh sách món ăn theo danh mục (gà rán, cơm, nước,...)
- Tìm kiếm món ăn
- Xem chi tiết món ăn
- Thêm vào giỏ hàng

#### Đơn hàng

- Đặt món (COD), thanh toán ví điện tử
- Xem và theo dõi đơn hàng đang giao
- Lịch sử đơn hàng

#### Đánh giá

- Sau khi nhận hàng, khách có thể đánh giá món ăn

#### Chat

- Chat realtime giữa khách hàng và shipper (Firebase Realtime DB)

---

--- MÔ TẢ QUY TRÌNH ĐẶT MÓN TỪ NGƯỜI DÙNG

- NGƯỜI DÙNG ĐĂNG NHẬP ỨNG DỤNG
- CHỌN MÓN ĂN CẦN ĐẶT
- KHI ĐÃ CHỌN XONG HIỂN THỊ MỘT BOTTOMSHETT THÔNG BÁO GIÁ . KHI BẤM VÀO SẼ CHUYỂN SANG TRANG ORDER
- CÒN NẾU NGƯỜI DÙNG KHÔNG BẤM VÀO MÓN ĂN ĐÃ CHỌN SẼ LƯU VÀO MỘT MÀN HÌNH (GIỐNG GIỎ HÀNG )
- KHI ĐẶT ĐƯỢC CHỌN VỊ TRÍ GIAO HÀNG , HÌNH THỨC THANH TOÁN
- SAU KHI ĐÃ XÁC NHẬN ĐẶT
- ĐƠN HÀNG SẼ CHUYỂN TRẠNG THÁI CHỜ NGƯỜI BÁN XÁC NHẬN
- ĐƠN ĐẶT HÀNG SẼ ĐƯỢC THÔNG BÁO CHO TÀI KHOẢN CỦA NGƯỜI BÁN
- NGƯỜI BÁN XÁC NHẬN => ĐƠN HÀNG SẼ ĐƯỢC CHUYỂN TRẠNG THÁI CHỜ SHIPPER =>
  NHỮNG SHIPPER XUNG QUANH SẼ NHẬN ĐƯỢC HIỂN THỊ NHỮNG ĐƠN HÀNG GẦN MÌNH
  => SAU KHI SHIPPER XÁC NHẬN ĐƠN HÀNG
  = đƠN HÀNG CHUYỂN TRẠNG THÁI ĐANG GIAO
  = kHI SHIPPER GIAO ĐẾN VÀ ( KHI SHIPPER XÁC NHẬN ĐƠN HÀNG GIAO THÀNH CÔNG )
  = ĐƠN HÀNG CHÍNH THỨC CHUYỂN TRẠNG THÁI THÀNH CÔNG

* NHƯNG TRONG PROJECT NÀY CHỈ CẦN LÀM ĐẾN BƯỚC (+ SAU KHI ĐÃ XÁC NHẬN ĐẶT )
  LÀ XONG NHỮNG BƯỚC KHÁC SẼ LÀM TẠI MỘT PROJECT KHÁC LIÊN KẾT
