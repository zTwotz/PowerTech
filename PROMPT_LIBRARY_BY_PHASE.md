# PROMPT_LIBRARY_BY_PHASE.md

> Thư viện prompt chuẩn theo từng giai đoạn cho dự án **PowerTech**.

---

# 1. Prompt khởi động chuẩn cho mọi phiên

```text
Trước khi làm bất kỳ việc gì, hãy đọc 5 file sau:
1. POWERTECH_MASTER_SPEC.md
2. PROJECT_STATUS.md
3. PHASE_TASK_BREAKDOWN.md
4. AGENT_BOOTSTRAP_PROMPT.md
5. PROMPT_LIBRARY_BY_PHASE.md

Sau đó:
- xác định giai đoạn hiện tại của dự án
- xác định những task đang [~] hoặc [ ]
- chọn đúng 1 cụm task gần nhau nhất để làm
- không làm lan sang giai đoạn sau

Tiếp theo:
- nếu task liên quan database SQL Server thật thì phải read schema first qua MCP
- nếu task liên quan UI/UX thì phải đọc `.agent/ui_style_guide_for_ai_agent.md`
- nếu task liên quan kiến trúc, workflow, UI, database, testing thì phải đọc các skill phù hợp trong `.agent/skills/`

Ràng buộc:
- migration phải additive, an toàn
- seeder phải idempotent
- UI phải bám style guide retail-tech
- ưu tiên tính nhất quán > tính dễ dùng > tính đẹp

Cuối phiên phải báo:
1. đã làm gì
2. skill nào đã dùng
3. style rules nào đã áp
4. file nào đã tạo hoặc sửa
5. task nào đã chuyển trạng thái
6. đã đạt Definition of Done nào chưa
7. bước tiếp theo nên là gì
8. PROJECT_STATUS.md cần cập nhật ra sao
```

---

# 2. Prompt tổng quát theo giai đoạn

## 2.1. Prompt triển khai trọn một giai đoạn

```text
Dựa trên:
- POWERTECH_MASTER_SPEC.md
- PROJECT_STATUS.md
- PHASE_TASK_BREAKDOWN.md
- AGENT_BOOTSTRAP_PROMPT.md
- PROMPT_LIBRARY_BY_PHASE.md

Hãy triển khai Giai đoạn <X> của dự án PowerTech.

Bắt buộc:
- nếu liên quan UI thì đọc `.agent/ui_style_guide_for_ai_agent.md`
- đọc các skill liên quan trong `.agent/skills/`

Yêu cầu:
- chỉ làm các task thuộc giai đoạn này
- bám đúng phạm vi, role, area, entity và màn hình trong MASTER SPEC
- nếu liên quan database thật thì phải read schema first qua MCP
- không drop database
- không truncate bảng
- không xóa dữ liệu thật
- migration phải additive
- seed phải idempotent
- code sạch, dễ mở rộng, tránh nhồi logic lớn vào Controller
- UI phải dùng đúng tone retail-tech, màu primary đỏ, spacing, typography, card/button/table/input rules

Đầu ra bắt buộc:
- danh sách file đã tạo/sửa
- skill đã dùng
- style guide rules đã áp
- phần nào đã hoàn tất
- phần nào còn thiếu
- cách test
- đã đạt Definition of Done nào của giai đoạn này
- đề xuất cập nhật PROJECT_STATUS.md
```

## 2.2. Prompt triển khai một cụm task trong giai đoạn

```text
Dựa trên 5 file nền của dự án PowerTech, hãy chọn và triển khai đúng 1 cụm task gần nhau nhất trong Giai đoạn <X>.

Trước khi làm:
- xác định có cần đọc skill nào trong `.agent/skills/` không
- nếu có UI thì đọc `.agent/ui_style_guide_for_ai_agent.md`

Ràng buộc:
- không làm lan sang task xa hơn
- không nhảy sang giai đoạn sau
- nếu task có phụ thuộc dữ liệu hoặc DB thật thì phải kiểm tra qua MCP trước
- nếu task có UI thì phải bám style guide
- sau khi xong phải báo rõ task nào trong PHASE_TASK_BREAKDOWN.md đã có thể chuyển từ [ ] sang [x]

Đầu ra:
- file đã sửa
- skill đã dùng
- kết quả
- test
- rủi ro còn lại
- bước kế tiếp hợp lý nhất
```

---

# 3. Prompt cho Giai đoạn 3 — Nền tảng kỹ thuật

## 3.1. Chuẩn hóa project nền

```text
Dựa trên 5 file nền của PowerTech, hãy rà soát và chuẩn hóa phần nền tảng kỹ thuật hiện có.

Mục tiêu:
- kiểm tra PowerTech.csproj
- kiểm tra Program.cs
- kiểm tra Identity setup
- kiểm tra ApplicationUser
- kiểm tra ApplicationDbContext
- kiểm tra DbSeeder và UserRoles
- kiểm tra route Area và authorization
- vá các điểm chưa ổn nhưng không làm lan sang module nghiệp vụ

Đầu ra:
- file đã sửa
- skill đã dùng
- những lỗi nền đã khắc phục
- cách test login / role / route
- checklist DoD của Giai đoạn 3 đã đạt tới đâu
```

---

# 4. Prompt cho Giai đoạn 4 — Catalog core

## 4.1. Đồng bộ entity catalog với DB thật

```text
Dựa trên 5 file nền của PowerTech, hãy hoàn tất module catalog core.

Yêu cầu:
- phải read schema first qua MCP đối với TechZoneStoreDb
- kiểm tra các bảng:
  - Categories
  - Brands
  - Products
  - ProductImages
  - SpecificationDefinitions
  - ProductSpecifications
- so sánh schema thật với code hiện tại
- tạo hoặc cập nhật entity
- thêm DbSet và Fluent API
- migration chỉ được tạo nếu thật sự cần và phải additive
- seed demo phải idempotent
- không tạo dữ liệu trùng nếu DB thật đã có dữ liệu

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- summary schema thật
- điểm lệch đã xử lý
- migration có/không và vì sao
- cách test query catalog
```

## 4.2. Seeder catalog demo an toàn

```text
Dựa trên 5 file nền của PowerTech, hãy tạo hoặc hoàn thiện seeder dữ liệu demo cho module catalog.

Yêu cầu:
- read schema và dữ liệu thật qua MCP trước
- chỉ seed khi cần
- seeder phải idempotent
- không tạo trùng category / brand / product

Đầu ra:
- seeder đã tạo/sửa
- skill đã dùng
- strategy seed
- dữ liệu demo dự kiến
- cách test
```

---

# 5. Prompt cho Giai đoạn 5 — Storefront & Customer MVP

## 5.1. Prompt dựng nền UI chung trước khi làm màn hình

```text
Dựa trên 5 file nền của PowerTech, hãy dựng nền UI chung cho Storefront và Customer trước khi làm từng màn hình.

Bắt buộc:
- đọc `.agent/ui_style_guide_for_ai_agent.md`
- đọc các skill UI liên quan trong `.agent/skills/`

Mục tiêu:
- xác định các layout chung
- xác định màu primary, text, border, surface
- xác định typography scale
- xác định spacing scale
- xác định button, input, card, table, badge chuẩn
- tạo hoặc chuẩn hóa shared layout / partial / CSS tokens / component partials nếu phù hợp với stack hiện tại

Không làm lan sang quá nhiều màn hình nghiệp vụ ở bước này.
Đầu ra:
- file đã tạo/sửa
- skill UI đã dùng
- style guide rules đã áp
- nền design system đã dựng
- cách test nhanh
```

## 5.2. Trang chủ Store

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai trang chủ Store cho PowerTech.

Bắt buộc:
- đọc `.agent/ui_style_guide_for_ai_agent.md`
- đọc skill UI liên quan

Yêu cầu:
- bám theo MASTER SPEC
- hiển thị:
  - banner / hero
  - danh mục nổi bật
  - sản phẩm nổi bật
  - sản phẩm mới
  - sản phẩm khuyến mãi
  - section tin tức / chính sách tối thiểu
- dùng dữ liệu từ catalog đã có
- UI phải đúng phong cách retail-tech, không quá màu mè

Đầu ra:
- controller / service / view / viewmodel đã tạo hoặc sửa
- skill đã dùng
- style rules đã áp
- dữ liệu nào đang dùng
- cách test route trang chủ
```

## 5.3. Trang danh sách sản phẩm

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai trang danh sách sản phẩm cho Store Area.

Bắt buộc:
- đọc style guide UI
- đọc skill UI liên quan

Yêu cầu:
- product list
- filter theo category
- filter theo brand
- filter theo khoảng giá
- filter theo specification cơ bản nếu dữ liệu đã sẵn
- sorting
- pagination
- chỉ hiển thị sản phẩm active
- filter bar, product card, badge, giá phải đúng design system

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- query/filter strategy
- style rules đã áp
- cách test từng bộ lọc
```

## 5.4. Trang chi tiết sản phẩm

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai trang chi tiết sản phẩm cho Store Area.

Bắt buộc:
- đọc style guide UI
- đọc skill UI liên quan

Yêu cầu:
- hiển thị:
  - tên
  - giá
  - giảm giá
  - gallery ảnh
  - mô tả ngắn
  - mô tả chi tiết
  - thông số kỹ thuật
  - trạng thái còn hàng
  - sản phẩm liên quan cơ bản
- xử lý trường hợp product không tồn tại hoặc inactive
- UI phải rõ, mạnh, tập trung chuyển đổi

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- query detail strategy
- style rules đã áp
- cách test product detail
```

## 5.5. UserAddress + Cart + CartItem

```text
Dựa trên 5 file nền của PowerTech, hãy hoàn tất phần data model cho:
- UserAddress
- Cart
- CartItem

Yêu cầu:
- read schema first qua MCP
- so sánh với DB thật
- tạo/cập nhật entity
- cập nhật ApplicationDbContext
- cấu hình Fluent API
- migration chỉ khi cần và phải additive
- seeder nhẹ nếu cần, phải idempotent

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- schema thật đã đọc
- migration có/không
- cách test CRUD dữ liệu cơ bản
```

## 5.6. Giỏ hàng

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai module giỏ hàng.

Bắt buộc:
- đọc style guide UI
- đọc skill UI liên quan

Mục tiêu:
- add to cart
- xem cart
- cập nhật quantity
- xóa item
- tính subtotal
- chặn thao tác không hợp lệ với product inactive hoặc quantity <= 0

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- route cart
- cách test add/update/remove
```

## 5.7. Order + OrderItem + Payment

```text
Dựa trên 5 file nền của PowerTech, hãy hoàn tất phần data model cho:
- Order
- OrderItem
- Payment

Yêu cầu:
- read schema first qua MCP
- đối chiếu với DB thật
- tạo/cập nhật entity
- cập nhật DbContext
- cấu hình Fluent API
- migration additive nếu cần
- không tích hợp cổng thanh toán thật ở bước này

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- schema thật đã đọc
- mô hình quan hệ đã chốt
- migration có/không
```

## 5.8. Checkout

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai checkout cơ bản từ Cart -> Order.

Bắt buộc:
- đọc style guide UI
- đọc skill UI liên quan

Yêu cầu:
- customer phải đăng nhập
- chọn địa chỉ giao hàng
- chọn phương thức thanh toán
- tạo order
- tạo order items từ cart items
- tạo payment record nền nếu model đang có
- xóa / làm rỗng cart sau khi đặt hàng thành công
- validate dữ liệu đầu vào
- không làm thanh toán online thật

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- luồng checkout
- cách test end-to-end
```

## 5.9. Customer profile / address / order history

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai cụm Customer MVP.

Bắt buộc:
- đọc style guide UI
- đọc skill UI liên quan

Mục tiêu:
- hồ sơ cá nhân
- địa chỉ nhận hàng
- danh sách đơn hàng của tôi
- chi tiết đơn hàng
- hủy đơn hợp lệ mức cơ bản

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- route customer
- cách test profile/address/order history
```

---

# 6. Prompt cho Giai đoạn 6 — Admin core

## 6.1. Dashboard Admin

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai dashboard cơ bản cho Admin Area.

Bắt buộc:
- đọc `.agent/ui_style_guide_for_ai_agent.md`
- đọc skill UI liên quan

Hiển thị tối thiểu:
- số lượng user
- số lượng product
- số lượng order
- cảnh báo hàng sắp hết nếu dữ liệu có sẵn
- điều hướng nhanh tới quản lý user, role, category, brand, product

Không làm dashboard phân tích quá nặng.
Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- dữ liệu dashboard đang dùng
- cách test route admin dashboard
```

## 6.2. User & role management

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai module quản lý user và role cho Admin Area.

Bắt buộc:
- đọc style guide UI
- đọc skill liên quan kiến trúc + UI

Mục tiêu:
- danh sách user
- xem chi tiết user
- gán role
- gỡ role
- hỗ trợ multi-role
- bật/tắt IsActive
- bật MustChangePassword

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- luồng gán/gỡ role
- cách test với user thật
```

## 6.3. Category / Brand / Product CRUD

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai module CRUD cho:
- Category
- Brand
- Product

Bắt buộc:
- đọc style guide UI
- đọc skill UI + workflow liên quan

Yêu cầu:
- bám đúng model dữ liệu
- slug rõ ràng
- validate dữ liệu
- active / inactive
- featured cho product nếu có
- dùng ViewModel khi cần
- UI đủ rõ để demo đồ án

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- route admin CRUD
- cách test từng module
```

---

# 7. Prompt cho Giai đoạn 7 — Sales / Warehouse / Support

## 7.1. Sales xử lý đơn

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai module Sales xử lý đơn hàng.

Bắt buộc:
- đọc style guide UI
- đọc skill liên quan

Mục tiêu:
- xem đơn mới
- xem chi tiết đơn
- xác nhận đơn
- cập nhật trạng thái đơn
- ghi chú xử lý

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- route sales
- cách test workflow xử lý đơn
```

## 7.2. Warehouse tồn kho / nhập kho

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai module Warehouse cơ bản.

Bắt buộc:
- đọc style guide UI
- đọc skill liên quan

Yêu cầu:
- nếu có DB thật thì read schema first qua MCP
- triển khai tối thiểu:
  - xem tồn kho
  - hàng sắp hết
  - tạo phiếu nhập kho cơ bản
  - lịch sử nhập kho cơ bản
- migration nếu cần phải additive và an toàn

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- schema thật đã đọc
- workflow nhập kho cơ bản
- cách test
```

## 7.3. Support ticket / review

```text
Dựa trên 5 file nền của PowerTech, hãy triển khai module Support cơ bản.

Bắt buộc:
- đọc style guide UI
- đọc skill liên quan

Mục tiêu:
- danh sách ticket
- chi tiết ticket
- cập nhật trạng thái ticket
- kiểm duyệt review
- chuẩn bị chỗ cho bảo hành / đổi trả mức mở rộng

Đầu ra:
- file đã tạo/sửa
- skill đã dùng
- style rules đã áp
- route support
- cách test
```

---

# 8. Prompt cho Giai đoạn 8 — Kiểm thử, demo data, polishing

## 8.1. Tổng rà soát chức năng

```text
Dựa trên 5 file nền của PowerTech, hãy thực hiện một vòng rà soát toàn hệ thống.

Kiểm tra:
- auth / role / area
- product list / detail / filter
- cart / checkout
- customer profile / address / order history
- admin CRUD
- sales / warehouse / support cơ bản
- sự nhất quán giao diện theo style guide

Đầu ra:
- danh sách phần đã ổn
- danh sách lỗi / thiếu sót
- đề xuất thứ tự sửa
- cập nhật suggested cho PROJECT_STATUS.md
```

## 8.2. Làm đẹp dữ liệu demo

```text
Dựa trên 5 file nền của PowerTech, hãy rà soát và làm đẹp dữ liệu demo cho hệ thống.

Yêu cầu:
- category, brand, product đủ đẹp để trình bày
- tránh dữ liệu rác
- seeder phải idempotent
- nếu DB thật đã có dữ liệu tốt thì không chèn thêm bừa

Đầu ra:
- strategy dữ liệu demo
- file seeder đã sửa
- cách verify
```

## 8.3. Chuẩn bị cho báo cáo và demo

```text
Dựa trên 5 file nền của PowerTech, hãy liệt kê các màn hình đã hoàn tất và đề xuất bộ ảnh chụp màn hình / flow demo cho buổi bảo vệ đồ án.

Yêu cầu:
- bám theo danh sách màn hình trong MASTER SPEC
- nhóm màn hình theo Area
- chỉ rõ màn hình nào đã đủ trình bày
- chỉ rõ màn hình nào còn thiếu / cần placeholder hợp lý

Đầu ra:
- danh sách ảnh chụp nên chuẩn bị
- luồng demo đề xuất
- các màn hình còn thiếu
```

---

# 9. Prompt chuyên dụng cho database thật qua MCP

## 9.1. Prompt đọc schema trước khi động vào DB

```text
Trước khi thay đổi bất kỳ entity, migration hay seeder nào, hãy đọc schema thật qua MCP cho module đang làm.

Yêu cầu:
- liệt kê bảng liên quan
- liệt kê cột chính
- khóa chính / khóa ngoại
- unique index
- trạng thái dữ liệu hiện có
- so sánh với entity / migration hiện tại trong code
- chỉ sau đó mới đề xuất thay đổi

Không được:
- drop database
- truncate bảng
- xóa dữ liệu thật
- giả định database trống
```

## 9.2. Prompt migration additive an toàn

```text
Dựa trên schema thật đã đọc qua MCP và code hiện tại trong PowerTech, hãy tạo migration theo hướng additive, an toàn.

Yêu cầu:
- chỉ thêm bảng / cột / index khi cần
- tránh rename/drop/alter phá dữ liệu
- nếu có rủi ro dữ liệu, phải nói rõ và dừng ở mức đề xuất

Đầu ra:
- migration có/không
- lý do
- file bị ảnh hưởng
- câu lệnh tiếp theo cần chạy
```

## 9.3. Prompt seed idempotent

```text
Dựa trên schema và dữ liệu thật đã đọc qua MCP, hãy tạo hoặc cập nhật seeder theo hướng idempotent.

Yêu cầu:
- không tạo trùng
- kiểm tra tồn tại trước khi thêm
- nếu dữ liệu thật đã đủ dùng thì không seed thêm vô nghĩa

Đầu ra:
- seeder strategy
- file đã sửa
- cách test an toàn
```

---

# 10. Prompt chuyên dụng cho cập nhật tiến độ

## 10.1. Cập nhật PROJECT_STATUS.md

```text
Dựa trên công việc vừa hoàn tất, hãy đề xuất cập nhật PROJECT_STATUS.md.

Cần cập nhật:
- Current Phase
- Last Completed
- In Progress
- Next Recommended
- DoD checklist tương ứng
- Current Risks nếu có thay đổi
- nếu có UI, ghi rõ skill/style đã áp

Chỉ đánh dấu [x] cho việc đã thật sự hoàn tất và test được.
```

## 10.2. Cập nhật PHASE_TASK_BREAKDOWN.md

```text
Dựa trên các file đã tạo/sửa trong phiên này, hãy xác định những task nào trong PHASE_TASK_BREAKDOWN.md có thể chuyển:
- từ [ ] sang [~]
- từ [~] sang [x]

Chỉ cập nhật những task thật sự đã làm xong.
Nếu mới làm một phần thì để [~].
```

---

# 11. Prompt fallback khi yêu cầu mơ hồ

```text
Yêu cầu hiện tại chưa đủ cụ thể.

Hãy:
1. đọc 5 file nền của PowerTech
2. xác định giai đoạn hiện tại
3. kiểm tra có skill nào trong `.agent/skills` cần đọc không
4. nếu có UI thì đọc `.agent/ui_style_guide_for_ai_agent.md`
5. tự chọn đúng 1 cụm task đang dở hoặc hợp lý nhất
6. giải thích ngắn vì sao chọn cụm đó
7. triển khai đúng trong phạm vi cụm đó
8. cuối phiên báo task nào đã xong và bước tiếp theo

Không làm ngoài phạm vi.
Không nhảy giai đoạn.
Nếu liên quan DB thật thì phải read schema first qua MCP.
```
