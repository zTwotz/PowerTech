---
name: testing-qa-review
description: Use when reviewing code, testing features, validating UI consistency, permissions, workflows, or preparing a feature for handoff.
---

# Testing, QA, and Review Skill

## When to use this skill
Use this skill when:
- reviewing a completed feature
- validating a workflow
- checking permissions
- preparing a merge/handoff
- testing UI consistency
- looking for regressions

## Review dimensions
Every feature review should check 5 dimensions:

1. **Functional correctness**
2. **Permission correctness**
3. **UI consistency**
4. **Workflow completeness**
5. **Data consistency**

## Functional checklist
Validate:
- the main happy path works
- form validation works
- success and failure states are clear
- redirects go to the correct next screen
- list/detail/edit flows behave correctly

## Permission checklist
Validate:
- Guest cannot enter protected screens
- Customer accesses only own account/order data
- Sales cannot manage unrelated admin data
- Warehouse cannot change pricing or payment logic
- Support cannot alter finance/order management beyond allowed scope
- Admin can access admin features and authorized internal features

## UI consistency checklist
Validate:
- shared colors are preserved
- spacing is consistent
- cards/forms/tables/buttons match the design system
- no rogue components appear
- responsive behavior is acceptable

## Workflow checklist
Validate end-to-end business logic:
- product browsing flows to cart correctly
- checkout creates orders correctly
- order list/detail reflects the order correctly
- sales processing updates expected statuses
- warehouse changes affect stock correctly
- review/ticket workflows reach the correct next state

## Data consistency checklist
Validate:
- stock history is recorded when required
- orders and order items match totals
- role assignments persist correctly
- product specs display correctly by category
- review and ticket linkage is correct

## Bug reporting format
When reporting a problem, structure it as:
1. issue title
2. area/screen
3. reproduction steps
4. expected result
5. actual result
6. severity
7. suspected root cause
8. suggested fix

## Review output format
When reviewing a feature, produce:
- pass/fail summary
- blocking issues
- non-blocking improvements
- permission concerns
- UI consistency concerns
- recommended next fixes

## Do not
- approve a feature only because the UI looks good
- ignore permission leaks
- ignore status or stock inconsistencies
- ignore navigation dead ends

## Output expectations
Outputs should be audit-friendly and actionable.
