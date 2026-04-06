---
name: ecommerce-business-rules
description: Use when implementing or validating business workflows such as browsing, cart, checkout, ordering, stock handling, reviews, tickets, and multi-role operations.
---

# Ecommerce Business Rules Skill

## When to use this skill
Use this skill when the task affects the project's real business workflows.

Typical triggers:
- cart logic
- checkout
- order lifecycle
- stock updates
- review moderation
- support tickets
- role-specific business operations
- admin-created accounts

## Core public workflows

### Storefront browsing
Guests and Customers can:
- view homepage
- browse categories
- search products
- filter by brand, price, specification, stock state
- sort by price, newest, best-selling
- view product detail
- read policies/news/guides

### Product detail workflow
The detail page must emphasize:
- images
- name
- current price
- old price if any
- short and detailed description
- technical specifications
- stock state
- warranty info
- related products
- add-to-cart / buy-now actions

### Cart workflow
The cart must support:
- add item
- change quantity
- remove item
- compute totals
- continue shopping
- proceed to checkout

### Checkout workflow
Checkout requires:
- authenticated customer
- receiver information
- shipping address
- payment selection
- order summary
- order creation

Checkout should create:
- Order
- OrderItem records
- Payment record or payment state

### Customer account workflow
Customer can:
- manage profile
- manage addresses
- view order list
- view order detail
- cancel eligible orders
- review purchased products
- change password
- use forgot password flow

## Internal workflows

### Sales
Sales can:
- view new orders
- confirm orders
- contact customer
- update order status
- create counter orders
- view order-processing performance if that screen is enabled

### Warehouse
Warehouse can:
- view stock
- create receiving records
- record stock issue by order
- monitor low stock
- trace stock history

### Support
Support can:
- view tickets
- process ticket detail
- moderate reviews
- optionally handle warranty/return requests if that extension is enabled

### Admin
Admin can:
- manage users and roles
- create accounts
- promote users into internal roles
- manage category, brand, specs, products
- manage orders
- manage reviews
- manage content
- monitor dashboard metrics

## Order state consistency
Whenever a feature touches order state:
- use a defined status set
- keep transitions consistent
- ensure Sales and Warehouse understand the same operational signals
- do not let stock and order states drift apart

Suggested statuses:
- PendingConfirmation
- Confirmed
- Preparing
- Shipping
- Completed
- Cancelled

## Stock consistency
Whenever a feature changes stock:
- stock changes must be traceable
- receiving increases stock
- issue-by-order decreases stock
- low-stock indicators are derived from current stock and thresholds

## Review rules
Reviews should be linked to product and customer.
If moderation is enabled:
- customer submits review
- support/admin approves, hides, or removes it
- storefront only shows approved/public reviews

## Ticket rules
Support tickets must support:
- status
- customer linkage
- content/history
- assignee or processor if needed

## Account creation rules
Two account creation paths must remain valid:
1. self-registration -> Customer
2. admin-created account -> one or more assigned roles

## Do not
- let checkout bypass identity rules without a deliberate design decision
- update stock silently without history
- let every role edit everything
- break the core order lifecycle with ad-hoc status changes

## Output expectations
When this skill is active, outputs should:
- preserve business workflow order
- make role boundaries explicit
- keep stock, orders, and authorization aligned
