---
name: ui-style-system
description: Use when generating or reviewing UI, pages, components, layouts, or styling rules for consistent retail-tech design across the website.
---

# UI Style System Skill

## When to use this skill
Use this skill whenever the task involves:
- page layout
- styling
- component appearance
- design system decisions
- responsive behavior
- visual consistency across areas

## Design direction
The visual direction is **retail-tech**, inspired by large computer hardware ecommerce websites:
- modern
- clean
- strong
- practical
- conversion-oriented
- information-dense but structured

The UI must feel:
- trustworthy
- technical
- professional
- sales-ready

It must **not** feel:
- childish
- pastel
- experimental
- glassmorphism-heavy
- neon cyberpunk
- luxury-minimalist to the point of losing ecommerce clarity

## Default color tokens
Use these tokens unless the user explicitly changes branding:

```css
:root {
  --color-primary: #D7262E;
  --color-primary-hover: #B91F26;
  --color-primary-soft: #FDEBEC;

  --color-text: #111111;
  --color-text-secondary: #4B5563;
  --color-text-muted: #6B7280;

  --color-bg: #FFFFFF;
  --color-bg-soft: #F7F7F8;
  --color-surface: #FFFFFF;
  --color-surface-alt: #F3F4F6;

  --color-border: #E5E7EB;
  --color-border-strong: #D1D5DB;

  --color-success: #16A34A;
  --color-warning: #D97706;
  --color-danger: #DC2626;
  --color-info: #2563EB;
}
```

## Typography
Default font stack:
```css
font-family: Inter, "Segoe UI", Roboto, Arial, sans-serif;
```

Type scale:
- Page title: 32px / 700
- Section title: 24px / 700
- Card title: 16-18px / 600
- Body text: 14-16px / 400-500
- Label/meta: 12-13px / 500
- Main price: 20-24px / 700
- Old price: 14-16px / 500 with line-through

## Spacing scale
Use only this spacing scale by default:
- 4
- 8
- 12
- 16
- 20
- 24
- 32
- 40
- 48
- 64

Do not use random inconsistent spacing unless necessary.

## Radius and elevation
- Large card radius: 16px
- Standard card radius: 12px
- Inputs/buttons: 10-12px
- Shadows must stay subtle

Recommended shadow:
```css
box-shadow: 0 4px 16px rgba(0, 0, 0, 0.05);
```

## Layout rules
- Desktop-first, then responsive.
- Main container width: roughly 1200-1320px.
- Storefront should use broad, readable layouts.
- Admin/internal areas should favor dense but clean operational layouts.

## Area-specific visual rules
### Store
- most visually rich area
- banners, product cards, promo blocks, filters
- stronger use of primary color

### Customer
- simpler than Store
- more account/order focused
- form-heavy but still aligned to storefront style

### Admin / Sales / Warehouse / Support
- cleaner and flatter
- more tables, forms, filters, dashboard cards
- less promotional styling
- stronger information hierarchy

## Mandatory consistency rules
The agent must not:
- create a different button style for every page
- create a different card style for every page
- swap branding colors per screen
- overuse gradients, glow, or decorative effects
- make internal dashboards look like landing pages

## Screen review checklist
Before finalizing any UI:
1. Does it use the shared color tokens?
2. Does it use the shared spacing scale?
3. Does it reuse existing button, input, card, badge patterns?
4. Is the primary CTA obvious?
5. Is the information easy to scan quickly?
6. Does the page still feel like the same product?

## Output expectations
Outputs should:
- look consistent across screens
- be implementation-ready
- preserve the same design language across all areas
