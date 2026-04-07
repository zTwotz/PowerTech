# PHASE_TASK_BREAKDOWN.md

> File này dùng để chia nhỏ toàn bộ đồ án **PowerTech** thành các giai đoạn, module và task cụ thể theo dạng checkbox.

---

# 1. Quy tắc sử dụng file này

## 1.1. Nguyên tắc chung
- Chỉ làm task của **giai đoạn hiện tại** hoặc giai đoạn kế tiếp khi giai đoạn trước đã đạt mức chấp nhận được.
- Mỗi task hoàn tất phải có:
  - file đã tạo/sửa
  - cách test
  - kết quả mong muốn
- Task liên quan database thật phải:
  - đọc schema trước qua MCP
  - không drop database
  - không truncate bảng
  - không xóa dữ liệu thật
  - migration phải additive
  - seeder phải idempotent
- Task liên quan UI phải:
  - đọc `.agent/ui_style_guide_for_ai_agent.md`
  - đọc các skill UI liên quan trong `.agent/skills/`
  - tái sử dụng component tối đa
  - bám đúng design system chung

## 1.2. Cách đánh dấu
- `[ ]` chưa làm
- `[~]` đang làm
- `[x]` đã xong
- `[-]` hoãn / không làm ở vòng hiện tại

---

# 2. Tổng quan roadmap
- Giai đoạn 1 — Phân tích & chốt phạm vi
- Giai đoạn 2 — Thiết kế dữ liệu & kiến trúc
- Giai đoạn 3 — Nền tảng kỹ thuật
- Giai đoạn 4 — Catalog core
- Giai đoạn 5 — Storefront & Customer MVP
- Giai đoạn 6 — Admin core
- Giai đoạn 7 — Sales / Warehouse / Support
- Giai đoạn 8 — Kiểm thử, seed demo, hoàn thiện báo cáo (Hoàn tất)
- Giai đoạn 9 — Bàn giao & Tài liệu (Đang tiến hành)

---

# 3. Giai đoạn 1 — Phân tích & chốt phạm vi

## Task
- [x] Xác định tên đề tài PowerTech
- [x] Xác định 6 Area
- [x] Xác định 6 nhóm người dùng
- [x] Chốt stack
- [x] Chốt cơ chế multi-role
- [x] Chốt nhóm chức năng chính
- [x] Chốt định hướng dữ liệu sản phẩm theo spec linh hoạt
- [x] Chốt danh sách màn hình chuẩn mức đồ án
- [x] Tạo file spec tổng
- [x] Ghi nhận có hệ skill `.agent/skills`
- [x] Ghi nhận có style guide `.agent/ui_style_guide_for_ai_agent.md`

## Deliverables
- `POWERTECH_MASTER_SPEC.md`

---

# 4. Giai đoạn 2 — Thiết kế dữ liệu & kiến trúc

## Task
- [x] Xác định ApplicationUser mở rộng từ IdentityUser
- [x] Chốt các field nền cho user
- [x] Chốt mô hình Category / Brand / Product
- [x] Chốt mô hình SpecificationDefinition / ProductSpecification
- [x] Chốt mô hình UserAddress / Cart / CartItem
- [x] Chốt mô hình Order / OrderItem / Payment
- [x] Chốt nguyên tắc delete behavior an toàn
- [x] Chốt route theo Area
- [x] Chốt authorization theo role
- [x] Chốt nguyên tắc migration additive + MCP-first
- [x] Chốt nguyên tắc UI theo style guide retail-tech

---

# 5. Giai đoạn 3 — Nền tảng kỹ thuật

## Task 3.1 — Khởi tạo solution và project
- [x] Tạo project ASP.NET Core MVC tên `PowerTech`
- [x] Chọn framework phù hợp với môi trường
- [x] Cài package EF Core, Identity, scaffolding cần thiết
- [x] Chuẩn hóa TargetFramework theo môi trường thực tế
- [x] Chuẩn hóa version package, tránh wildcard nếu cần

## Task 3.2 — Dựng cấu trúc thư mục nền
- [x] Tạo `Areas`
- [x] Tạo `Data`
- [x] Tạo `Data/Seeders`
- [x] Tạo `Models/Entities`
- [x] Tạo `Models/ViewModels`
- [x] Tạo `Services`
- [x] Tạo `Constants`
- [x] Tạo `Helpers`
- [x] Tạo skeleton 6 Areas
- [x] Tạo `_ViewStart.cshtml`
- [x] Tạo `_ViewImports.cshtml`
- [x] Chuẩn bị `.agent/skills`
- [x] Chuẩn bị `.agent/ui_style_guide_for_ai_agent.md`

## Task 3.3 — Identity nền
- [x] Tạo `ApplicationUser`
- [x] Kế thừa từ `IdentityUser`
- [x] Thêm field nền cho user
- [x] Sửa `FullName` từ nullable sang non-null nếu cần
- [x] Xử lý logic `IsActive`
- [x] Xử lý logic `MustChangePassword`

## Task 3.4 — DbContext nền
- [x] Tạo `ApplicationDbContext`
- [x] Kế thừa `IdentityDbContext<ApplicationUser>`
- [x] Cấu hình SQL Server
- [x] Kiểm tra thống nhất DB provider với file / migration cũ

## Task 3.5 — Role constants + seeder
- [x] Tạo `Constants/UserRoles.cs`
- [x] Tạo role chuẩn
- [x] Tạo `DbSeeder`
- [x] Seed role
- [x] Seed admin mặc định
- [x] Đảm bảo admin luôn có role kể cả khi user đã tồn tại
- [x] Đưa password admin ra khỏi source cứng nếu cần

## Task 3.6 — Program.cs
- [x] AddDbContext SQL Server
- [x] AddIdentity hỗ trợ role
- [x] AddControllersWithViews
- [~] AddRazorPages nếu dùng Identity UI
- [x] Map route cho Area
- [x] Route mặc định ưu tiên Store
- [x] Gọi seeder nền
- [~] Kiểm tra error handling / access denied / redirect

## Task 3.7 — Authorization theo Area
- [x] Store Area public
- [x] Customer Area cho Customer, Admin
- [x] Sales Area cho SalesStaff, Admin
- [x] Warehouse Area cho WarehouseStaff, Admin
- [x] Support Area cho SupportStaff, Admin
- [x] Admin Area chỉ cho Admin
- [x] Tạo controller mẫu kiểm tra route

## Definition of Done — Giai đoạn 3
- [x] Project build được
- [x] Có Identity nền
- [x] Có role và admin
- [x] Có route Area
- [x] Có auth theo role
- [~] Có thể đăng nhập test và đi đúng vào area
- [~] Có AddRazorPages nếu đang dùng Identity UI
- [~] Chuẩn hóa framework / packages / secrets

---

# 6. Giai đoạn 4 — Catalog core

## Task 4.1 — Đọc schema thật qua MCP
- [x] Kết nối MCP tới `TechZoneStoreDb`
- [x] Đọc schema các bảng liên quan catalog
- [x] So sánh schema thật với code hiện tại
- [x] Ghi nhận điểm lệch (Đã khớp 100%)
- [x] Chốt hướng migration additive (Không cần do đã khớp)

## Task 4.2 — Tạo entity catalog
- [x] Tạo `Category`
- [x] Tạo `Brand`
- [x] Tạo `Product`
- [x] Tạo `ProductImage`
- [x] Tạo `SpecificationDefinition`
- [x] Tạo `ProductSpecification`

## Task 4.3 — Cập nhật ApplicationDbContext cho catalog
- [x] Thêm DbSet catalog
- [x] Giữ `base.OnModelCreating(builder)`

## Task 4.4 — Fluent API cho catalog
- [x] Cấu hình các quan hệ catalog
- [x] Cấu hình precision decimal
- [x] Cấu hình unique slug / SKU
- [x] Cấu hình check constraint cần thiết
- [x] Cấu hình delete behavior an toàn

## Task 4.5 — Migration catalog an toàn
- [x] So sánh migration hiện có với schema thật
- [x] Chỉ tạo migration nếu thật sự cần (Xác nhận khớp)
- [x] Không drop / rename phá dữ liệu
- [x] Chỉ thêm bảng / cột / index an toàn

## Task 4.6 — Seeder catalog demo
- [x] Tạo `CatalogSeeder`
- [x] Seed Category demo
- [x] Seed Brand demo
- [x] Seed Product demo
- [x] Seed ProductImage demo tối thiểu
- [x] Seed SpecificationDefinition / ProductSpecification demo tối thiểu
- [x] Seeder phải idempotent

## Task 4.7 — Kiểm thử catalog
- [x] Query được danh sách category
- [x] Query được brand
- [x] Query được product
- [x] Lấy được images và specs của product
- [x] Không lỗi migration / seed

---

# 7. Giai đoạn 5 — Storefront & Customer MVP

## Quy tắc bắt buộc của giai đoạn này
- Mọi UI phải đọc `.agent/ui_style_guide_for_ai_agent.md`
- Phải đọc skill UI liên quan trong `.agent/skills`
- Phải dựng UI thống nhất trước khi mở rộng màn hình

## Module 5.1 — Auth pages
- [x] Trang đăng nhập
- [x] Trang đăng ký
- [x] Trang quên mật khẩu
- [x] Trang đổi mật khẩu
- [x] Redirect sau login theo role
- [x] AccessDenied page tối thiểu

## Module 5.2 — Store Home
- [x] Tạo Store HomeController hoàn chỉnh
- [x] Render trang chủ
- [x] Banner / hero section
- [x] Danh mục nổi bật
- [x] Sản phẩm nổi bật
- [x] Sản phẩm mới
- [x] Sản phẩm khuyến mãi
- [x] Section tin tức / chính sách tối thiểu
- [x] UI bám đúng retail-tech style

## Module 5.3 — Product list
- [x] Trang danh sách sản phẩm
- [x] Lọc theo category
- [x] Lọc theo brand
- [x] Lọc theo khoảng giá
- [-] Lọc theo specification cơ bản (Sẽ làm ở phase sau)
- [x] Sắp xếp
- [x] Phân trang
- [x] Filter bar đúng design system

## Module 5.4 — Product detail
- [x] Trang chi tiết sản phẩm
- [x] Gallery ảnh
- [x] Mô tả ngắn
- [x] Mô tả chi tiết
- [x] Thông số kỹ thuật
- [x] Trạng thái còn hàng
- [x] Gợi ý sản phẩm liên quan
- [x] Product card / info block đúng style

## Module 5.5 — UserAddress / Cart / CartItem data model
- [x] Đọc schema qua MCP
- [x] Tạo entity `UserAddress`
- [x] Tạo entity `Cart`
- [x] Tạo entity `CartItem`
- [x] Thêm DbSet
- [x] Cấu hình Fluent API
- [x] Migration additive an toàn nếu cần (Xác nhận khớp DB thực)

## Module 5.6 — Cart UI & logic
- [x] Add to cart
- [x] Xem giỏ hàng
- [x] Cập nhật số lượng
- [x] Xóa item
- [x] Tính tạm tính
- [x] UI giỏ hàng bám style guide

## Module 5.7 — Order / OrderItem / Payment data model
- [x] Đọc schema qua MCP
- [x] Tạo / cập nhật entity `Order`
- [x] Tạo / cập nhật entity `OrderItem`
- [x] Tạo / cập nhật entity `Payment`
- [x] Thêm DbSet
- [x] Cấu hình Fluent API
- [x] Migration additive an toàn nếu cần (Xác nhận khớp DB thực)

## Module 5.8 — Checkout
- [x] Trang checkout
- [x] Chọn địa chỉ
- [x] Chọn phương thức thanh toán
- [x] Review đơn
- [x] Tạo order từ cart
- [x] Tạo order items
- [x] Tạo payment record nền nếu cần
- [x] Dọn cart sau khi tạo order thành công
- [x] UI form/summary đúng style guide

## Module 5.9 — Customer profile
- [x] Trang hồ sơ
- [x] Cập nhật FullName
- [x] Cập nhật thông tin cá nhân cơ bản

## Module 5.10 — Customer address
- [x] Danh sách địa chỉ
- [x] Thêm địa chỉ
- [x] Sửa địa chỉ (Tích hợp thông qua Thêm/Xóa)
- [x] Xóa địa chỉ
- [x] Chọn mặc định

## Module 5.11 — Order history
- [x] Danh sách đơn hàng của tôi
- [x] Chi tiết đơn hàng
- [x] Timeline trạng thái đơn
- [x] Hủy đơn nếu hợp lệ

## Module 5.12 — Review cơ bản
- [x] Form đánh giá sản phẩm (Tích hợp trong Chi tiết / Customer)
- [x] Danh sách review của user
- [x] Trạng thái chờ duyệt nếu áp dụng

---

# 8. Giai đoạn 6 — Admin core

## Quy tắc UI của giai đoạn này
- dashboard, table, filter, form phải bám style guide
- sidebar/menu/page title/action bar phải nhất quán

## Module 6.1 — Admin Dashboard
- [x] Tạo dashboard admin
- [x] Thống kê tổng quan user
- [x] Thống kê tổng quan order
- [x] Cảnh báo hàng sắp hết
- [x] Điều hướng nhanh tới module quản trị

## Module 6.2 — User management
- [x] Danh sách user
- [x] Tìm kiếm user
- [x] Lọc theo role
- [x] Xem chi tiết user
- [x] Bật / tắt `IsActive`
- [x] Bật `MustChangePassword`

## Module 6.3 — Role management
- [x] Gán role cho user
- [x] Gỡ role của user
- [x] Hỗ trợ multi-role

## Module 6.4 — Create internal account
- [x] Form tạo tài khoản nội bộ
- [x] Chọn role lúc tạo
- [x] Tạo mật khẩu tạm
- [x] Set `MustChangePassword = true` nếu cần

## Module 6.5 — Category CRUD
- [x] Danh sách category
- [x] Tạo category
- [x] Sửa category
- [x] Xóa mềm / khóa category nếu cần
- [x] Quản lý parent category
- [x] Slug / display order / active

## Module 6.6 — Brand CRUD
- [x] Danh sách brand
- [x] Tạo brand
- [x] Sửa brand
- [x] Trạng thái active
- [x] Logo / country / slug

## Module 6.7 — Product CRUD
- [x] Danh sách product
- [x] Tạo product
- [x] Sửa product
- [x] Active / Featured
- [x] Giá / giảm giá / bảo hành
- [x] Thumbnail
- [x] Gắn category / brand

## Module 6.8 — Product image & specification management
- [x] Quản lý product images
- [x] Quản lý specification definitions
- [x] Quản lý product specifications
- [x] Đánh dấu spec filterable / required

## Module 6.9 — Review moderation cơ bản
- [x] Danh sách review
- [x] Duyệt review
- [x] Ẩn / từ chối review

---

# 9. Giai đoạn 7 — Sales / Warehouse / Support

## Quy tắc UI của giai đoạn này
- phải giống Admin về ngôn ngữ thiết kế
- khác nhau ở nội dung nghiệp vụ, không khác nhau ở design system

## Module 7.1 — Sales
- [x] Danh sách đơn mới
- [x] Chi tiết đơn
- [x] Xác nhận đơn
- [x] Cập nhật trạng thái đơn
- [x] Ghi chú xử lý
- [x] Hỗ trợ tạo đơn tại quầy mức cơ bản
- [x] Thống kê xử lý đơn cơ bản

## Module 7.2 — Warehouse
- [x] Khảo sát schema qua MCP
- [x] Đồng bộ entity nếu quyết định làm
- [x] Trang tồn kho
- [x] Trang hàng sắp hết
- [x] Trang nhập kho
- [x] Trang lịch sử / phiếu nhập

## Module 7.3 — Support
- [x] Khảo sát schema cho ticket / review / warranty / return
- [x] Đồng bộ entity tối thiểu cần dùng
- [x] Danh sách ticket
- [x] Chi tiết ticket
- [x] Cập nhật trạng thái ticket
- [x] Duyệt review
- [x] Màn hình bảo hành / đổi trả mức mở rộng

---

# 10. Giai đoạn 8 — Kiểm thử, seed demo, hoàn thiện báo cáo

## Task 8.1 — Test auth & role
- [x] Test Guest
- [x] Test Customer
- [x] Test SalesStaff
- [x] Test WarehouseStaff
- [x] Test SupportStaff
- [x] Test Admin
- [x] Test multi-role
- [x] Test route bị chặn
- [x] Test redirect sau login

## Task 8.2 — Test nghiệp vụ chính
- [x] Product list
- [x] Product detail
- [x] Filter
- [x] Cart
- [x] Checkout
- [x] Order history
- [x] Admin CRUD catalog
- [x] Sales xử lý đơn
- [x] Warehouse tồn kho
- [x] Support ticket/review

## Task 8.3 — Seed dữ liệu demo đẹp
- [x] Category demo đẹp
- [x] Brand demo đẹp
- [x] Product demo đẹp
- [x] Ảnh demo đủ trình bày
- [x] Review / ticket / order demo nếu cần
- [x] Seeder không tạo trùng

## Task 8.4 — Giao diện & UX
- [x] Responsive cơ bản
- [x] Layout đồng nhất
- [x] Menu điều hướng rõ
- [x] Trang lỗi / access denied / not found tối thiểu
- [x] Không còn màn hình placeholder lộ liễu
- [x] Toàn hệ thống bám đúng style guide

## Task 8.5 — Hồ sơ báo cáo
- [x] Chụp ảnh màn hình theo module
- [x] Chốt sitemap
- [x] Chốt mô hình dữ liệu
- [x] Chốt use case / sequence nếu cần
- [x] Chốt mô tả giai đoạn thực hiện
- [x] Chốt phần demo flow

---

# 11. Giai đoạn 9 — Bàn giao & Tài liệu

## Task 9.1 — Tài liệu kỹ thuật
- [x] Soạn thảo README.md hướng dẫn cài đặt & chạy project
- [x] Tài liệu hóa cấu trúc các Area và Routing
- [x] Mô tả cơ chế Authorization và Multi-role
- [x] Script SQL Final và hướng dẫn Seed dữ liệu (Đã tích hợp trong Seeder)

## Task 9.2 — Hướng dẫn sử dụng (User Manual)
- [x] Hướng dẫn cho Khách hàng (Mua hàng, Profile, Ticket)
- [x] Hướng dẫn cho Nhân viên (Sales, Warehouse, Support)
- [x] Hướng dẫn cho Quản trị viên (User Management, Catalog, Dashboard)

## Task 9.3 — Hoàn thiện gói bàn giao
- [x] Dọn dẹp mã nguồn (Cleanup unused code/logs)
- [x] Kiểm tra tính đóng gói (Portability)
- [x] Tạo file Handoff Summary

---

# 11. File agent nên ưu tiên đọc

## Luôn đọc trước
- [ ] `POWERTECH_MASTER_SPEC.md`
- [ ] `PROJECT_STATUS.md`
- [ ] `PHASE_TASK_BREAKDOWN.md`
- [ ] `AGENT_BOOTSTRAP_PROMPT.md`
- [ ] `PROMPT_LIBRARY_BY_PHASE.md`

## Đọc thêm khi làm UI
- [ ] `.agent/ui_style_guide_for_ai_agent.md`
- [ ] các skill UI liên quan trong `.agent/skills`

## Đọc thêm khi làm backend
- [ ] `Program.cs`
- [ ] `PowerTech.csproj`
- [ ] `Data/ApplicationDbContext.cs`
- [ ] `Data/Seeders/*`
- [ ] `Constants/UserRoles.cs`
- [ ] `Models/Entities/*`

---

# 12. Mẫu cập nhật tiến độ sau mỗi phiên

```md
## Session Update

### Done
- ...

### Skills Used
- ...

### UI Style Rules Applied
- ...

### Files Changed
- ...

### Tested
- ...

### Remaining
- ...

### Risks
- ...

### Suggested Next Step
- ...
```
