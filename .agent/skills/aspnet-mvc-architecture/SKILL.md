---
name: aspnet-mvc-architecture
description: Use when structuring ASP.NET Core MVC code, Areas, Controllers, Views, ViewModels, services, and feature organization for this project.
---

# ASP.NET Core MVC Architecture Skill

## When to use this skill
Use this skill when the task involves:
- project structure
- area structure
- controller planning
- views and viewmodels
- services
- dependency boundaries
- routing and authorization

## Required architecture style
The project uses:
- ASP.NET Core MVC
- Areas
- EF Core Code First
- ASP.NET Core Identity
- SQL Server

## Area structure
Use these areas:
- Store
- Customer
- Sales
- Warehouse
- Support
- Admin

Do not collapse them into a single flat MVC folder structure unless explicitly requested.

## Structural rules
Prefer this separation:

- `Areas/<AreaName>/Controllers`
- `Areas/<AreaName>/Views`
- `Areas/<AreaName>/ViewModels`
- `Services/`
- `Data/`
- `Models/`
- `Repositories/` only if the project explicitly uses repository abstraction
- `Mappings/` or feature mapping helpers if needed

## Controller rules
Controllers should:
- stay thin
- delegate business rules to services
- handle model binding, authorization, and response shaping
- avoid embedding long business workflows directly

## ViewModel rules
Use ViewModels whenever:
- the page needs combined data from multiple entities
- the page contains UI-only fields
- the page has filter/search/sort state
- the page should not expose the domain entity directly

Do not overbind EF entities directly into forms when a ViewModel is more appropriate.

## Service rules
Create services for:
- cart logic
- checkout/order creation
- stock changes
- role management
- product specification handling
- ticket/review workflows
- content management if needed

Services should:
- own business workflows
- validate cross-entity operations
- coordinate transactions when necessary

## Authorization rules
- Guest: public Store only
- Customer: Store + Customer
- Sales Staff: Sales
- Warehouse Staff: Warehouse
- Support Staff: Support
- Admin: Admin and permitted internal operations

Use role-based access control and preserve multi-role support.

## Routing rules
Prefer clear routes by area and feature.
Examples:
- `/Store/Product/Detail/{slug}`
- `/Customer/Orders`
- `/Admin/Products`
- `/Sales/Orders`
- `/Warehouse/Inventory`
- `/Support/Tickets`

## View rules
Views must:
- follow the shared design system
- use layouts appropriate to area
- avoid duplicated markup when partials/components can help
- preserve consistent table/form/card structures

## Dependency rules
- UI layer should not own business rules
- Services should not depend on views
- Data access should stay below business logic
- Domain models should not become tightly coupled to view concerns

## Recommended feature sequence
When implementing a feature:
1. confirm area and role
2. define data model impact
3. define service workflow
4. define ViewModel(s)
5. define controller actions
6. create views
7. secure routes
8. test end-to-end behavior

## Do not
- place all logic inside controllers
- merge all areas into one admin dashboard
- skip ViewModels on complex screens
- hardcode role checks in scattered ad-hoc ways if policy/service abstraction is more maintainable

## Output expectations
Outputs should provide:
- area-aware structure
- thin controllers
- clear ViewModel usage
- reusable service boundaries
