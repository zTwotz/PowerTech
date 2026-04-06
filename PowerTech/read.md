3. Nhóm lệnh Entity Framework Core (Database)
Đối với các dự án web có sử dụng SQL Server hoặc database khác, bạn cần cài đặt dotnet-ef tool trước (dotnet tool install --global dotnet-ef).

dotnet ef migrations add <NAME>: Tạo một file migration mới dựa trên những thay đổi trong Code First.

dotnet ef database update: Áp dụng các migration vào database thật.

dotnet ef dbcontext info: Kiểm tra thông tin về DbContext và database đang kết nối.

dotnet ef migrations remove: Xóa bản migration cuối cùng (nếu chưa update database).




dotnet restore
dotnet build
dotnet run
dotnet watch run
dotnet clean

🔑 Thông tin Đăng nhập Admin (Mặc định):
Tài khoản: admin@powertech.com
Mật khẩu: Admin@123




Nếu máy bạn chưa có tree thì:

brew install tree

Sau đó có mấy cách hay dùng:

1. Xem toàn bộ cây thư mục

tree

2. Chỉ lấy tên thư mục

tree -d

3. Xuất cây thư mục ra file txt

tree > caythumuc.txt

4. Bỏ qua các thư mục rác như bin, obj, node_modules, .git

tree -I "bin|obj|node_modules|.git"

5. Vừa gọn vừa thực tế cho project code

tree -a -I "bin|obj|node_modules|.git|.vs"

Nếu bạn đang dùng macOS và muốn copy nhanh để gửi cho AI hoặc dán báo cáo:

tree -a -I "bin|obj|node_modules|.git|.vs" > structure.txt

rồi mở file structure.txt để copy.

Nếu không muốn cài tree, có thể dùng lệnh có sẵn:

find . -print

nhưng nó xấu và khó đọc hơn tree.

Mẫu mình khuyên dùng nhất cho project ASP.NET / Flutter / web:

tree -a -I "bin|obj|node_modules|.git|.vs|build|dist"