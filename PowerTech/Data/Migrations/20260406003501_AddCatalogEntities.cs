using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PowerTech.Migrations
{
    /// <inheritdoc />
    public partial class AddCatalogEntities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Safety Check: Only create tables if they don't exist yet
            migrationBuilder.Sql(@"
                IF OBJECT_ID(N'[Brands]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [Brands] (
                        [Id] int NOT NULL IDENTITY,
                        [Name] nvarchar(100) NOT NULL,
                        [Slug] nvarchar(100) NOT NULL,
                        [Description] nvarchar(max) NULL,
                        [Country] nvarchar(100) NULL,
                        [LogoUrl] nvarchar(max) NULL,
                        [IsActive] bit NOT NULL,
                        [CreatedAt] datetime2 NOT NULL,
                        [UpdatedAt] datetime2 NULL,
                        CONSTRAINT [PK_Brands] PRIMARY KEY ([Id])
                    );
                    CREATE UNIQUE INDEX [IX_Brands_Slug] ON [Brands] ([Slug]);
                END
                
                IF OBJECT_ID(N'[Categories]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [Categories] (
                        [Id] int NOT NULL IDENTITY,
                        [ParentCategoryId] int NULL,
                        [Name] nvarchar(100) NOT NULL,
                        [Slug] nvarchar(100) NOT NULL,
                        [Description] nvarchar(max) NULL,
                        [DisplayOrder] int NOT NULL,
                        [IsActive] bit NOT NULL,
                        [CreatedAt] datetime2 NOT NULL,
                        [UpdatedAt] datetime2 NULL,
                        CONSTRAINT [PK_Categories] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_Categories_Categories_ParentCategoryId] FOREIGN KEY ([ParentCategoryId]) REFERENCES [Categories] ([Id]) ON DELETE NO ACTION
                    );
                    CREATE INDEX [IX_Categories_ParentCategoryId] ON [Categories] ([ParentCategoryId]);
                    CREATE UNIQUE INDEX [IX_Categories_Slug] ON [Categories] ([Slug]);
                END

                IF OBJECT_ID(N'[Products]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [Products] (
                        [Id] int NOT NULL IDENTITY,
                        [SKU] nvarchar(50) NOT NULL,
                        [Name] nvarchar(255) NOT NULL,
                        [Slug] nvarchar(255) NOT NULL,
                        [CategoryId] int NOT NULL,
                        [BrandId] int NOT NULL,
                        [Price] decimal(18,2) NOT NULL,
                        [DiscountPrice] decimal(18,2) NULL,
                        [StockQuantity] int NOT NULL,
                        [SoldQuantity] int NOT NULL,
                        [ShortDescription] nvarchar(max) NULL,
                        [Description] nvarchar(max) NULL,
                        [ThumbnailUrl] nvarchar(max) NULL,
                        [WarrantyMonths] int NOT NULL,
                        [IsFeatured] bit NOT NULL,
                        [IsActive] bit NOT NULL,
                        [CreatedAt] datetime2 NOT NULL,
                        [UpdatedAt] datetime2 NULL,
                        CONSTRAINT [PK_Products] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_Products_Brands_BrandId] FOREIGN KEY ([BrandId]) REFERENCES [Brands] ([Id]) ON DELETE NO ACTION,
                        CONSTRAINT [FK_Products_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([Id]) ON DELETE NO ACTION
                    );
                    CREATE INDEX [IX_Products_BrandId] ON [Products] ([BrandId]);
                    CREATE INDEX [IX_Products_CategoryId] ON [Products] ([CategoryId]);
                    CREATE UNIQUE INDEX [IX_Products_SKU] ON [Products] ([SKU]);
                    CREATE UNIQUE INDEX [IX_Products_Slug] ON [Products] ([Slug]);
                END

                IF OBJECT_ID(N'[SpecificationDefinitions]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [SpecificationDefinitions] (
                        [Id] int NOT NULL IDENTITY,
                        [CategoryId] int NOT NULL,
                        [SpecName] nvarchar(100) NOT NULL,
                        [DisplayName] nvarchar(100) NULL,
                        [DataType] nvarchar(20) NOT NULL,
                        [Unit] nvarchar(50) NULL,
                        [GroupName] nvarchar(100) NULL,
                        [SortOrder] int NOT NULL,
                        [IsFilterable] bit NOT NULL,
                        [IsRequired] bit NOT NULL,
                        [IsActive] bit NOT NULL,
                        [CreatedAt] datetime2 NOT NULL,
                        CONSTRAINT [PK_SpecificationDefinitions] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_SpecificationDefinitions_Categories_CategoryId] FOREIGN KEY ([CategoryId]) REFERENCES [Categories] ([Id]) ON DELETE CASCADE
                    );
                    CREATE INDEX [IX_SpecificationDefinitions_CategoryId] ON [SpecificationDefinitions] ([CategoryId]);
                END

                IF OBJECT_ID(N'[ProductImages]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [ProductImages] (
                        [Id] int NOT NULL IDENTITY,
                        [ProductId] int NOT NULL,
                        [ImageUrl] nvarchar(max) NOT NULL,
                        [AltText] nvarchar(max) NULL,
                        [IsPrimary] bit NOT NULL,
                        [SortOrder] int NOT NULL,
                        [CreatedAt] datetime2 NOT NULL,
                        CONSTRAINT [PK_ProductImages] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_ProductImages_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE CASCADE
                    );
                    CREATE INDEX [IX_ProductImages_ProductId] ON [ProductImages] ([ProductId]);
                END

                IF OBJECT_ID(N'[ProductSpecifications]', N'U') IS NULL
                BEGIN
                    CREATE TABLE [ProductSpecifications] (
                        [Id] int NOT NULL IDENTITY,
                        [ProductId] int NOT NULL,
                        [SpecDefinitionId] int NOT NULL,
                        [ValueText] nvarchar(max) NULL,
                        [ValueNumber] decimal(18,4) NULL,
                        [ValueBoolean] bit NULL,
                        [DisplayValue] nvarchar(max) NULL,
                        [CreatedAt] datetime2 NOT NULL,
                        CONSTRAINT [PK_ProductSpecifications] PRIMARY KEY ([Id]),
                        CONSTRAINT [FK_ProductSpecifications_Products_ProductId] FOREIGN KEY ([ProductId]) REFERENCES [Products] ([Id]) ON DELETE CASCADE,
                        CONSTRAINT [FK_ProductSpecifications_SpecificationDefinitions_SpecDefinitionId] FOREIGN KEY ([SpecDefinitionId]) REFERENCES [SpecificationDefinitions] ([Id]) ON DELETE CASCADE
                    );
                    CREATE UNIQUE INDEX [IX_ProductSpecifications_ProductId_SpecDefinitionId] ON [ProductSpecifications] ([ProductId], [SpecDefinitionId]);
                    CREATE INDEX [IX_ProductSpecifications_SpecDefinitionId] ON [ProductSpecifications] ([SpecDefinitionId]);
                END
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ProductImages");

            migrationBuilder.DropTable(
                name: "ProductSpecifications");

            migrationBuilder.DropTable(
                name: "Products");

            migrationBuilder.DropTable(
                name: "SpecificationDefinitions");

            migrationBuilder.DropTable(
                name: "Brands");

            migrationBuilder.DropTable(
                name: "Categories");
        }
    }
}
