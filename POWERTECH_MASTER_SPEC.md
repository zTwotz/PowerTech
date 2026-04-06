# POWERTECH_MASTER_SPEC.md

> Tài liệu gốc dùng chung cho:
> 1. đồ án website thương mại điện tử linh kiện máy tính  
> 2. AI agent Antigravity  
> 3. checklist kiểm soát tiến độ, phạm vi, màn hình, dữ liệu và giai đoạn triển khai

---

## 1. Mục đích của tài liệu

Tài liệu này là **source of truth** cho toàn bộ dự án **PowerTech**.

Nó có 6 vai trò cùng lúc:

1. Mô tả đầy đủ bài toán, phạm vi, tính năng, nghiệp vụ và màn hình của đồ án.
2. Chỉ rõ kiến trúc kỹ thuật, mô hình dữ liệu, Area, Role và quy tắc triển khai.
3. Làm **bảng điều hướng tiến độ** để AI agent biết hệ thống đang ở đâu và phải làm tiếp gì.
4. Làm **checklist nghiệm thu theo giai đoạn** để tránh làm lan man, sai thứ tự hoặc bỏ sót.
5. Làm nền để sinh prompt theo từng giai đoạn nếu cần, nhưng **không phụ thuộc vào việc viết prompt rời lẻ**.
6. Ràng buộc AI agent phải đọc **skill nội bộ** và **style guide giao diện** trước khi làm UI/UX.

---

## 2. Tuyên bố phạm vi dự án

### 2.1. Tên đề tài
**Website thương mại điện tử linh kiện máy tính — PowerTech**

### 2.2. Mục tiêu chính
Xây dựng một website bán linh kiện máy tính có:

- khu vực công khai cho khách xem sản phẩm
- khu vực khách hàng để quản lý tài khoản và đơn hàng
- khu vực nội bộ cho Sales, Warehouse, Support
- khu vực quản trị Admin
- phân quyền đa vai trò
- dữ liệu sản phẩm linh hoạt theo thông số kỹ thuật từng danh mục
- giỏ hàng, đặt hàng, theo dõi đơn, quản lý kho, hỗ trợ khách hàng

### 2.3. Phạm vi triển khai
Dự án chia thành **6 Area**:

- Store
- Customer
- Sales
- Warehouse
- Support
- Admin

Dự án phục vụ **6 nhóm người dùng**:

- Guest
- Customer
- SalesStaff
- WarehouseStaff
- SupportStaff
- Admin

### 2.4. Công nghệ chốt
- ASP.NET Core MVC
- EF Core Code First
- SQL Server
- ASP.NET Core Identity
- Area-based architecture
- Role-based authorization
- Multi-role user
- Migration-first / MCP-assisted safe schema sync

---

## 3. Nguồn điều phối bắt buộc cho AI agent

Trước khi làm việc, AI agent **bắt buộc** phải đọc đủ các nguồn sau:

### 3.1. File điều phối dự án
- `POWERTECH_MASTER_SPEC.md`
- `PROJECT_STATUS.md`
- `PHASE_TASK_BREAKDOWN.md`
- `PROMPT_LIBRARY_BY_PHASE.md`
- `AGENT_BOOTSTRAP_PROMPT.md`

### 3.2. Skill nội bộ của Antigravity
Agent phải rà thư mục:

```text
.agent/skills/
```

và đọc các skill liên quan trước khi thực hiện task, đặc biệt các nhóm:

- `agent-execution-rules`
- `aspnet-mvc-architecture`
- `component-library`
- `database-domain-rules`
- `ecommerce-business-rules`
- `frontend-design`
- `implementation-workflow`
- `navigation-screen-priority`
- `project-context`
- `testing-qa-review`
- `ui-style-system`

Nếu task thuộc backend, database, UI, testing hay workflow, agent phải ưu tiên đọc đúng skill liên quan trước khi code.

### 3.3. Style guide giao diện bắt buộc
Agent phải đọc file:

```text
.agent/ui_style_guide_for_ai_agent.md
```

trước khi làm bất kỳ màn hình, component, layout, table, card, form hay dashboard nào.

### 3.4. Nguyên tắc áp dụng style guide
Mọi UI phải bám chặt tinh thần:

- retail-tech hiện đại
- mạnh mẽ, rõ ràng, chuyên nghiệp
- thiên bán hàng và thao tác nhanh
- nền sáng
- màu thương hiệu đỏ là primary
- typography sans-serif hiện đại
- spacing, radius, border, shadow phải nhất quán
- Store thiên bán hàng
- Customer đơn giản hơn Store
- Admin/Sales/Warehouse/Support thiên dashboard, table, form

Không được:
- tự ý đổi tone màu chính
- mỗi màn hình một kiểu button/card
- quá nhiều gradient, glow, glassmorphism, neon
- làm Admin giống landing page marketing

---

## 4. Tóm tắt nghiệp vụ cốt lõi

### 4.1. Luồng công khai / bán hàng
- xem trang chủ
- xem danh mục
- xem danh sách sản phẩm
- xem chi tiết sản phẩm
- tìm kiếm
- lọc theo hãng, giá, thông số
- xem tin tức / chính sách / hướng dẫn mua hàng
- thêm vào giỏ hàng tạm
- đăng ký / đăng nhập

### 4.2. Luồng tài khoản & xác thực
- đăng ký tài khoản
- đăng nhập
- đăng xuất
- quên mật khẩu
- đổi mật khẩu
- cập nhật hồ sơ cá nhân
- quản lý địa chỉ nhận hàng
- quản lý user nhiều role
- Admin tạo tài khoản nội bộ
- Admin nâng quyền / gán vai trò

### 4.3. Luồng giỏ hàng & đặt hàng
- thêm sản phẩm vào giỏ hàng
- cập nhật số lượng
- xoá khỏi giỏ
- checkout
- chọn địa chỉ giao hàng
- chọn phương thức thanh toán
- tạo đơn
- xem lịch sử đơn
- xem chi tiết đơn
- theo dõi trạng thái
- hủy đơn hợp lệ
- đánh giá sản phẩm sau mua

### 4.4. Luồng vận hành nội bộ
- Sales xử lý đơn mới, xác nhận đơn, cập nhật trạng thái
- Warehouse quản lý tồn kho, nhập kho, theo dõi hàng sắp hết
- Support xử lý ticket, kiểm duyệt review, hỗ trợ bảo hành / đổi trả
- Admin quản lý toàn cục: tài khoản, vai trò, danh mục, thương hiệu, sản phẩm, dữ liệu hệ thống

---

## 5. Area, Role và quy tắc phân quyền

### 5.1. Role chuẩn
- Admin
- Customer
- SalesStaff
- WarehouseStaff
- SupportStaff

### 5.2. Quy tắc truy cập
- Store: public
- Customer Area: Customer, Admin
- Sales Area: SalesStaff, Admin
- Warehouse Area: WarehouseStaff, Admin
- Support Area: SupportStaff, Admin
- Admin Area: Admin

### 5.3. Quy tắc đa vai trò
Một user có thể có nhiều role cùng lúc. Ví dụ:
- SalesStaff + WarehouseStaff
- Customer + SupportStaff
- Admin là role cao nhất

### 5.4. Quy tắc đặc biệt
- User tự đăng ký => mặc định role Customer
- Admin có thể tạo tài khoản cho khách hàng hoặc nhân viên
- Admin có thể nâng quyền tài khoản Customer thành nhân viên nghiệp vụ
- Tài khoản nội bộ có thể bị bắt buộc đổi mật khẩu ở lần đăng nhập đầu

---

## 6. Kiến trúc hệ thống

### 6.1. Kiến trúc ứng dụng
Ứng dụng theo mô hình:

- ASP.NET Core MVC
- Area-based modularization
- Entity-based domain model
- Identity cho authentication + authorization
- EF Core Code First
- SQL Server
- Seeders cho role/admin/demo data
- Services cho nghiệp vụ
- ViewModels cho hiển thị
- Helpers / Constants cho logic dùng chung

### 6.2. Cấu trúc thư mục chuẩn
```text
PowerTech/
  .agent/
    skills/
    ui_style_guide_for_ai_agent.md
  Areas/
    Store/
    Customer/
    Sales/
    Warehouse/
    Support/
    Admin/
  Constants/
  Data/
    Seeders/
    Migrations/
  Models/
    Entities/
    ViewModels/
  Services/
  Helpers/
  Views/
  wwwroot/
```

### 6.3. Nguyên tắc tổ chức code
- Entity chỉ mô tả dữ liệu domain
- ViewModel dùng để bind ra View
- Không đưa nghiệp vụ nặng vào Controller
- Không thao tác database trực tiếp trong View
- Seed dữ liệu phải idempotent
- Migration phải ưu tiên additive, an toàn
- UI mới phải ưu tiên tái sử dụng component sẵn có
- Nếu tạo component mới, phải bám style guide và skill UI

---

## 7. Mô hình dữ liệu cốt lõi

### 7.1. Nhóm Identity & người dùng
- ApplicationUser
- IdentityRole
- AspNetUserRoles
- UserAddress

### 7.2. Nhóm danh mục & sản phẩm
- Category
- Brand
- Product
- ProductImage
- SpecificationDefinition
- ProductSpecification

### 7.3. Nhóm giỏ hàng & đơn hàng
- Cart
- CartItem
- Order
- OrderItem
- Payment

### 7.4. Nhóm hỗ trợ & vận hành mở rộng
- Review
- SupportTicket
- Supplier
- PurchaseReceipt
- PurchaseReceiptItem
- StockTransaction

### 7.5. Tư duy mô hình hóa
Không tạo bảng riêng kiểu:
- Products_Laptop
- Products_Monitor
- Products_Mouse

Thay vào đó:
- `Products` lưu thông tin chung
- `SpecificationDefinitions` định nghĩa loại thông số theo Category
- `ProductSpecifications` lưu giá trị thông số cụ thể của từng Product

---

## 8. Quan hệ dữ liệu quan trọng

### 8.1. Quan hệ catalog
- Category 1-n Product
- Brand 1-n Product
- Category 1-n SpecificationDefinition
- Product 1-n ProductImage
- Product 1-n ProductSpecification
- SpecificationDefinition 1-n ProductSpecification

### 8.2. Quan hệ user
- ApplicationUser 1-n UserAddress
- ApplicationUser n-n Role thông qua Identity
- ApplicationUser 1-n Order
- ApplicationUser 1-n Cart hoặc 1-1 Cart tùy schema thật

### 8.3. Quan hệ giỏ hàng
- Cart 1-n CartItem
- Product 1-n CartItem

### 8.4. Quan hệ đơn hàng
- Order 1-n OrderItem
- Product 1-n OrderItem
- Order 1-n Payment hoặc 1-1 Payment tùy schema thật

### 8.5. Delete behavior gợi ý
- Category -> Product: Restrict
- Brand -> Product: Restrict
- Product -> ProductImages: Cascade
- Product -> ProductSpecifications: Cascade
- Cart -> CartItems: Cascade
- Product -> OrderItems: Restrict
- User -> Order: Restrict / NoAction
- Order -> OrderItems: Cascade hoặc Restrict tùy chính sách
- Không xóa cứng dữ liệu giao dịch nếu đã phát sinh lịch sử

---

## 9. Ràng buộc dữ liệu & quy tắc nghiệp vụ

### 9.1. Ràng buộc dữ liệu
- Price >= 0
- DiscountPrice >= 0
- DiscountPrice <= Price
- StockQuantity >= 0
- SoldQuantity >= 0
- WarrantyMonths >= 0
- Quantity > 0
- Amount >= 0

### 9.2. Ràng buộc duy nhất
- Categories.Slug unique
- Brands.Slug unique
- Products.SKU unique
- Products.Slug unique
- SpecificationDefinitions(CategoryId, SpecName) unique
- ProductSpecifications(ProductId, SpecDefinitionId) unique
- Carts.UserId unique nếu mô hình chốt là 1 user 1 cart

### 9.3. Quy tắc nghiệp vụ
- chỉ sản phẩm active mới được thêm giỏ hàng
- checkout phải có ít nhất 1 cart item
- order phải có ít nhất 1 order item
- không cho tồn kho âm
- không xóa sản phẩm đã phát sinh đơn, chỉ chuyển IsActive = false
- review chỉ dành cho user hợp lệ sau mua nếu muốn siết nghiệp vụ
- MustChangePassword phải được kiểm tra ở luồng đăng nhập nội bộ

---

## 10. Danh mục sản phẩm chuẩn

Danh mục gợi ý dùng cho demo và triển khai:
- Laptop
- PC bộ
- CPU
- Mainboard
- RAM
- Card đồ họa
- Ổ cứng / Storage
- Nguồn máy tính
- Case
- Màn hình
- Bàn phím
- Chuột
- Tai nghe
- Micro
- Loa
- Thiết bị mạng
- Phụ kiện & Phần mềm

---

## 11. Chức năng chi tiết theo từng nhóm người dùng

### 11.1. Guest
Được phép:
- xem trang chủ
- xem danh mục
- xem danh sách sản phẩm
- xem chi tiết sản phẩm
- tìm kiếm
- lọc theo hãng / giá / thông số
- xem tin tức / chính sách
- thêm giỏ hàng tạm
- đăng ký
- đăng nhập

Không được:
- đặt hàng chính thức nếu chưa đăng nhập
- truy cập Area nội bộ

### 11.2. Customer
Có toàn bộ quyền của Guest, cộng thêm:
- quản lý hồ sơ cá nhân
- quản lý địa chỉ nhận hàng
- đặt hàng
- theo dõi đơn hàng
- xem lịch sử đơn hàng
- hủy đơn hợp lệ
- đánh giá sản phẩm
- đổi mật khẩu / quên mật khẩu

### 11.3. SalesStaff
- xem đơn mới
- xác nhận đơn
- cập nhật trạng thái đơn
- liên hệ khách hàng
- hỗ trợ tạo đơn tại quầy
- theo dõi tiến độ xử lý đơn

### 11.4. WarehouseStaff
- xem tồn kho
- nhập kho
- điều chỉnh tồn theo phiếu hợp lệ
- theo dõi hàng sắp hết
- xem lịch sử nhập kho / giao dịch kho

### 11.5. SupportStaff
- xem ticket hỗ trợ
- xử lý ticket
- kiểm duyệt review
- hỗ trợ bảo hành / đổi trả
- cập nhật trạng thái xử lý

### 11.6. Admin
- dashboard tổng quan
- quản lý user
- gán / gỡ role
- tạo tài khoản nội bộ
- quản lý category
- quản lý brand
- quản lý product
- quản lý definition/spec
- quản lý trạng thái hệ thống
- có thể truy cập các Area nội bộ khác theo cấu hình role

---

## 12. Danh sách màn hình chuẩn triển khai

### 12.1. Store / Auth / Customer-facing
- ST-01 — Trang đăng nhập
- ST-02 — Trang đăng ký
- ST-03 — Trang quên mật khẩu / đổi mật khẩu
- ST-04 — Trang chủ
- ST-05 — Trang danh mục / danh sách sản phẩm
- ST-06 — Trang chi tiết sản phẩm
- ST-07 — Trang tin tức / chính sách / hướng dẫn mua hàng
- ST-08 — Trang giỏ hàng
- ST-09 — Trang thanh toán

### 12.2. Customer Area
- CU-01 — Trang hồ sơ cá nhân
- CU-02 — Trang địa chỉ nhận hàng
- CU-03 — Trang đơn hàng của tôi
- CU-04 — Trang chi tiết đơn hàng
- CU-05 — Trang đánh giá sản phẩm

### 12.3. Admin Area
- AD-01 — Dashboard Admin
- AD-02 — Quản lý tài khoản người dùng
- AD-03 — Tạo tài khoản / cập nhật vai trò
- AD-04 — Quản lý danh mục
- AD-05 — Quản lý thương hiệu
- AD-06 — Quản lý sản phẩm
- AD-07 — Quản lý hình ảnh & thông số sản phẩm
- AD-08 — Quản lý đánh giá / nội dung
- AD-09 — Báo cáo nhanh / điều phối hệ thống

### 12.4. Sales Area
- SA-01 — Trang đơn hàng mới
- SA-02 — Trang chi tiết đơn hàng
- SA-03 — Trang xác nhận / cập nhật trạng thái đơn
- SA-04 — Trang hỗ trợ tạo đơn tại quầy
- SA-05 — Trang theo dõi đơn / hiệu suất xử lý

### 12.5. Warehouse Area
- WH-01 — Trang tồn kho
- WH-02 — Trang nhập kho
- WH-03 — Trang chi tiết nhập kho / điều chỉnh kho
- WH-04 — Trang hàng sắp hết
- WH-05 — Trang phiếu nhập / lịch sử kho

### 12.6. Support Area
- SP-01 — Trang danh sách ticket hỗ trợ
- SP-02 — Trang chi tiết ticket
- SP-03 — Trang kiểm duyệt đánh giá
- SP-04 — Trang hỗ trợ bảo hành / đổi trả

---

## 13. Quy tắc giao diện bắt buộc

### 13.1. Tone chung
- công nghệ
- mạnh mẽ
- sạch sẽ
- chuyên nghiệp
- tin cậy
- tập trung chuyển đổi

### 13.2. Hệ màu chung
- primary đỏ
- nền trắng / xám rất nhạt
- chữ gần đen
- border xám nhạt
- success/warning/danger/info rõ ràng

### 13.3. Typography
- sans-serif hiện đại
- page title rõ
- section title rõ
- card title / product title dễ đọc
- giá và CTA luôn nổi bật

### 13.4. Component system
- button phải có primary / secondary / danger thống nhất
- input/select/textarea đồng nhất
- card đồng nhất
- product card phải rõ ảnh/tên/giá/cta
- table admin/staff phải rõ ràng, dễ quét
- badge trạng thái nhỏ gọn, dễ đọc

### 13.5. Theo từng Area
- Store: thiên bán hàng
- Customer: thiên self-service
- Admin/Sales/Warehouse/Support: thiên dashboard, table, form

### 13.6. Responsive
- desktop-first
- tablet thu gọn hợp lý
- mobile không vỡ layout

### 13.7. Điều kiện bắt buộc trước khi chốt UI
Agent phải tự kiểm:
- đúng màu
- đúng spacing
- đúng typography
- đúng button/card/table/input system
- đúng tinh thần retail-tech
- đã tái sử dụng component cũ tối đa chưa

---

## 14. Lộ trình triển khai chuẩn

### Giai đoạn 1 — Phân tích
- chốt đề tài
- chốt phạm vi
- chốt Area và Role
- chốt danh sách chức năng chính

### Giai đoạn 2 — Thiết kế
- thiết kế dữ liệu
- thiết kế wireframe / luồng màn hình
- chốt category và cấu trúc specification

### Giai đoạn 3 — Nền tảng kỹ thuật
- khởi tạo project
- cấu hình EF Core
- cấu hình SQL Server
- cấu hình Identity
- seed role và admin
- cấu hình Area + route + auth nền

### Giai đoạn 4 — Storefront & Customer MVP
- trang chủ
- danh mục
- chi tiết sản phẩm
- tìm kiếm, lọc
- giỏ hàng
- thanh toán
- hồ sơ
- địa chỉ
- đơn hàng của tôi
- chi tiết đơn
- đổi/quên mật khẩu

### Giai đoạn 5 — Admin
- dashboard
- quản lý user
- quản lý role
- quản lý category
- quản lý brand
- quản lý product
- quản lý specification
- quản lý review cơ bản

### Giai đoạn 6 — Sales / Warehouse / Support
- Sales xử lý đơn
- Warehouse quản lý tồn và nhập kho
- Support xử lý ticket và review

### Giai đoạn 7 — Kiểm thử & tối ưu
- test chức năng
- test role
- test multi-role
- test responsive
- seed dữ liệu demo
- sửa lỗi
- chuẩn bị báo cáo

---

## 15. Definition of Done theo giai đoạn

### 15.1. DoD — Giai đoạn 3
- project build thành công
- connect được SQL Server
- Identity chạy ổn
- role seed thành công
- admin seed thành công
- Area route hoạt động
- authorize theo role hoạt động

### 15.2. DoD — Giai đoạn 4
- xem được product list
- xem được product detail
- filter hoạt động
- cart hoạt động
- checkout tạo được order
- customer xem được lịch sử đơn

### 15.3. DoD — Giai đoạn 5
- admin CRUD được category / brand / product
- admin quản lý được user / role
- admin tạo tài khoản nội bộ
- admin cập nhật role thành công

### 15.4. DoD — Giai đoạn 6
- sales xử lý được đơn
- warehouse cập nhật được tồn và phiếu nhập
- support xử lý được ticket / review
- quyền truy cập từng Area đúng

### 15.5. DoD — Giai đoạn 7
- có dữ liệu demo sạch
- không lỗi route chính
- không lỗi auth chính
- giao diện đủ demo
- báo cáo và slide chuẩn bị được

---

## 16. Quy tắc làm việc dành cho AI agent

### 16.1. Nguyên tắc chung
AI agent phải luôn:
- đọc file này trước khi làm việc
- đọc `PROJECT_STATUS.md`
- đọc `PHASE_TASK_BREAKDOWN.md`
- đọc `.agent/skills` liên quan
- đọc `.agent/ui_style_guide_for_ai_agent.md` nếu task liên quan UI
- xác định giai đoạn hiện tại
- không nhảy sang giai đoạn sau khi giai đoạn trước chưa đạt DoD
- ưu tiên đúng phạm vi đồ án
- không thêm tính năng ngoài phạm vi nếu chưa được phê duyệt

### 16.2. Với database
- luôn ưu tiên đọc schema thật trước nếu có MCP
- không giả định database trống
- không drop database
- không truncate bảng
- không xóa dữ liệu thật
- migration phải additive và an toàn
- seeder phải idempotent

### 16.3. Với code
- không viết logic lớn trong Controller
- ưu tiên service cho nghiệp vụ
- dùng ViewModel cho dữ liệu ra View
- không dùng entity trực tiếp để render giao diện phức tạp nếu dễ lộ dữ liệu nhạy cảm
- không hard-code role string rời rạc; dùng Constants/UserRoles

### 16.4. Với quyền truy cập
- luôn kiểm tra Area + role
- luôn hỗ trợ Admin là quyền cao nhất
- luôn để ý trường hợp multi-role
- không làm hỏng logic redirect sau login

### 16.5. Với UI/UX
- phải đọc style guide trước
- phải tái sử dụng component tối đa
- phải giữ hệ màu/tone/radius/spacing/typography nhất quán
- ưu tiên tính nhất quán hơn hiệu ứng đẹp
- ưu tiên tính dễ dùng hơn trình diễn

### 16.6. Với prompt execution
Khi nhận task mới, AI agent phải tự trả lời 6 câu trước:
1. Task này thuộc giai đoạn nào?
2. Có nằm trong phạm vi file này không?
3. Phụ thuộc dữ liệu / entity / route nào?
4. Có rủi ro auth / migration / dữ liệu không?
5. Có skill nào trong `.agent/skills` cần đọc trước không?
6. Nếu có UI, đã đọc `.agent/ui_style_guide_for_ai_agent.md` chưa?

---

## 17. Cơ chế cập nhật tiến độ trong repo

Tạo hoặc cập nhật file:
`PROJECT_STATUS.md`

Agent phải cập nhật sau mỗi phiên:
- Current Phase
- Last Completed
- In Progress
- Next Recommended
- DoD checklist tương ứng

---

## 18. Gợi ý thứ tự code tối ưu
1. Identity + Area auth
2. Catalog entities + DbContext
3. Catalog migration + seed demo
4. Store list/detail/filter
5. Cart
6. Order / Payment nền
7. Customer profile/address/order history
8. Admin CRUD
9. Sales
10. Warehouse
11. Support
12. Final QA

---

## 19. Trạng thái hiện tại gợi ý từ source tree đã thấy

### Đã có
- project PowerTech
- ASP.NET Core MVC
- Area skeleton
- Identity nền
- ApplicationUser
- ApplicationDbContext
- role constants
- seeder role/admin
- Program.cs có route Area
- authorize theo Area cơ bản
- hệ skill `.agent/skills`
- style guide `.agent/ui_style_guide_for_ai_agent.md`

### Có khả năng đang làm dở
- catalog entities
- DbContext catalog
- safe migration với DB thật
- seed category / brand / product demo
- cart / order / payment domain

### Chưa nên coi là hoàn tất nếu chưa test
- redirect theo role sau login
- logic MustChangePassword
- sync migration với TechZoneStoreDb thật
- full CRUD nghiệp vụ các Area
- consistency UI theo style guide

---

## 20. Kết luận định hướng

PowerTech không chỉ là website bán hàng đơn giản mà là một hệ thống thương mại điện tử có:
- storefront công khai
- customer self-service
- internal operations
- centralized admin control
- flexible technical specifications
- multi-role security model
- design system retail-tech nhất quán

Muốn làm đúng và nhanh, phải bám:
- **đúng phạm vi**
- **đúng giai đoạn**
- **đúng dữ liệu**
- **đúng role**
- **đúng Definition of Done**
- **đúng skill**
- **đúng style guide**

Tài liệu này là mốc chuẩn để AI agent và người làm đồ án cùng nhìn về một hướng.
