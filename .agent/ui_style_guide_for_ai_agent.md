# UI Style Guide cho AI Agent

> Mục tiêu: Tài liệu này dùng để ép mọi màn hình của website **thống nhất về phong cách giao diện**.  
> Agent **phải tuân thủ tuyệt đối** các quy tắc bên dưới khi sinh HTML/CSS, Razor View, React component, Tailwind class, hoặc đề xuất UI mới.

---

## 1. Bối cảnh dự án

Website là **website thương mại điện tử linh kiện máy tính**, lấy cảm hứng từ phong cách của các website retail công nghệ như GEARVN:

- hiện đại, rõ ràng, mạnh mẽ
- tập trung bán hàng
- ưu tiên khả năng đọc nhanh, so sánh nhanh, thao tác nhanh
- giao diện sáng, nhấn mạnh màu thương hiệu
- nhiều thông tin nhưng vẫn có trật tự
- cảm giác **công nghệ + chuyên nghiệp + đáng tin cậy**
- không dùng phong cách quá màu mè, quá cyber, quá glassmorphism, quá hoạt hình

Agent phải giữ đúng tinh thần đó trên **mọi Area**:
- Store
- Customer
- Admin
- Sales
- Warehouse
- Support

---

## 2. Nguyên tắc thiết kế bắt buộc

Agent phải luôn tuân theo các nguyên tắc sau:

1. **Ưu tiên tính nhất quán**
   - Không tự tạo style mới cho từng trang nếu chưa có lý do rõ ràng.
   - Mọi trang phải dùng lại cùng hệ màu, font, spacing, button, card, input, table, badge.

2. **Ưu tiên khả năng sử dụng**
   - Giao diện phải dễ đọc, dễ quét thông tin.
   - CTA phải rõ ràng.
   - Không hy sinh tính dễ dùng để lấy hiệu ứng đẹp.

3. **Ưu tiên nghiệp vụ thương mại điện tử**
   - Product card, giá, tồn kho, trạng thái đơn, bộ lọc, bảng dữ liệu phải rõ.
   - Không làm UI quá nghệ thuật khiến giảm khả năng thao tác.

4. **Thiết kế hệ thống, không thiết kế rời rạc**
   - Mỗi thành phần phải là một phần của design system chung.
   - Nếu tạo component mới, phải theo đúng style token hiện có.

5. **Desktop-first nhưng responsive đầy đủ**
   - Giao diện phải đẹp trên desktop trước.
   - Sau đó co giãn hợp lý cho tablet và mobile.
   - Không được phá layout khi responsive.

---

## 3. Tone thương hiệu

Tone giao diện phải luôn giữ:

- **Công nghệ**
- **Mạnh mẽ**
- **Sạch sẽ**
- **Chuyên nghiệp**
- **Tin cậy**
- **Tập trung chuyển đổi**

Không dùng tone:
- quá dễ thương
- quá pastel
- quá tối bí
- quá neon gaming
- quá nhiều hiệu ứng phát sáng
- quá nhiều gradient phức tạp

---

## 4. Hệ màu chuẩn

Agent phải dùng hệ màu này làm chuẩn mặc định.

## 4.1. Brand colors

```css
--color-primary: #D7262E;
--color-primary-hover: #B91F26;
--color-primary-soft: #FDEBEC;

--color-text: #111111;
--color-text-secondary: #4B5563;
--color-text-muted: #6B7280;

--color-bg: #FFFFFF;
--color-bg-soft: #F7F7F8;
--color-surface: #FFFFFF;
--color-surface-alt: #F3F4F6;

--color-border: #E5E7EB;
--color-border-strong: #D1D5DB;

--color-success: #16A34A;
--color-warning: #D97706;
--color-danger: #DC2626;
--color-info: #2563EB;
```

## 4.2. Quy tắc dùng màu

- **Primary đỏ** chỉ dùng cho:
  - nút chính
  - badge khuyến mãi
  - link quan trọng
  - highlight đang active
  - giá ưu đãi hoặc điểm nhấn thương hiệu

- Nền chính phải là:
  - trắng
  - hoặc xám rất nhạt

- Chữ chính:
  - dùng màu gần đen
  - không dùng xám nhạt cho nội dung quan trọng

- Border:
  - dùng xám nhạt
  - không dùng viền đậm trừ khi cần phân tách mạnh

- Không được lạm dụng quá 1 màu nhấn chính trên cùng một vùng nội dung.

---

## 5. Typography

## 5.1. Font

Agent phải ưu tiên font sans-serif hiện đại, dễ đọc, theo thứ tự:

```css
font-family: Inter, "Segoe UI", Roboto, Arial, sans-serif;
```

## 5.2. Cấp chữ chuẩn

- Page title: `32px`, `700`
- Section title: `24px`, `700`
- Card title / product name: `16px - 18px`, `600`
- Body text: `14px - 16px`, `400 - 500`
- Label / meta text: `12px - 13px`, `500`
- Price chính: `20px - 24px`, `700`
- Price cũ: `14px - 16px`, `500`, gạch ngang

## 5.3. Quy tắc chữ

- Tiêu đề phải đậm và rõ.
- Không dùng quá nhiều cấp chữ linh tinh.
- Không dùng chữ quá nhỏ cho thông tin quan trọng.
- Tên sản phẩm có thể dài nhưng phải được cắt dòng hợp lý.
- Giá và CTA luôn phải nổi bật hơn mô tả phụ.

---

## 6. Spacing và kích thước

Agent phải dùng spacing scale thống nhất:

```css
4px, 8px, 12px, 16px, 20px, 24px, 32px, 40px, 48px, 64px
```

Quy tắc:
- Khoảng cách giữa các section lớn: `32px - 48px`
- Padding card: `16px - 20px`
- Khoảng cách giữa label và input: `8px`
- Khoảng cách giữa các field trong form: `16px`
- Khoảng cách giữa các block trong dashboard/table/filter: `16px - 24px`

Không dùng spacing ngẫu nhiên như `7px`, `13px`, `19px` nếu không thực sự cần.

---

## 7. Bo góc, viền, đổ bóng

## 7.1. Border radius

- Card lớn: `16px`
- Card nhỏ: `12px`
- Input / Select / Button: `10px - 12px`
- Badge: `999px` nếu dạng pill

## 7.2. Border

- Border chuẩn: `1px solid var(--color-border)`

## 7.3. Shadow

Chỉ dùng shadow nhẹ:

```css
box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
```

Không dùng:
- shadow quá nặng
- glow đỏ
- nhiều lớp shadow chồng nhau

---

## 8. Layout hệ thống

## 8.1. Container

- Desktop container: `1200px - 1320px`
- Nội dung phải căn giữa
- Không kéo full width trừ banner hoặc section đặc biệt

## 8.2. Grid

- Homepage product grid: 4 cột desktop
- Collection page: 3 hoặc 4 cột tùy sidebar
- Admin dashboard: grid 3 hoặc 4 card
- Table/list page: ưu tiên bố cục rộng, rõ cột

## 8.3. Cấu trúc chung mỗi trang

Mọi trang nên tuân theo khung:

1. Header
2. Page heading / breadcrumb
3. Main content
4. Section / card / table / form
5. Footer (nếu là Store/Customer)
6. Không bắt buộc footer cho Admin/Sales/Warehouse/Support

---

## 9. Component rules

## 9.1. Button

### Primary button
- nền đỏ
- chữ trắng
- hover đỏ đậm hơn
- font-weight 600
- padding cân đối
- bo góc 10-12px

### Secondary button
- nền trắng
- border xám
- chữ đen/xám đậm
- hover nền xám nhạt

### Danger button
- nền đỏ đậm hoặc trắng viền đỏ
- chỉ dùng cho xóa / hủy / tác vụ nguy hiểm

Không được tạo thêm quá nhiều biến thể button vô nghĩa.

---

## 9.2. Input / Select / Textarea

- nền trắng
- viền xám nhạt
- cao đều nhau
- focus có outline hoặc ring nhẹ màu primary
- placeholder màu muted
- không dùng input quá bo tròn hoặc quá dẹt

---

## 9.3. Card

Card là component cốt lõi, phải thống nhất:

- nền trắng
- border xám nhạt
- bo góc 12-16px
- shadow rất nhẹ hoặc không shadow
- padding 16-20px
- header card rõ
- khoảng cách nội dung gọn gàng

### Product card
Phải có cấu trúc rõ:
- ảnh sản phẩm
- tên sản phẩm
- giá hiện tại
- giá cũ nếu có
- badge giảm giá nếu có
- thông tin ngắn: tồn kho / quà tặng / thông số ngắn
- CTA xem chi tiết hoặc thêm giỏ

---

## 9.4. Badge / Status

Dùng badge cho:
- còn hàng
- hết hàng
- chờ xác nhận
- đang giao
- hoàn thành
- đã hủy
- khuyến mãi
- nổi bật

Màu gợi ý:
- Success: xanh lá
- Warning: cam
- Danger: đỏ
- Info: xanh dương
- Promotion: đỏ hoặc cam

Badge phải nhỏ gọn, dễ đọc, không chói.

---

## 9.5. Table

Table trong Admin/Sales/Warehouse/Support phải:

- header rõ
- hàng dễ quét
- khoảng cách hợp lý
- có hover nhẹ
- có cột trạng thái rõ ràng
- action button/icon nằm cuối hàng
- responsive: với mobile thì có thể chuyển card-list

Không dùng table quá dày chữ hoặc quá nhiều border đậm.

---

## 9.6. Filter bar

Với các trang danh mục và quản trị:
- filter phải nằm trong card hoặc sidebar gọn gàng
- nhóm filter phải có tiêu đề
- checkbox/radio/select phải đồng nhất
- có nút reset filter nếu cần

---

## 10. Header và footer

## 10.1. Header Store/Customer

Header storefront phải mang tinh thần retail-tech:

- logo trái
- thanh tìm kiếm nổi bật
- tài khoản
- giỏ hàng
- hotline hoặc support link
- menu danh mục rõ

Tone:
- sạch
- rõ
- thiên mua hàng
- không quá rườm rà

## 10.2. Footer Store/Customer

Footer phải có:
- giới thiệu ngắn
- chính sách mua hàng
- chính sách đổi trả / bảo hành
- thông tin liên hệ
- hotline
- thanh toán / vận chuyển nếu có

Footer phải tạo cảm giác đáng tin cậy.

---

## 11. Quy tắc riêng cho từng Area

## 11.1. Store

Phong cách:
- bắt mắt vừa phải
- thiên bán hàng
- nhiều card sản phẩm
- ưu tiên banner, deal, danh mục, CTA

Phải có:
- màu primary nổi bật hơn area nội bộ
- product card nhất quán
- section title rõ
- filter gọn, dễ dùng

## 11.2. Customer

Phong cách:
- giống Store nhưng đơn giản hơn
- ít marketing hơn
- thiên quản lý tài khoản và đơn hàng

Phải có:
- layout rõ ràng
- form dễ dùng
- trạng thái đơn hàng rõ
- thông tin cá nhân tách khối tốt

## 11.3. Admin

Phong cách:
- chuyên nghiệp
- tối giản hơn Store
- tập trung table, form, dashboard card

Phải có:
- sidebar/menu trái rõ
- page title rõ
- data table nhất quán
- filter / search / action bar rõ ràng

Không được làm Admin giống trang marketing.

## 11.4. Sales

Phong cách:
- giống Admin
- tập trung đơn hàng và trạng thái xử lý
- tốc độ thao tác cao

Phải làm nổi:
- trạng thái đơn
- thông tin khách
- CTA xác nhận / cập nhật

## 11.5. Warehouse

Phong cách:
- giống Admin
- thiên dữ liệu tồn kho
- dễ kiểm tra số lượng và biến động

Phải rõ:
- số lượng tồn
- cảnh báo sắp hết
- nhập/xuất kho

## 11.6. Support

Phong cách:
- giống Admin
- thiên ticket, review, phản hồi khách hàng

Phải rõ:
- trạng thái ticket
- lịch sử xử lý
- nội dung khách phản hồi

---

## 12. Icon và hình ảnh

- Dùng icon nét đơn giản, hiện đại, đồng bộ
- Không dùng nhiều bộ icon trộn lẫn
- Ảnh sản phẩm phải rõ, sáng, nền sạch
- Banner không dùng quá nhiều chữ nhỏ
- Không dùng ảnh quá tối hoặc quá nhiều hiệu ứng RGB

---

## 13. Hover, active, focus, disabled

Agent phải luôn làm đủ state cho component:

### Hover
- button: đậm hơn nhẹ
- card: shadow nhẹ hơn hoặc border đậm nhẹ
- link: đổi màu primary

### Active
- tab/menu đang chọn: nổi bật bằng primary hoặc nền soft

### Focus
- input/button/link phải có focus ring hoặc outline rõ

### Disabled
- opacity giảm
- cursor not-allowed
- nhìn rõ là không bấm được

---

## 14. Responsive rules

## 14.1. Desktop
- là ưu tiên chính
- giữ layout rộng, rõ, nhiều cột

## 14.2. Tablet
- giảm số cột grid
- filter có thể thu gọn
- table có thể cuộn ngang

## 14.3. Mobile
- header đơn giản hơn
- action quan trọng giữ dễ bấm
- product grid 2 cột hoặc 1 cột
- form full width
- table chuyển card-list nếu cần

Agent không được chỉ làm desktop mà bỏ qua responsive.

---

## 15. Những gì tuyệt đối không được làm

Agent **không được**:

- tự ý đổi tone màu chính sang xanh, tím, pastel
- dùng nhiều gradient nặng
- dùng hiệu ứng glow, neon, glassmorphism tràn lan
- tạo mỗi trang một kiểu button khác nhau
- tạo mỗi trang một kiểu card khác nhau
- dùng quá nhiều cỡ chữ lộn xộn
- làm admin giống landing page
- nhồi quá nhiều animation gây rối
- dùng khoảng trắng quá ít khiến chật chội
- dùng khoảng trắng quá nhiều khiến mất nhịp thương mại điện tử

---

## 16. Luật tái sử dụng component

Khi tạo màn hình mới, agent phải:

1. Tìm component tương tự đã có
2. Ưu tiên tái sử dụng
3. Chỉ tạo mới nếu thật sự cần
4. Nếu tạo mới, phải tuân theo:
   - màu hiện có
   - spacing hiện có
   - radius hiện có
   - typography hiện có
   - state hiện có

Không được tạo component mới chỉ vì “cho đẹp hơn”.

---

## 17. Checklist bắt buộc trước khi hoàn thành một màn hình

Trước khi chốt UI, agent phải tự kiểm tra:

- Màn hình có đúng hệ màu không?
- Header/footer/sidebar có đúng style chung không?
- Button có đúng biến thể không?
- Input/table/card có đúng design system không?
- Khoảng cách có thống nhất không?
- Typography có rõ cấp bậc không?
- CTA chính có nổi bật không?
- Responsive có ổn không?
- Màn hình này có bị lệch khỏi tinh thần retail-tech không?
- Có tái sử dụng component cũ tối đa chưa?

Nếu có 1 câu trả lời là “chưa”, agent phải chỉnh lại trước khi hoàn thành.

---

## 18. Output expectation cho AI agent

Khi agent tạo bất kỳ màn hình nào, output phải:

- sạch
- thống nhất
- có thể dùng ngay
- không trình diễn style thừa
- không phá design system
- không tự sáng tạo vượt khỏi spec này

Nếu có mâu thuẫn giữa:
- **tính đẹp**
- **tính nhất quán**
- **tính dễ dùng**

thì phải ưu tiên theo thứ tự:

1. tính nhất quán  
2. tính dễ dùng  
3. tính đẹp  

---

## 19. Kết luận ngắn cho agent

Hãy coi website này là một **hệ thống bán linh kiện máy tính chuyên nghiệp**, phong cách **retail-tech hiện đại**, lấy cảm hứng từ các website công nghệ lớn như GEARVN nhưng được làm **gọn hơn, sạch hơn, thống nhất hơn**.

Mọi màn hình phải trông như cùng một sản phẩm, cùng một thương hiệu, cùng một đội thiết kế làm ra.

Agent phải luôn ưu tiên:
- đồng bộ
- rõ ràng
- chuyên nghiệp
- tập trung nghiệp vụ
- dễ mở rộng về sau
