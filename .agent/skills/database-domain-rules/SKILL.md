---
name: database-domain-rules
description: Use when defining entities, EF Core models, relationships, migrations, or domain data structures for the computer-parts ecommerce system.
---

# Database and Domain Rules Skill

## When to use this skill
Use this skill when the task involves:
- entity design
- EF Core models
- relationships
- migrations
- schema rules
- catalog structure
- order and stock data
- user-role relations

## Domain model priorities
The database must support:
- category and product management
- brand management
- dynamic technical specifications by category
- authentication and multi-role authorization
- cart, order, payment
- warehouse and stock changes
- reviews and support tickets

## Required core entities
The default core model includes:
- Category
- Brand
- Product
- ProductImage
- SpecificationDefinition
- ProductSpecification
- ApplicationUser
- Role / UserRole via Identity
- UserAddress
- Cart
- CartItem
- Order
- OrderItem
- Payment
- Review
- Supplier
- PurchaseReceipt
- PurchaseReceiptItem
- StockTransaction
- SupportTicket

## Dynamic specification rule
Do not create separate schema families like:
- ProductsLaptop
- ProductsMonitor
- ProductsMouse

Instead use:
- `Product` for shared product data
- `SpecificationDefinition` for category-specific spec definitions
- `ProductSpecification` for actual values per product

This is a hard rule unless the user explicitly requests a redesign.

## Identity and roles
The user system must support:
- self-registration -> default Customer role
- admin-created accounts
- one user with multiple roles
- highest privilege Admin
- first-login password change if that extension is enabled

## Relationship guidance
Typical expected relations:
- Category 1-n Product
- Brand 1-n Product
- Product 1-n ProductImage
- Category 1-n SpecificationDefinition
- Product 1-n ProductSpecification
- User 1-n UserAddress
- User 1-n Orders
- Order 1-n OrderItem
- Product 1-n Review
- Supplier 1-n PurchaseReceipt
- PurchaseReceipt 1-n PurchaseReceiptItem
- Product 1-n StockTransaction
- User 1-n SupportTicket

## Data integrity rules
The agent must preserve:
- referential integrity
- non-negative stock rules where appropriate
- valid order totals derived from items
- valid product-category-brand references
- review linkage to product and customer
- stock history traceability

## Migration rules
When modifying schema:
1. explain why the change is needed
2. preserve existing domain assumptions
3. avoid breaking core workflows
4. update related services/viewmodels accordingly

## Naming rules
Use domain-focused names.
Avoid vague names like:
- Info1
- TypeX
- ItemData

Prefer:
- StockTransactionType
- IsFilterable
- DisplayOrder
- CreatedByUserId
- CurrentStockQuantity

## Do not
- flatten all specs into Product columns
- remove stock history
- remove role relationships
- mix internal operational data into unrelated entities carelessly

## Output expectations
When this skill is active, outputs should:
- use a scalable schema
- preserve the dynamic spec model
- remain aligned with EF Core Code First best practices
