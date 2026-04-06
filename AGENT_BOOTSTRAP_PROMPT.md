# AGENT_BOOTSTRAP_PROMPT.md

## Mục đích
File này dùng để khởi động Antigravity hoặc AI agent ở đầu mỗi phiên làm việc với dự án PowerTech.

Agent phải đọc file này cùng với:
- `POWERTECH_MASTER_SPEC.md`
- `PROJECT_STATUS.md`
- `PHASE_TASK_BREAKDOWN.md`
- `PROMPT_LIBRARY_BY_PHASE.md`

và phải đọc thêm:
- các skill liên quan trong `.agent/skills/`
- `.agent/ui_style_guide_for_ai_agent.md` nếu task có UI/UX

---

## Prompt khởi động chuẩn

```text
Bạn đang làm việc trên dự án PowerTech.

Trước khi làm bất kỳ việc gì, hãy đọc:
1. POWERTECH_MASTER_SPEC.md
2. PROJECT_STATUS.md
3. PHASE_TASK_BREAKDOWN.md
4. PROMPT_LIBRARY_BY_PHASE.md

Sau đó rà các nguồn phụ trợ bắt buộc:
5. các skill liên quan trong `.agent/skills/`
6. `.agent/ui_style_guide_for_ai_agent.md` nếu task có UI, layout, component, form, card, table, dashboard

Sau đó tự trả lời ngắn gọn 10 mục sau:
1. Dự án này là gì?
2. Giai đoạn hiện tại là gì?
3. Những gì đã hoàn tất?
4. Những gì đang làm dở?
5. Việc tiếp theo hợp lý nhất là gì?
6. Task sắp làm thuộc Area nào, Role nào, module nào?
7. Nếu task liên quan database SQL Server thật, bạn đã read schema first qua MCP chưa?
8. Task này cần đạt Definition of Done nào trong MASTER SPEC?
9. Có skill nào trong `.agent/skills/` cần áp dụng trực tiếp không?
10. Nếu có UI, bạn đã đọc `.agent/ui_style_guide_for_ai_agent.md` và sẽ bám tone retail-tech, màu primary đỏ, typography, spacing, component rules chưa?

Quy tắc bắt buộc:
- Không làm ngoài phạm vi trong POWERTECH_MASTER_SPEC.md
- Không nhảy sang giai đoạn sau khi giai đoạn trước chưa đạt DoD
- Nếu liên quan database:
  - phải read schema first qua MCP
  - không drop database
  - không truncate bảng
  - không xóa dữ liệu thật
  - migration phải additive, an toàn
  - seeder phải idempotent
- Không hard-code role string rời rạc nếu đã có Constants/UserRoles
- Không viết nghiệp vụ lớn dồn trong Controller
- Ưu tiên service, ViewModel, code sạch, dễ mở rộng
- Nếu làm UI:
  - phải tái sử dụng component tối đa
  - phải bám style guide
  - không được tự đổi tone màu chính
  - không làm Admin giống landing page marketing
  - ưu tiên tính nhất quán > tính dễ dùng > tính đẹp
- Cuối mỗi lượt phải báo:
  1. đã làm gì
  2. đã sửa file nào
  3. còn thiếu gì
  4. có đạt Definition of Done chưa
  5. bước tiếp theo nên là gì
  6. có cần cập nhật PROJECT_STATUS.md không
  7. đã dùng skill nào / style rule nào

Nếu task được giao quá mơ hồ, hãy:
- đối chiếu MASTER SPEC
- đối chiếu PHASE_TASK_BREAKDOWN
- chọn phương án phù hợp nhất với giai đoạn hiện tại
- tránh làm lan sang module chưa tới lượt
```

---

## Mẫu tác phong làm việc theo giai đoạn

### Khi đang ở giai đoạn nền tảng kỹ thuật
Ưu tiên:
- Identity
- Role
- Authorization
- Area route
- DbContext
- Migration an toàn

### Khi đang ở giai đoạn Catalog core
Ưu tiên:
- entity
- DbContext
- Fluent API
- schema sync an toàn
- seeder demo

### Khi đang ở giai đoạn Storefront MVP
Ưu tiên:
- Home
- Product List
- Product Detail
- Search / Filter
- Cart
- Checkout
- Customer Profile
- Address
- Order History
- phải đọc style guide UI trước

### Khi đang ở giai đoạn Admin
Ưu tiên:
- user / role
- category / brand / product
- specification
- dashboard cơ bản
- table/form/dashboard phải bám style guide

### Khi đang ở giai đoạn nội bộ
Ưu tiên:
- Sales xử lý đơn
- Warehouse tồn kho / nhập kho
- Support ticket / review
- UI nội bộ phải nhất quán với design system

---

## Mẫu tự đánh giá trước khi code

Agent phải tự kiểm tra:

### 1. Scope check
- Task này có nằm trong MASTER SPEC không?
- Có đúng giai đoạn hiện tại không?

### 2. Dependency check
- Cần entity nào?
- Cần migration nào?
- Cần route / role nào?
- Cần service nào?
- Cần ViewModel nào?
- Cần skill nào?

### 3. Risk check
- Có động tới database thật không?
- Có rủi ro auth không?
- Có rủi ro mất dữ liệu không?
- Có khả năng tạo dữ liệu trùng không?
- Nếu làm UI, có nguy cơ lệch style guide không?

### 4. Test check
- Làm xong có test được ngay không?
- Route nào cần mở thử?
- Role nào cần đăng nhập thử?
- Có cần dữ liệu seed bổ sung không?

---

## Mẫu output cuối mỗi phiên

```text
Kết quả phiên làm việc:
- Đã làm:
- Skill đã dùng:
- UI style rule đã áp:
- File đã tạo/sửa:
- Database / migration:
- Rủi ro còn lại:
- DoD đạt được:
- Chưa đạt:
- Bước tiếp theo đề xuất:
- PROJECT_STATUS.md cần cập nhật:
```

---

## Quy định cập nhật trạng thái
Nếu agent hoàn thành một mốc đáng kể, phải đề xuất cập nhật:
- Current Phase
- Last Completed
- In Progress
- Next Recommended
- DoD checklist tương ứng

Không để PROJECT_STATUS.md bị lỗi thời sau nhiều phiên làm việc.
