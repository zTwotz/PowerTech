---
name: agent-execution-rules
description: Use as the general operating rulebook for the agent when working on this project, including consistency, decision hierarchy, and how to combine other skills.
---

# Agent Execution Rules Skill

## When to use this skill
Use this skill as the default operating guide whenever the agent performs substantial work on this project.

## Decision hierarchy
If there is any ambiguity, resolve decisions in this order:

1. project business scope
2. security and role correctness
3. navigation and workflow correctness
4. data/model correctness
5. design-system consistency
6. implementation convenience

## Mandatory behavior rules
The agent must:
- identify area and actor before implementing
- preserve multi-role authorization assumptions
- preserve the shared UI system
- work in dependency order
- prefer reuse over invention
- explain file changes in a structured way when appropriate
- avoid unnecessary rewrites of working code

## Skill composition rules
When a task is received, combine skills like this:

### For UI work
Load:
- project-context
- ui-style-system
- component-library
- navigation-screen-priority

### For backend/architecture work
Load:
- project-context
- aspnet-mvc-architecture
- database-domain-rules
- ecommerce-business-rules
- implementation-workflow

### For feature completion or review
Load:
- relevant implementation skills
- testing-qa-review

## Change safety rules
Before changing existing code:
1. identify affected area
2. identify impacted workflows
3. identify shared components or services
4. minimize breakage
5. keep naming and structure consistent

## Naming consistency rules
Use stable naming across:
- areas
- controllers
- viewmodels
- services
- entities
- components

Do not rename established concepts casually.

## Communication rules
When proposing work, prefer:
- scope summary
- assumptions
- dependencies
- concrete implementation steps
- constraints or risks

## Anti-drift rules
The agent must not:
- silently change the project style direction
- silently collapse role boundaries
- hardcode throwaway logic that fights the architecture
- add flashy UI that breaks the design system
- prioritize optional screens ahead of core business workflows

## Completion rules
A task is not considered complete if:
- the workflow is broken
- authorization is wrong
- the UI is inconsistent
- the navigation dead-ends
- the schema or service assumptions are violated

## Output expectations
The agent should behave like a disciplined teammate:
- consistent
- dependency-aware
- architecture-aware
- business-aware
- design-aware
