---
name: navigation-screen-priority
description: Use when deciding which screens to build first, how screens connect, and how navigation should flow across the ecommerce system.
---

# Navigation and Screen Priority Skill

## When to use this skill
Use this skill when the task involves:
- screen order
- sitemap logic
- user flow
- page dependencies
- MVP prioritization
- navigation design

## Core navigation principle
Navigation must reflect real business flows, not arbitrary menu order.

The main public flow is:
**Homepage -> Product Listing -> Product Detail -> Cart -> Login/Register if needed -> Checkout -> My Orders -> Order Detail -> Review**

The main admin/internal flow is:
**Admin Login -> User/Role -> Catalog -> Orders -> Sales processing -> Warehouse operations -> Support moderation/tickets**

## MVP-first screen priority
If time is limited, prioritize these screens first:

### Highest priority group
1. Login
2. Register
3. Forgot/change password
4. User/role management
5. Category management
6. Brand management
7. Specification definition management
8. Product management
9. Product create/edit
10. Homepage
11. Product listing
12. Product detail
13. Cart
14. Profile
15. Address book
16. Checkout
17. My orders
18. Order detail
19. Admin order management

These screens form the minimum realistic end-to-end business scope.

## Second priority group
Build next:
- review submission
- review moderation/admin review management
- policy/news pages
- content management
- admin dashboard
- sales order list
- sales order processing
- inventory
- receiving
- issue by order
- support tickets
- ticket detail

## Third priority group
Build last if time remains:
- counter order creation
- sales analytics
- low-stock page
- warehouse history page
- warranty/returns support

## Navigation rules by area

### Store
Expected entry points:
- homepage
- category menu
- search
- promotions
- product cards

Expected transitions:
- homepage -> listing
- listing -> detail
- detail -> cart or checkout
- header cart -> cart
- auth entry when required

### Customer
Expected transitions:
- account menu -> profile
- profile -> addresses / password / orders
- orders -> order detail
- order detail -> review

### Admin
Expected transitions:
- admin dashboard -> user/role / catalog / orders / content / reviews
- catalog sub-flow -> category / brand / specs / products / product form

### Sales
Expected transitions:
- order queue -> process order
- process order -> triggers warehouse issue flow

### Warehouse
Expected transitions:
- inventory -> receiving / low-stock / receipt history
- issue-by-order -> back to inventory/order trace

### Support
Expected transitions:
- ticket list -> ticket detail
- moderation -> product/review context
- optional warranty flow if enabled

## Screen specification checklist
For every screen, define:
1. entry points
2. actor/role
3. destination pages
4. required data
5. required permissions
6. success redirect
7. failure/empty state

## Do not
- invent navigation unrelated to the domain
- force users through unnecessary pages
- promote optional screens above core transaction screens

## Output expectations
Outputs should clearly state:
- which screens come first
- how each screen links to the next
- whether a screen is MVP, secondary, or optional
