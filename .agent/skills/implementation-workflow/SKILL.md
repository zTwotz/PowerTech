---
name: implementation-workflow
description: Use when planning or executing implementation steps for a feature, including order of work, dependencies, deliverables, and developer workflow.
---

# Implementation Workflow Skill

## When to use this skill
Use this skill when the task requires:
- a build plan
- feature decomposition
- step-by-step execution
- implementation order
- dependency-aware development
- sprint or task breakdown

## Default implementation philosophy
Work from **foundations to flows**, not from isolated screens to disconnected code.

Preferred order:
1. identity and authorization foundations
2. catalog master data
3. storefront browsing
4. cart and checkout
5. customer account/order screens
6. admin management
7. internal operations
8. optional extensions

## Feature implementation template
For each feature, follow this order:

1. **Clarify scope**
   - which area?
   - which actor?
   - what business value?
   - what dependencies?

2. **Check existing skills**
   - project context
   - architecture
   - business rules
   - navigation priority
   - UI style
   - testing/QA

3. **Define data impact**
   - entities involved
   - schema change required?
   - validation rules?
   - transaction boundaries?

4. **Define backend workflow**
   - services
   - controller actions
   - authorization
   - status transitions
   - stock impact if any

5. **Define ViewModels and UI states**
   - page data
   - filters
   - form state
   - validation messages
   - empty/loading/error states

6. **Implement UI using shared components**
   - no one-off style drift
   - reuse buttons, tables, forms, cards

7. **Run flow validation**
   - entry point
   - action path
   - redirect/next page
   - role restriction
   - success/failure states

8. **Run QA checklist**
   - visual
   - functional
   - permission
   - edge cases

## Recommended project-level sequence
### Phase 1: Auth foundation
- Login
- Register
- Forgot/change password
- role-aware navigation

### Phase 2: Admin catalog foundation
- user/role management
- category
- brand
- specification definitions
- product management
- product create/edit

### Phase 3: Storefront MVP
- homepage
- product listing
- product detail
- cart
- checkout

### Phase 4: Customer self-service
- profile
- address book
- my orders
- order detail
- review

### Phase 5: Internal operations
- sales order queue
- sales order processing
- inventory
- receiving
- stock issue by order
- support tickets
- moderation

### Phase 6: Extensions
- dashboard enrichments
- content management enrichments
- warranty/returns
- sales analytics

## Packaging work for an agent
When asked to implement a screen or feature, the agent should return:
- scope summary
- dependencies
- files to create/update
- recommended order of edits
- validation checklist

## Do not
- start from low-value extension screens first
- skip dependencies
- build screens that cannot work because the underlying models/services are missing
- build isolated UI mocks and call the feature complete

## Output expectations
The output should help a developer or agent execute work in a realistic order.
