# PowerTech - E-Commerce cho Linh Kiện Máy Tính

PowerTech là một hệ thống thương mại điện tử chuyên nghiệp được thiết kế đặc biệt cho lĩnh vực bán lẻ linh kiện máy tính, PC build và các thiết bị công nghệ (Retail-Tech).

Dự án được xây dựng dựa trên kiến trúc **ASP.NET Core MVC (Version 9.0)**, kết hợp cùng **Entity Framework Core (Code First)** và hệ thống phân quyền **ASP.NET Core Identity** mạnh mẽ.

---

## 🌟 Tóm tắt tính năng (Features Overview)

Hệ thống được chia thành 6 phân hệ (Areas) chính với cơ chế phân quyền (Role-based access control) chặt chẽ:

1. **Storefront (Hiển thị công khai)** 
   - Trang chủ linh động (Banners, Sản phẩm nổi bật/mới/sale).
   - Danh sách sản phẩm với bộ lọc phức hợp (Danh mục, Thương hiệu, Phân khúc giá, Sắp xếp).
   - Trang chi tiết hiển thị Specs, Gallery ảnh và trạng thái tồn kho thực tế.
2. **Customer Area (Khách hàng)**
   - Quản lý hồ sơ, thẻ thông tin cá nhân.
   - Sổ địa chỉ giao hàng.
   - Quản lý giỏ hàng & quy trình thanh toán (Checkout flow).
   - Lịch sử mua hàng, trạng thái đơn và tính năng Hủy đơn.
3. **Sales Area (Nhân viên Bán hàng)**
   - Dashboard xử lý đơn hàng.
   - POS (Tạo đơn hàng tại quầy nhanh chóng).
4. **Warehouse Area (Nhân viên Kho)**
   - Quản lý danh mục hàng hóa vật lý.
   - Thống kê tồn kho, cảnh báo sắp hết hàng.
   - Thực hiện phiếu nhập kho (Ghi nhận Lịch sử/Audit Trail).
5. **Support Area (Nhân viên CSKH)**
   - Hệ thống quản lý khiếu nại & vé hỗ trợ (Support Tickets).
   - Kiểm duyệt đánh giá (Reviews) từ người dùng.
6. **Admin Panel (Ban Giám Đốc / Quản trị viên)**
   - Quản trị viên điều hành toàn hệ thống với toàn quyền truy cập.
   - Quản lý Master Data: Category, Brand, Product, Spec...
   - Quản lý Người dùng & Cơ cấu tổ chức (Phân quyền Roles linh hoạt).

---

## 🛠 Nền tảng Kỹ thuật (Technical Stack)

- **Framework Backend:** ASP.NET Core MVC 9.0
- **Database:** Microsoft SQL Server
- **ORM:** Entity Framework Core (Tiếp cận Code First - Synchronized với DB có sẵn)
- **Authentication/Authorization:** ASP.NET Core Identity (Role-based & Multiple Roles)
- **Frontend Layer:** HTML5, Vanilla CSS (Thiết kế độc quyền, không phụ thuộc Tailwind/Bootstrap), JavaScript (ES6+).
- **CSS Architecture:** Bám sát UI Style Guide dành riêng cho bán lẻ công nghệ (Retail-Tech theme: Tone Đỏ/Đen, Box-shadow cao cấp, Animations mượt mà).
- **Tooling:** Dotnet CLI, MCP (Model Context Protocol) database inspection.

---

## 🚀 Hướng dẫn Cài đặt & Chạy ứng dụng (Getting Started)

### 1. Yêu cầu hệ thống (Prerequisites)
- .NET 9.0 SDK
- Microsoft SQL Server (Ví dụ: SQL Server Express hoặc Docker container)
- Visual Studio 2022 / JetBrains Rider hoặc VS Code

### 2. Thiết lập Database (Database Setup)
1. Mở file `PowerTech/appsettings.json` và cập nhật `DefaultConnection` trỏ tới hệ thống SQL Server của bạn. 
   *(Lưu ý: Đảm bảo thêm `TrustServerCertificate=True` nếu dùng localhost)*
2. Hệ thống đang sử dụng cơ chế **Tự động Seed dữ liệu**. Bảng cấu hình và dữ liệu mẫu (Sản phẩm, User, Quản trị viên) sẽ được tự tạo trong lần khởi chạy đầu tiên nếu Database chưa tồn tại.

### 3. Chạy Project
Sử dụng Terminal/Command Prompt, trỏ vào thư mục chứa file `.csproj` và chạy lệnh sau:
```bash
cd PowerTech
dotnet restore
dotnet build
dotnet run
```
Trang web sẽ cấu hình mặc định chạy ở cổng (Ví dụ: `http://localhost:5000` hoặc `https://localhost:5001`).

---

## 📚 Cấu trúc Thư mục Chính

- `/Areas/`: Chứa các module nghiệp vụ tách biệt (Admin, Store, Sales, Warehouse, Support, Customer). Mỗi Area có `Controllers` và `Views` riêng.
- `/Models/Entities/`: Lớp Models mapped với Database.
- `/Models/ViewModels/`: DTOs (Data Transfer Objects) chuyên biệt để render View, tránh rò rỉ Entity.
- `/Data/`: DbContext và các logic Migration, Seeding Data.
- `/wwwroot/`: Chứa các tài sản Front-end (CSS, JS) và thư viện ảnh (`/images/`, `/uploads/`).

---

## 📝 Bản Quyền

Dự án thực hiện cho đồ án môn học. Các hình ảnh minh họa thuộc về nhà cung cấp/hãng nguyên bản (ASUS, Intel, NVIDIA...).
