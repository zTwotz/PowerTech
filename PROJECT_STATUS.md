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

- [x] Giai đoạn 8 — Kiểm thử & tối ưu (Hoàn tất)
- [/] Giai đoạn 9 — Bàn giao & Tài liệu (Đang tiến hành)

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
- Giai đoạn 9: Bàn giao & Tài liệu (Final Handover).
- Tổng hợp tài liệu hướng dẫn sử dụng (User Manual).
- Chuẩn bị tài liệu kỹ thuật (Technical Documentation).
- Chụp ảnh minh họa các tính năng (Screenshots).

## Next Recommended
1. **Technical Handover**: Tạo file README chi tiết hướng dẫn chạy project và DB.
2. **User Manual**: Viết tài liệu hướng dẫn cho Admin và Khách hàng.
3. **Database Final Backup**: Đảm bảo script SQL/Data seed đã sẵn sàng.

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

### Giai đoạn 7 — Sales / Warehouse / Support (Trong tiến trình)
- [x] SA-04: Tạo đơn tại quầy (POS) - **DONE**
- [x] SA-05: Thống kê hiệu suất Dashboard Sales - **DONE**
- [x] Xử lý đơn hàng (Xác nhận, Cập nhật trạng thái) - **DONE**
- [x] Quản trị kho cơ bản (Tồn kho, Cảnh báo sắp hết) - **DONE**
- [x] Quản lý phiếu nhập kho & Lịch sử (StockTransaction Audit) - **DONE**
- [x] Quản lý Ticket hỗ trợ & Duyệt Review - **DONE**

## Technical Notes
- Database hiện tại: TechZoneStoreDb (SQL Server).
- Framework: ASP.NET Core 9.0 (MVC).
- Kỹ thuật: EF Core Code First (Synced with existing DB).
- UI Style: Retail-tech (GEARVN inspired), tone sáng, primary #D7262E.
- **Discovery**: Phát hiện `Data/DbFixer.cs` dùng để đồng bộ các cột thiếu trong DB mà Migration chưa có (như `InternalNote`).
- **Update**: Hệ thống đã có tính năng POS cho nhân viên bán hàng.

## Update Rule
Sau mỗi phiên làm việc, AI agent phải cập nhật file này để phản ánh đúng tiến độ thực tế và lộ trình tiếp theo.
