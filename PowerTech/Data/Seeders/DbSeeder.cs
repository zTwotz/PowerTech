using Microsoft.AspNetCore.Identity;
using PowerTech.Constants;
using PowerTech.Models.Entities;

namespace PowerTech.Data.Seeders
{
    public static class DbSeeder
    {
        public static async Task SeedRolesAndAdminAsync(IServiceProvider serviceProvider)
        {
            var roleManager = serviceProvider.GetRequiredService<RoleManager<IdentityRole>>();
            var userManager = serviceProvider.GetRequiredService<UserManager<ApplicationUser>>();

            string[] roleNames =
            {
                UserRoles.Admin,
                UserRoles.Customer,
                UserRoles.SalesStaff,
                UserRoles.WarehouseStaff,
                UserRoles.SupportStaff,
                UserRoles.Shipper
            };

            foreach (var roleName in roleNames)
            {
                if (!await roleManager.RoleExistsAsync(roleName))
                {
                    var roleResult = await roleManager.CreateAsync(new IdentityRole(roleName));
                    if (!roleResult.Succeeded)
                    {
                        throw new Exception($"Không tạo được role {roleName}: " +
                            string.Join("; ", roleResult.Errors.Select(e => e.Description)));
                    }
                }
            }

            var adminEmail = "admin@powertech.com";
            var adminPassword = "Admin@123";

            var adminUser = await userManager.FindByEmailAsync(adminEmail);

            if (adminUser == null)
            {
                adminUser = new ApplicationUser
                {
                    UserName = adminEmail,
                    Email = adminEmail,
                    FullName = "System Administrator",
                    EmailConfirmed = true,
                    IsActive = true,
                    MustChangePassword = false,
                    CreatedAt = DateTime.UtcNow
                };

                var userResult = await userManager.CreateAsync(adminUser, adminPassword);
                if (!userResult.Succeeded)
                {
                    throw new Exception("Không tạo được tài khoản admin: " +
                        string.Join("; ", userResult.Errors.Select(e => e.Description)));
                }
            }

            if (!await userManager.IsInRoleAsync(adminUser, UserRoles.Admin))
            {
                var addRoleResult = await userManager.AddToRoleAsync(adminUser, UserRoles.Admin);
                if (!addRoleResult.Succeeded)
                {
                    throw new Exception("Không gán được role Admin cho tài khoản admin: " +
                        string.Join("; ", addRoleResult.Errors.Select(e => e.Description)));
                }
            }
        }
    }
}