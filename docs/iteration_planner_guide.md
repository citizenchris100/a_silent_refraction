# Iteration Planner Guide

This document provides a comprehensive guide to using the enhanced Iteration Planning System for A Silent Refraction.

## Overview

The Iteration Planning System helps manage the development of A Silent Refraction through structured iterations (similar to Agile sprints). The system has been enhanced to include formal requirements tracking at both the Epic (iteration) and User Story (task) levels.

## Key Features

- **Requirements-Driven Development:** Track both high-level business/user requirements and detailed task-level user stories
- **Traceability:** Link individual tasks to Epic-level requirements using requirement IDs
- **Progress Reporting:** Generate comprehensive reports showing progress across all iterations
- **User Story Format:** Standardized "As a [role], I want [feature], so that [benefit]" format for clarity

## Command Reference

| Command | Description |
|---------|-------------|
| `./iteration_planner.sh init` | Initialize the planning system |
| `./iteration_planner.sh create <iter_num> "<name>"` | Create a new iteration |
| `./iteration_planner.sh list <iter_num>` | List tasks for a specific iteration |
| `./iteration_planner.sh update <iter> <task> <status>` | Update task status (pending/in_progress/complete) |
| `./iteration_planner.sh report` | Generate progress report across all iterations |
| `./iteration_planner.sh link <iter> <task> "<file_path>"` | Link a task to a code file |
| `./iteration_planner.sh add-req <iter> <type> "<text>"` | Add a requirement to an iteration (type: business/user/technical) |
| `./iteration_planner.sh add-story <iter> <task> "<story>"` | Add a user story to a task |
| `./iteration_planner.sh help` | Show help message |

## Requirement Types

The system supports three types of requirements at the Epic level:

1. **Business Requirements (B1, B2, etc.):** High-level business needs that the iteration addresses
   - Include rationale and success metrics
   - Example: `B1: Establish core game mechanic of NPC suspicion to drive gameplay tension`

2. **User Requirements (U1, U2, etc.):** Player-focused needs and experiences 
   - Include user value and acceptance criteria
   - Example: `U1: As a player, I want to observe subtle cues that help identify assimilated NPCs`

3. **Technical Requirements (T1, T2, etc.):** Implementation constraints and technical considerations
   - Include rationale and constraints
   - Example: `T1: Create extensible NPC state machine system`

## User Story Format

Task-level requirements follow the User Story format:

```
As a [role], I want [feature/capability], so that [benefit/value].
```

Example: `As a player, I want to see a visual indicator of my current suspicion level, so that I can make informed decisions about my actions and interactions with NPCs.`

Each user story includes:
- **Linked Requirements:** References to Epic-level requirements (e.g., B1, U2)
- **Acceptance Criteria:** Specific conditions that must be met for the story to be considered complete
- **Implementation Notes:** Technical guidance or approach

## How Requirements Flow Through the System

1. **Epic-Level Requirements:** Define high-level business/user needs for the iteration
2. **Task-Level User Stories:** Break down Epic requirements into specific, actionable tasks
3. **Traceability:** Tasks link back to Epic requirements to ensure comprehensive coverage
4. **Progress Reporting:** Reports include requirements to provide context for tasks

## Best Practices

1. **Create Clear Business Requirements:** Focus on the "why" - what business value does this iteration provide?
2. **Write User-Centric User Requirements:** Clearly articulate what the player will experience
3. **Technical Requirements are Optional:** Only include when there are specific technical constraints
4. **User Stories Should Be Specific:** Each story should focus on one piece of functionality
5. **Link Tasks to Requirements:** Always specify which Epic-level requirements a task addresses
6. **Update Progress Regularly:** Keep the system up-to-date to get accurate progress reports

## Example Workflow

1. Initialize the system: `./iteration_planner.sh init`
2. Create a new iteration: `./iteration_planner.sh create 2 "NPC Framework and Suspicion System"`
3. Add a business requirement: `./iteration_planner.sh add-req 2 business "Create reusable NPC framework to streamline future character development"`
4. Add a user requirement: `./iteration_planner.sh add-req 2 user "Players can track their suspicion level with accessible UI"`
5. Add a user story to a task: `./iteration_planner.sh add-story 2 3 "As a player, I want to see a visual indicator of my current suspicion level, so that I can make informed decisions about my actions and interactions with NPCs"`
6. Link a task to a code file: `./iteration_planner.sh link 2 3 "src/ui/suspicion_meter/global_suspicion_meter.gd"`
7. Update task status: `./iteration_planner.sh update 2 3 complete`
8. Generate progress report: `./iteration_planner.sh report`

## Conclusion

The enhanced Iteration Planning System provides a comprehensive framework for managing the development of A Silent Refraction in a requirements-driven manner. By focusing on both high-level business/user needs and detailed task-level user stories, the system ensures that development remains aligned with project goals while providing clear guidance for implementation.