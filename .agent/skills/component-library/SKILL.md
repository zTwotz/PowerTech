---
name: component-library
description: Use when building or reviewing reusable UI components such as headers, footers, product cards, buttons, forms, tables, badges, and filters.
---

# Component Library Skill

## When to use this skill
Use this skill when the task involves reusable UI building blocks.

Typical triggers:
- create a new component
- redesign an existing component
- implement a page that should reuse existing patterns
- review consistency across cards, buttons, forms, or tables

## Design-system-first rule
Always reuse before inventing.
When a new screen is requested:
1. identify which existing components can be reused
2. compose the page from those components
3. create a new component only if the need is truly unique

## Core components

### HeaderStore
Purpose:
- logo
- search
- account
- cart
- hotline/support
- main category navigation

Use on:
- Store
- Customer

### FooterStore
Purpose:
- contact
- policy links
- warranty/returns
- payment/shipping
- trust-building information

Use on:
- Store
- Customer

### SidebarAdmin
Purpose:
- internal navigation for Admin/Sales/Warehouse/Support
- compact, predictable, consistent navigation

Use on:
- Admin
- Sales
- Warehouse
- Support

### PageHeader
Purpose:
- page title
- breadcrumb
- primary actions
- summary info if needed

Use on:
- all areas

### AppButton
Variants:
- primary
- secondary
- danger
- ghost (only if really needed)

Rules:
- primary = red fill
- secondary = white fill + gray border
- danger = destructive intent only
- keep size and radius consistent

### FormField
Includes:
- label
- input/select/textarea
- helper text
- validation message

Rules:
- consistent spacing
- consistent focus state
- aligned labels

### ProductCard
Must support:
- product image
- product name
- current price
- old price
- optional discount badge
- optional short specs or stock state
- CTA to view/add

Rules:
- practical and scannable
- pricing must dominate lower content
- no decorative overload

### FilterSidebar / FilterBar
Must support:
- group title
- checkbox/radio/select groups
- reset filter action
- optional selected chips

Use on:
- product listings
- admin listing pages
- warehouse filtering

### StatusBadge
Common statuses:
- in stock
- out of stock
- pending
- confirmed
- shipping
- completed
- canceled
- draft
- published
- hidden

Rules:
- same shape
- same text style
- same color logic everywhere

### DataTable
Must support:
- clear header row
- row actions
- hover state
- status column
- search/filter toolbar nearby
- responsive fallback if needed

Use on:
- Admin
- Sales
- Warehouse
- Support

### SummaryCard / KPI Card
Use for:
- dashboard metrics
- quick counts
- revenue/order summaries
- low stock counters

Rules:
- bold number
- short label
- optional icon
- subtle styling

## Mapping by area
### Store
- HeaderStore
- FooterStore
- ProductCard
- FilterSidebar
- PageHeader
- AppButton
- FormField

### Customer
- HeaderStore
- FooterStore
- PageHeader
- AppButton
- FormField
- DataTable or card-list for orders
- StatusBadge

### Admin
- SidebarAdmin
- PageHeader
- AppButton
- FormField
- DataTable
- StatusBadge
- SummaryCard

### Sales / Warehouse / Support
- SidebarAdmin
- PageHeader
- AppButton
- FormField
- DataTable
- StatusBadge
- SummaryCard where needed

## Component creation rules
If a truly new component must be created:
- derive its spacing from the shared scale
- derive its colors from the shared tokens
- derive its typography from the shared type scale
- name it clearly
- keep the API simple
- document its intended reuse

## Do not
- introduce style drift
- duplicate nearly identical components
- create isolated one-off buttons/cards/forms without reason

## Output expectations
When this skill is active, the output should:
- state which shared components are used
- minimize one-off styling
- preserve consistency across areas
