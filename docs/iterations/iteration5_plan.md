# Iteration 5: Time and Notification Systems

## Epic Description
**Phase**: 1 - MVP Foundation  
**Cohesive Goal**: "Time flows and the game can communicate with the player"

As a player, I need to feel the passage of time creating urgency in my investigation, while receiving clear feedback about important events and system states through a unified notification system.

## Goals
- Implement Time Management System MVP
- Create Prompt Notification System for all player communications
- Build basic calendar/clock UI
- Establish time-based event foundation
- Integrate notifications across all existing systems

## Requirements

### Business Requirements
- **B1:** Create a sense of progression and urgency through time management
  - **Rationale:** Time-based gameplay creates strategic choices and replay value
  - **Success Metric:** Players report making meaningful time allocation decisions in test sessions

- **B2:** Establish consistent player communication patterns
  - **Rationale:** Clear feedback reduces player frustration and improves engagement
  - **Success Metric:** 95% of player actions have appropriate feedback

### User Requirements
- **U1:** As a player, I want to see time passing in the game world
  - **User Value:** Creates immersion and strategic planning opportunities
  - **Acceptance Criteria:** Clock and calendar UI clearly shows current time/date

- **U2:** As a player, I want clear notifications about important events
  - **User Value:** Never miss critical information or system feedback
  - **Acceptance Criteria:** All major events trigger appropriate notifications

- **U3:** As a player, I want to manage my time strategically
  - **User Value:** Time pressure creates meaningful choices
  - **Acceptance Criteria:** Different actions consume different amounts of time

### Technical Requirements
- **T1:** Implement centralized time management system
  - **Rationale:** All systems need consistent time reference
  - **Constraints:** Must be serializable and deterministic

- **T2:** Create flexible notification queue system
  - **Rationale:** Multiple systems need to communicate with player
  - **Constraints:** Must not block gameplay or create notification spam

## Tasks

### Time Management System
- [ ] Task 1: Create TimeManager singleton
- [ ] Task 2: Implement game clock (hours, minutes)
- [ ] Task 3: Implement calendar system (days, months, years)
- [ ] Task 4: Create time advancement mechanics
- [ ] Task 5: Implement action duration system
- [ ] Task 6: Create time-based event scheduler

### Notification System
- [ ] Task 7: Create PromptNotificationSystem singleton
- [ ] Task 8: Implement notification queue and priority system
- [ ] Task 9: Create notification UI component
- [ ] Task 10: Implement notification categories and filtering
- [ ] Task 11: Add notification sound support (prep for audio)

### UI Implementation
- [ ] Task 12: Create clock UI display
- [ ] Task 13: Create calendar UI display
- [ ] Task 14: Implement time controls (pause, speed settings)
- [ ] Task 15: Create notification display area

### System Integration
- [ ] Task 16: Integrate time system with existing game flow
- [ ] Task 17: Add notifications to existing systems
- [ ] Task 18: Implement time serialization
- [ ] Task 19: Create time-based debug tools

## User Stories

### Task 1: Create TimeManager singleton
**User Story:** As a developer, I want a central time management system, so that all game systems can reference and advance time consistently.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. TimeManager exists as autoload singleton
  2. Tracks current time (hour, minute, day, month, year)
  3. Provides methods to advance time by specific durations
  4. Emits signals for time change events
  5. Integrates with serialization system from I4

**Implementation Notes:**
- Start date: Day 1, Month 1, Year 2157, 08:00
- 24-hour days, 30-day months, 12-month years
- Time advances in 5-minute increments minimum
- Reference: docs/design/time_management_system_mvp.md

### Task 7: Create PromptNotificationSystem singleton
**User Story:** As a player, I want to receive clear notifications about game events, so that I never miss important information.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. PromptNotificationSystem exists as autoload singleton
  2. Supports queued notifications with priorities
  3. Provides different notification types (info, warning, critical)
  4. Notifications auto-dismiss or require confirmation
  5. Integrates with future audio system

**Implementation Notes:**
- Priority levels: LOW, NORMAL, HIGH, CRITICAL
- Queue max size: 10 notifications
- Auto-dismiss after 5 seconds for non-critical
- Reference: docs/design/prompt_notification_system_design.md

### Task 5: Implement action duration system
**User Story:** As a player, I want different actions to take different amounts of time, so that I must make strategic choices about how to spend my limited time.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Actions have configurable duration in minutes
  2. Time advances when actions complete
  3. Player sees time cost before committing to actions
  4. Can't perform actions that would exceed day limits
  5. Duration data is easily configurable

**Implementation Notes:**
- Example durations: Talk (10 min), Travel (30 min), Work (4 hours)
- Store durations in resource files for easy balancing
- Show time cost in hover text and confirmations
- Maximum single action: 8 hours (work shift)

## Testing Criteria
- Time advances correctly for all actions
- Calendar system tracks days/months/years properly
- Notifications appear for all major events
- Time system saves and loads correctly
- UI displays current time clearly
- Performance remains smooth with time updates
- Notification queue handles spam gracefully

## Timeline
- Start date: After Iteration 4 completion
- Target completion: 2 weeks
- Critical for: Iteration 7 (Save/Sleep needs time)

## Dependencies
- Iteration 4: Serialization Foundation (time must be saved)
- UI foundation from previous iterations

## Code Links
- src/core/time/time_manager.gd (to be created)
- src/core/notifications/prompt_notification_system.gd (to be created)
- src/ui/time/clock_display.gd (to be created)
- src/ui/time/calendar_display.gd (to be created)
- docs/design/time_management_system_mvp.md
- docs/design/prompt_notification_system_design.md
- docs/design/time_calendar_display_ui_design.md

## Notes
- Time system is foundational for many Phase 2 systems
- Notification system will be used by all future systems
- Consider time speed settings for development/testing
- Time pressure is key to creating game tension