---
name: project-context
description: Use when the task needs project context, roles, areas, scope, or the overall product vision for the computer-parts ecommerce website.
---

# Project Context Skill

## When to use this skill
Use this skill when the task requires understanding the project's scope, actors, areas, priorities, or product identity.

Typical triggers:
- The agent must decide which area a feature belongs to.
- The agent must infer who uses a screen or workflow.
- The agent must preserve the same business scope across code, UI, and documentation.
- The task mentions Store, Customer, Sales, Warehouse, Support, or Admin.

## Project definition
This project is a **website thương mại điện tử linh kiện máy tính** built around:
- public storefront browsing
- customer account and ordering
- internal business operations
- multi-role authorization
- structured catalog with dynamic specifications

## Core areas
The system is divided into 6 areas:
1. **Store**: public storefront for browsing and buying.
2. **Customer**: account, addresses, orders, profile, password, reviews.
3. **Sales**: new orders, order confirmation, order status processing, in-store order creation.
4. **Warehouse**: stock, receiving, issue by order, low-stock monitoring, receipt history.
5. **Support**: tickets, review moderation, optional warranty/return support.
6. **Admin**: users/roles, catalog, specs, products, orders, content, reviews, dashboard.

## Core actors
The system supports 6 user groups:
- **Guest**
- **Customer**
- **Sales Staff**
- **Warehouse Staff**
- **Support Staff**
- **Admin**

## Authority model
- One user may have **multiple roles**.
- **Admin** is the highest role.
- Admin may enter internal business areas when permitted by system rules.
- Self-registered users default to **Customer**.
- Admin may create accounts and assign one or more roles.

## Product philosophy
This website is not a generic CMS and not a minimalist portfolio.
It is a **retail-tech ecommerce system** with these priorities:
1. fast product browsing
2. technical filtering
3. strong product detail pages
4. order lifecycle visibility
5. clear internal operations
6. scalable catalog structure

## Data philosophy
The catalog must support multiple hardware categories with different technical specifications.
Do not design one hard-coded product table per category.
Instead, preserve this model:
- Category
- Brand
- Product
- ProductImage
- SpecificationDefinition
- ProductSpecification

## Agent instructions
When solving any task:
1. First identify the affected **area**.
2. Identify the **actor(s)** and authorization rules.
3. Identify whether the task belongs to:
   - storefront
   - customer self-service
   - admin management
   - sales operations
   - warehouse operations
   - support operations
4. Preserve consistency with the project scope.
5. If the request conflicts with the established system model, prefer the existing system model unless explicitly asked to change it.

## Constraints
Do not:
- collapse all roles into one admin-only panel
- remove multi-role support
- invent unrelated project domains
- redesign the project into a social network, blog-only site, or generic ERP

## Output expectations
When this skill is active, outputs should:
- name the correct area
- reflect the correct actor
- preserve the project's ecommerce nature
- stay consistent with the 6-area system
