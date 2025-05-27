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

### Advanced Time/Calendar Display UI
- [ ] Task 20: Create TimeDisplay UI component with minimal/expanded states
- [ ] Task 21: Implement deadline warning system with color coding
- [ ] Task 22: Create expandable calendar view with event listings
- [ ] Task 23: Integrate time display with quest deadlines
- [ ] Task 24: Add assimilation countdown display
- [ ] Task 25: Implement contextual time information system
- [ ] Task 26: Create time display positioning system
- [ ] Task 27: Add critical event flash warnings
- [ ] Task 28: Implement time display serialization
- [ ] Task 29: Create accessibility features for time display

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

### Task 12: Create clock UI display
**User Story:** As a player, I want to see the current time clearly displayed at all times, so that I can manage my activities effectively.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Clock shows current hour and minute in 24-hour format
  2. Display is always visible in top-right corner
  3. Non-intrusive but clearly readable
  4. Updates in real-time as time advances
  5. Shows time period indicator (Morning, Afternoon, etc.)

**Implementation Notes:**
- Position: Top-right corner with configurable offset
- Format: "Day 12 | 14:30"
- Include hover tooltip for time period
- Must work with all background colors

### Task 13: Create calendar UI display
**User Story:** As a player, I want to see what day it is and upcoming events, so that I can plan my investigation around important deadlines.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Shows current day number
  2. Can expand to show upcoming events
  3. Highlights critical deadlines in red
  4. Shows days until evaluation (Day 30)
  5. Integrates with quest deadlines

**Implementation Notes:**
- Minimal view: Just day number
- Expanded view: Full calendar with events
- Color coding for urgency levels
- Must integrate with future quest system

### Task 20: Create TimeDisplay UI component with minimal/expanded states
**User Story:** As a player, I want a persistent time display that can expand to show more details, so that I can quickly check the time or get detailed schedule information as needed.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Minimal display shows day and time
  2. Hover expands to show detailed information
  3. Shows station assimilation percentage
  4. Lists upcoming events for next 3 days
  5. Displays today's schedule milestones

**Implementation Notes:**
- Minimal: "Day 12 | 14:30"
- Expanded includes evaluation countdown
- Mouse hover triggers expansion
- Reference: docs/design/time_calendar_display_ui_design.md

### Task 21: Implement deadline warning system with color coding
**User Story:** As a player, I want visual warnings when deadlines approach, so that I never miss critical events or quest objectives.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U2
- **Acceptance Criteria:**
  1. Normal state for deadlines > 3 days
  2. Warning state (orange) for 1-3 days
  3. Critical state (red + flash) for < 1 day
  4. Alert icon appears for urgent deadlines
  5. Integrates with notification system

**Implementation Notes:**
- Color constants: NORMAL, WARNING, CRITICAL
- Flash animation for critical deadlines
- Priority system for multiple deadlines

### Task 22: Create expandable calendar view with event listings
**User Story:** As a player, I want to view a full calendar showing all upcoming events, so that I can plan my investigation strategy effectively.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1, U3
- **Acceptance Criteria:**
  1. Shows 14-day calendar grid
  2. Current day is highlighted
  3. Event indicators on each day
  4. Click day for event details
  5. Evaluation day marked in red

**Implementation Notes:**
- Grid layout for calendar days
- Event type icons (quest, rent, coalition, etc.)
- Popup panel for detailed view
- Performance: lazy load event data

### Task 23: Integrate time display with quest deadlines
**User Story:** As a player, I want to see quest deadlines in the time display, so that I can prioritize time-sensitive objectives.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U3
- **Acceptance Criteria:**
  1. Shows quests due within 3 days
  2. Displays quest name and time remaining
  3. Color codes by urgency
  4. Updates when quests complete
  5. Links to quest log when available

**Implementation Notes:**
- Connect to QuestManager signals
- Filter by time_limit property
- Show most urgent quest if multiple

### Task 24: Add assimilation countdown display
**User Story:** As a player, I want constant awareness of the station's assimilation progress and evaluation deadline, so that I understand the stakes and urgency of my mission.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. Shows current assimilation percentage
  2. Displays evaluation day countdown
  3. Color indicates ending trajectory
  4. Critical warnings near evaluation
  5. Always visible in time display

**Implementation Notes:**
- Green < 35% (escape), Yellow 35-65% (undecided), Blue >= 65% (control)
- Flash warnings when < 5 days remain
- Connect to AssimilationManager signals

### Task 25: Implement contextual time information system
**User Story:** As a player, I want relevant time information based on my current location and situation, so that I can make informed decisions about my immediate actions.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Shows shop closing times when in commercial district
  2. Displays next tram departure near stations
  3. Indicates when sleep is available
  4. Warns about exhaustion effects
  5. Updates based on player location

**Implementation Notes:**
- Context detection from current district
- Dynamic info panel below main display
- Prioritize most relevant information

### Task 26: Create time display positioning system
**User Story:** As a player, I want to customize where the time display appears, so that it doesn't interfere with my preferred UI layout.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Default position in top-right corner
  2. Settings menu allows repositioning
  3. Saves position preference
  4. Snaps to screen edges
  5. Stays visible at all resolutions

**Implementation Notes:**
- Anchor system for corner placement
- Margin offsets for fine tuning
- Save position in settings file

### Task 27: Add critical event flash warnings
**User Story:** As a player, I want unmissable warnings for critical events, so that I'm alerted to urgent situations that require immediate attention.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Flash animation for critical deadlines
  2. Pursuit mode creates constant flash
  3. Evaluation approach triggers warnings
  4. Can acknowledge to stop flash
  5. Audio cue preparation for future

**Implementation Notes:**
- Flash uses AnimationPlayer
- Different patterns for event types
- Non-blocking but attention-grabbing

### Task 28: Implement time display serialization
**User Story:** As a developer, I want the time display UI state to persist between sessions, so that player preferences and tracked events are maintained.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** T1, T2
- **Acceptance Criteria:**
  1. Save display position and mode
  2. Persist expanded/collapsed state
  3. Remember tracked events
  4. Restore custom alerts
  5. Compatible with save system

**Implementation Notes:**
- TimeDisplaySerializer class
- Low priority in save order
- Handle missing data gracefully

### Task 29: Create accessibility features for time display
**User Story:** As a player with visual impairments, I want the time display to be readable with high contrast options and screen reader support.

**Design Reference:** `docs/design/time_calendar_display_ui_design.md`

**Status History:**
- **⏳ PENDING** (05/27/25)

**Requirements:**
- **Linked to:** B2
- **Acceptance Criteria:**
  1. High visibility mode with larger text
  2. High contrast color scheme
  3. Screen reader text description
  4. Keyboard shortcuts for expansion
  5. Configurable font size

**Implementation Notes:**
- Accessibility text includes all critical info
- Separate high contrast stylesheet
- Font size multiplier in settings

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