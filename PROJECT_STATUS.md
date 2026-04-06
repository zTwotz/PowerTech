# PROJECT_STATUS.md

## Project
PowerTech — Website thương mại điện tử linh kiện máy tính

## Mandatory Context For Agent
Trước khi làm việc, agent phải đọc:
- POWERTECH_MASTER_SPEC.md
- PHASE_TASK_BREAKDOWN.md
- AGENT_BOOTSTRAP_PROMPT.md
- PROMPT_LIBRARY_BY_PHASE.md
- các skill liên quan trong `.agent/skills/`
- `.agent/ui_style_guide_for_ai_agent.md` nếu task có UI/UX, layout, component, form, card, table, dashboard

## Current Phase
- [x] Giai đoạn 1 — Phân tích
- [x] Giai đoạn 2 — Thiết kế
- [x] Giai đoạn 3 — Nền tảng kỹ thuật
- [x] Giai đoạn 4 — Catalog core
- [x] Giai đoạn 5 — Storefront & Customer MVP (Hoàn tất phần lớn logic & UI nền)
- [/] Giai đoạn 6 — Admin (Đang chuẩn bị)
- [ ] Giai đoạn 7 — Sales / Warehouse / Support
- [ ] Giai đoạn 8 — Kiểm thử & tối ưu

## Last Completed
- Khởi tạo project ASP.NET Core MVC & Identity.
- Đồng bộ hoàn chỉnh Data Model Catalog (Category, Brand, Product, Spec) với SQL Server thật qua MCP.
- Hoàn thiện Entity và mapping Fluent API cho:
  - Catalog (Category, Brand, Product, ProductImage, Spec).
  - Order & Payment (Order, OrderItem, Payment).
  - Customer Core (UserAddress, Cart, CartItem).
- Xây dựng hệ thống Navigation Properties và Check Constraints (Fluent API).
- Kiểm chứng database TechZoneStoreDb đã có dữ liệu seed Catalog chuẩn.
- Project build thành công và đồng bộ 100% với schema database SQL.

## In Progress
- Triển khai CRUD Sản phẩm & Danh mục (Phase 6.4).
- Quản lý đơn hàng nâng cao (Phase 6.6).
- Triển khai logic nghiệp vụ nâng cao (Voucher, Promotion).

## Next Recommended
1. **Dựng nền UI Storefront (Phase 5.1 & 5.2)**:
   - Cấu hình CSS Variables, Typography (Inter), Colors (Primary Red).
   - Tạo Header linh hoạt (search, cart icon, user icon).
   - Tạo Footer chuyên nghiệp.
2. **Triển khai Trang Danh sách Sản phẩm (Phase 5.3)**:
   - Phân trang, lọc theo Brand/Category/Price.
   - Hiển thị Card sản phẩm "wow" bám sát style guide.
3. **Triển khai Giỏ hàng (Phase 5.5)**:
   - Logic thêm/sửa/xóa giỏ hàng đồng bộ Database.
4. **Triển khai Thanh toán (Phase 5.6)**:
   - Quy trình Checkout 3 bước.

## Definition of Done Check

### Giai đoạn 4 — Catalog core (DONE)
- [x] Đã read schema thật qua MCP
- [x] Có entity catalog hoàn chỉnh
- [x] Có DbContext catalog
- [x] Có Fluent API catalog
- [x] Có migration additive an toàn hoặc xác nhận chưa cần (Hiện tại DB đã khớp code snapshot)
- [x] Có seeder demo idempotent (Đã có dữ liệu thật trong TechZoneStoreDb)

### Giai đoạn 6 — Admin Core & Order Management (DONE: 100%)
- [x] Khung UI Admin (Layout, Sidebar, Topbar, Responsive) - DONE
- [x] Dashboard thống kê (Real-time data từ DB) - DONE
- [x] Quản trị Sản phẩm (CRUD, Image Upload) - DONE
- [x] Quản trị Danh mục & Thương hiệu (Danh mục CRUD DONE)
- [x] Quản trị Đơn hàng (Cập nhật trạng thái, In hóa đơn) - DONE
- [x] Quản trị Người dùng & Phân quyền (Admin, Sales, Warehouse...) - DONE

### Giai đoạn 5 — Storefront & Customer MVP (Hoàn tất: 100%)
- [x] Trang chủ (Hoàn tất logic & UI - Dữ liệu động)
- [x] Danh sách sản phẩm (Hoàn tất logic - Bộ lọc & Phân trang)
- [x] Chi tiết sản phẩm (Hoàn tất Gallery, Spec Table, Buy actions)
- [x] Tìm kiếm / lọc (DONE - Search logic integrated)
- [x] Menu danh mục động (DONE - ViewComponent)
- [x] Giỏ hàng (Hoàn tất logic & UI chuyên nghiệp)
- [x] Thanh toán (Hoàn tất 3 bước - Address, Payment, Confirmation)
- [x] Hồ sơ khách hàng & Địa chỉ (DONE)
- [x] Quản lý đơn hàng & Hủy đơn (DONE)
- [x] Giao diện Đăng nhập / Đăng ký (DONE - Retail-tech style)
- [x] Lịch sử đơn hàng (DONE)
- [x] Chi tiết đơn hàng (DONE)
- [x] UI bám style guide retail-tech (Layout & Customer Area DONE)

## Technical Notes
- Database hiện tại: TechZoneStoreDb (SQL Server).
- Framework: ASP.NET Core 9.0 (MVC).
- Kỹ thuật: EF Core Code First (Synced with existing DB).
- UI Style: Retail-tech (GEARVN inspired), tone sáng, primary #D7262E.
- Skills đã dùng: `database-domain-rules`, `agent-execution-rules`, `ui-style-system`.

## Update Rule
Sau mỗi phiên làm việc, AI agent phải cập nhật file này để phản ánh đúng tiến độ thực tế và lộ trình tiếp theo.
