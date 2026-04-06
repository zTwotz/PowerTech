# HANDOFF_INSTRUCTIONS_FOR_ANTIGRAVITY.md

> Copy nguyên văn phần trong khối code bên dưới vào phiên chat mới với Antigravity.

```text
Bạn đang tiếp quản dự án PowerTech — website thương mại điện tử linh kiện máy tính.

Trước khi làm bất kỳ việc gì, hãy đọc và bám chặt 5 file sau trong repo:
1. POWERTECH_MASTER_SPEC.md
2. PROJECT_STATUS.md
3. PHASE_TASK_BREAKDOWN.md
4. AGENT_BOOTSTRAP_PROMPT.md
5. PROMPT_LIBRARY_BY_PHASE.md

Sau đó đọc thêm các nguồn bắt buộc của agent:
6. các skill liên quan trong `.agent/skills/`
7. `.agent/ui_style_guide_for_ai_agent.md` nếu task có UI, layout, component, form, card, table, dashboard

Bối cảnh dự án:
- Đây là đồ án website thương mại điện tử linh kiện máy tính.
- Kiến trúc chốt: ASP.NET Core MVC + EF Core Code First + SQL Server + ASP.NET Core Identity.
- Hệ thống có 6 Area:
  - Store
  - Customer
  - Sales
  - Warehouse
  - Support
  - Admin
- Hệ thống có multi-role:
  - Admin
  - Customer
  - SalesStaff
  - WarehouseStaff
  - SupportStaff
- Admin là quyền cao nhất.
- Database thật đang có trên SQL Server: TechZoneStoreDb.
- Bạn đã có kết nối MCP tới database này.

Quy tắc bắt buộc:
- Không làm ngoài phạm vi các file spec.
- Không nhảy sang giai đoạn sau nếu giai đoạn trước chưa đủ điều kiện.
- Nếu task liên quan database thật:
  - phải read schema first qua MCP
  - không drop database
  - không truncate bảng
  - không xóa dữ liệu thật
  - migration phải additive, an toàn
  - seeder phải idempotent
- Không giả định database trống.
- Không hard-code role string rời rạc nếu đã có Constants/UserRoles.
- Không nhồi nghiệp vụ lớn vào Controller.
- Ưu tiên service, ViewModel, code sạch, dễ mở rộng.
- Nếu task có UI:
  - bắt buộc đọc `.agent/ui_style_guide_for_ai_agent.md`
  - phải tận dụng skill UI liên quan trong `.agent/skills`
  - phải bám phong cách retail-tech hiện đại
  - phải dùng tone sáng, primary đỏ, typography sans-serif hiện đại
  - phải giữ spacing, radius, card, button, input, table, badge nhất quán
  - Store thiên bán hàng, Admin/Sales/Warehouse/Support thiên dashboard/table/form
  - không dùng neon, glow, glassmorphism, gradient nặng
  - ưu tiên tính nhất quán > tính dễ dùng > tính đẹp

Việc đầu tiên bạn phải làm:
1. Đọc 5 file nền ở trên.
2. Rà các skill liên quan trong `.agent/skills/`.
3. Nếu task sắp làm có UI, đọc `.agent/ui_style_guide_for_ai_agent.md`.
4. Tóm tắt ngắn:
   - dự án là gì
   - giai đoạn hiện tại là gì
   - những gì đã hoàn tất
   - những gì đang làm dở
   - bước tiếp theo hợp lý nhất là gì
5. Xác định task đang [~] hoặc [ ] trong PHASE_TASK_BREAKDOWN.md.
6. Chọn đúng 1 cụm task gần nhau nhất để làm tiếp.
7. Nếu cụm task đó có liên quan database, hãy đọc schema thật qua MCP trước rồi mới code.

Cách làm việc trong mỗi phiên:
- Chỉ làm đúng 1 cụm task gần nhau nhất.
- Cuối phiên phải báo:
  1. đã làm gì
  2. skill nào đã dùng
  3. style guide rule nào đã áp
  4. file nào đã tạo hoặc sửa
  5. task nào đã chuyển trạng thái
  6. đã đạt Definition of Done nào chưa
  7. bước tiếp theo nên là gì
  8. PROJECT_STATUS.md cần cập nhật gì

Ưu tiên hiện tại:
- Xác định đúng giai đoạn hiện tại từ PROJECT_STATUS.md
- Nếu chưa hoàn tất Catalog core thì ưu tiên module catalog trước
- Sau đó mới tới Cart / Order / Checkout / Storefront / Admin / nội bộ
- Khi bắt đầu UI, dựng nền design system / shared layout trước rồi mới làm từng màn hình

Đầu ra mong muốn ngay bây giờ:
- Một bản tóm tắt hiện trạng dự án
- Một đề xuất cụm task tiếp theo
- Danh sách skill cần dùng cho cụm task đó
- Nếu có UI, xác nhận đã đọc style guide
- Nếu liên quan DB thật, một bản đọc schema ngắn qua MCP trước khi sửa code
```
