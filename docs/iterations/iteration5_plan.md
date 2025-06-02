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

### Performance Infrastructure
- [ ] Task 30: Implement performance telemetry framework
- [ ] Task 31: Create in-game performance metric collection
- [ ] Task 32: Add performance regression tracking system

### Event System Foundation
- [ ] Task 33: Design event system data structures
- [ ] Task 34: Create base event serialization format
- [ ] Task 35: Implement event timestamp tracking
- [ ] Task 36: Create event notification categories

### Notification System UI
- [ ] Task 37: Implement UI visual styling for notification types
- [ ] Task 38: Create modal dialog UI component

### Debugging and Testing
- [ ] Task 39: Create notification system debug tools
- [ ] Task 40: Add notification stress testing capabilities
- [ ] Task 41: Implement notification history viewer
- [ ] Task 42: Create notification category filtering
- [ ] Task 43: Add performance monitoring for notifications
- [ ] Task 44: Implement notification replay system
- [ ] Task 45: Create mock notification generator
- [ ] Task 46: Add notification analytics dashboard
- [ ] Task 47: Implement notification sound test interface
- [ ] Task 48: Create notification template system
- [ ] Task 49: Add bulk notification management tools
- [ ] Task 50: Implement notification export/import
- [ ] Task 51: Create automated notification testing

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

### Task 2: Implement game clock (hours, minutes)
**User Story:** As a player, I want time to pass realistically in hours and minutes, so that I can plan my daily activities within the game world.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. 24-hour clock format
  2. Minutes advance in 5-minute increments
  3. Hour transitions work correctly
  4. Clock wraps at midnight
  5. Time display formatted properly

**Implementation Notes:**
- Internal time as float (minutes since start)
- Convert to hours:minutes for display
- Consider time acceleration for testing
- Reference: docs/design/time_management_system_mvp.md

### Task 3: Implement calendar system (days, months, years)
**User Story:** As a player, I want a calendar system to track longer time periods, so that I can plan around deadlines and understand the passage of time.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, U1
- **Acceptance Criteria:**
  1. 30-day months for simplicity
  2. 12 months per year
  3. Day advances at midnight
  4. Calendar data structure defined
  5. Special dates markable

**Implementation Notes:**
- Simple calendar for gameplay clarity
- Day 1-30, Month 1-12
- Year starts at 2157
- Reference: docs/design/time_management_system_mvp.md

### Task 4: Create time advancement mechanics
**User Story:** As a developer, I want controlled ways to advance game time, so that actions have temporal consequences and the world progresses.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Advance by specific duration
  2. Advance to specific time
  3. Skip to next day
  4. Pause/resume time flow
  5. Time multiplier support

**Implementation Notes:**
- Methods: advance_time(minutes), skip_to_time(hour)
- Emit signals for time changes
- Update all dependent systems
- Reference: docs/design/time_management_system_mvp.md

### Task 7: Create PromptNotificationSystem singleton
**User Story:** As a player, I want to receive clear notifications about game events with appropriate visual styling and performance constraints, so that I never miss important information while maintaining smooth gameplay.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. PromptNotificationSystem exists as autoload singleton
  2. Supports queued notifications with priorities (queue max size: 20)
  3. Provides different notification types (info, warning, critical, confirm, story)
  4. Notifications auto-dismiss or require confirmation
  5. Integrates with future audio system
  6. Implements performance constraints (history: 1000 entries, message length: 2000 chars)
  7. Provides convenience methods (show_info, show_warning, show_critical, show_confirm, show_story)
  8. Proper deduplication by notification ID

**Implementation Notes:**
- Priority levels: CRITICAL=0, WARNING=10, STORY=20, CONFIRM=30, INFO=40
- Queue max size: 20 notifications (increased from 10)
- Auto-dismiss after 5 seconds for non-critical
- Message length limited to 2000 characters
- History automatically pruned at 1000 entries
- Convenience methods reduce boilerplate for common notifications
- Reference: docs/design/prompt_notification_system_design.md

### Task 8: Implement notification queue and priority system
**User Story:** As a player, I want notifications to be queued and shown in order of importance, so that critical information is never buried under less important messages.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, T2
- **Acceptance Criteria:**
  1. Notification queue with configurable max size (20)
  2. Priority-based ordering (lower number = higher priority)
  3. Automatic deduplication by notification ID
  4. Queue overflow handling (drops lowest priority)
  5. Proper queue state management
  6. Signal emission for queue changes

**Implementation Notes:**
- FIFO within same priority level
- Critical notifications can clear queue
- Reference: docs/design/prompt_notification_system_design.md

### Task 9: Create notification UI component
**User Story:** As a player, I want a consistent UI component for all notifications, so that I can easily recognize and interact with game messages.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Reusable notification UI scene
  2. Title and message text areas
  3. OK button for dismissal
  4. Proper sizing and centering
  5. Fade in/out animations
  6. Keyboard and mouse support

**Implementation Notes:**
- Base UI component for all notification types
- Must be theme-able for different styles
- Reference: docs/design/prompt_notification_system_design.md

### Task 10: Implement notification categories and filtering
**User Story:** As a player, I want notifications organized by category, so that I can understand the context of each message at a glance.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Category system implemented (System, Story, Economy, etc.)
  2. Category-based filtering options
  3. Category icons and colors
  4. Per-category priority defaults
  5. Category statistics tracking

**Implementation Notes:**
- Categories help with future filtering features
- Prepare for player preferences in Phase 2
- Reference: docs/design/prompt_notification_system_design.md

### Task 11: Add notification sound support (prep for audio)
**User Story:** As a developer, I want the notification system prepared for audio integration, so that we can easily add sounds in Phase 2.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T2
- **Acceptance Criteria:**
  1. Sound trigger points identified
  2. Audio bus routing prepared
  3. Per-type sound settings structure
  4. Volume control integration points
  5. Placeholder sound file paths

**Implementation Notes:**
- No actual audio in Phase 1
- Structure ready for Phase 2 audio
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

### Task 6: Create time-based event scheduler
**User Story:** As a developer, I want a system that can trigger events at specific times, so that the world can have scheduled activities and deadlines.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Can schedule events for specific times
  2. Triggers callbacks when time reached
  3. Supports recurring events
  4. Handles missed events gracefully
  5. Integrates with TimeManager

**Implementation Notes:**
- Foundation for living world in I8
- Simple callback system for MVP
- Consider performance with many events
- Reference: docs/design/time_management_system_mvp.md

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

### Task 14: Implement time controls (pause, speed settings)
**User Story:** As a developer, I want debug controls for time manipulation, so that I can test time-based features efficiently.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Debug panel with time controls
  2. Pause/resume time flow
  3. Time speed multiplier (1x, 2x, 10x)
  4. Jump to specific time/date
  5. Only available in debug builds

**Implementation Notes:**
- Debug-only feature for testing
- Hotkeys for common operations
- Reference: docs/design/time_management_system_mvp.md

### Task 15: Create notification display area
**User Story:** As a player, I want a dedicated area for notifications to appear, so that they don't obscure important game elements.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Centered screen position for modals
  2. Proper layering (always on top)
  3. Background dimming when active
  4. Responsive to screen size changes
  5. Accessibility considerations

**Implementation Notes:**
- Modal overlay approach
- Must not conflict with other UI
- Reference: docs/design/prompt_notification_system_design.md

### Task 16: Integrate time system with existing game flow
**User Story:** As a player, I want all game actions to properly advance time, so that the world feels consistent and time has meaning.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Movement actions advance time
  2. Conversations advance time
  3. Inventory actions have time cost
  4. All systems use TimeManager
  5. Time flow feels natural

**Implementation Notes:**
- Retrofit existing systems
- Consistent time costs across game
- Reference: docs/design/time_management_system_mvp.md

### Task 17: Add notifications to existing systems
**User Story:** As a player, I want all game systems to use the unified notification system, so that I receive consistent feedback.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Save system uses notifications
  2. Inventory uses notifications
  3. Dialog system uses notifications
  4. All error messages use notifications
  5. Remove old feedback systems

**Implementation Notes:**
- Systematic replacement of old UI
- Consistent messaging patterns
- Reference: docs/design/prompt_notification_system_design.md

### Task 18: Implement time serialization
**User Story:** As a player, I want the game time to be saved and restored correctly, so that my progress through time is preserved.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. TimeManager implements BaseSerializer
  2. All time data properly saved
  3. Scheduled events preserved
  4. Time resumes correctly on load
  5. Handles version migration

**Implementation Notes:**
- Priority order in save system
- Include scheduled events
- Reference: docs/design/time_management_system_mvp.md

### Task 19: Create time-based debug tools
**User Story:** As a developer, I want comprehensive debug tools for the time system, so that I can diagnose time-related bugs.

**Design Reference:** `docs/design/time_management_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Time flow visualization
  2. Event schedule viewer
  3. Time advancement log
  4. Performance metrics
  5. Time validation tools

**Implementation Notes:**
- Debug overlay for time info
- Event timeline visualization
- Reference: docs/design/time_management_system_mvp.md

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

### Task 30: Implement performance telemetry framework
**User Story:** As a developer, I want an in-game telemetry framework that collects performance metrics during development and testing, so that I can identify performance bottlenecks early and track optimization progress.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Performance Metric Infrastructure
- **Acceptance Criteria:**
  1. FPS tracking with percentiles (p50, p95, p99)
  2. Memory usage monitoring (current, peak, delta)
  3. Frame time analysis and spikes detection
  4. Per-system performance breakdown
  5. Minimal overhead (<1% performance impact)

**Implementation Notes:**
- Create PerformanceMonitor singleton
- Ring buffer for historical data
- Export metrics to CSV for analysis
- Optional HUD overlay for development

### Task 31: Create in-game performance metric collection
**User Story:** As a developer, I want to collect detailed performance metrics during gameplay, so that I can ensure the game meets hardware validation targets of 30fps stable and <4GB memory usage.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Key Metrics to Track
- **Acceptance Criteria:**
  1. Track load times (boot, districts, save/load)
  2. Monitor CPU/GPU utilization
  3. Detect thermal throttling events
  4. Per-district memory profiling
  5. Automatic metric snapshots at key points

**Implementation Notes:**
- Hook into scene transitions for load time tracking
- Sample metrics every 100ms
- Create performance report on game exit
- Flag when metrics exceed targets

### Task 32: Add performance regression tracking system
**User Story:** As a developer, I want automated alerts when performance regresses below our targets, so that optimization issues are caught immediately during development.

**Status History:**
- **⏳ PENDING** (06/01/25)

**Requirements:**
- **Linked to:** Hardware Validation Plan - Alert System
- **Acceptance Criteria:**
  1. Baseline performance profiles stored
  2. Automatic comparison on each run
  3. Alert when FPS drops below 30
  4. Alert when memory exceeds 4GB
  5. Regression report generation

**Implementation Notes:**
- Store baselines in res://benchmarks/
- Compare against previous 5 runs
- Log regressions to file
- Optional popup warnings in debug builds

### Task 33: Design event system data structures
**User Story:** As a developer, I want to define the core data structures for events, so that the event system has a solid foundation for future expansion.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Event base class defined
  2. Event data dictionary structure
  3. Event type enumeration
  4. Priority system defined
  5. Extensible for future types

**Implementation Notes:**
- Reference event_data structure in MVP design
- Keep simple but extensible
- Consider performance implications
- Reference: docs/design/living_world_event_system_mvp.md

### Task 34: Create base event serialization format
**User Story:** As a developer, I want events to have a defined serialization format, so that they can be saved and loaded efficiently.

**Design Reference:** `docs/design/living_world_event_system_mvp.md` & `docs/design/modular_serialization_architecture.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** T1
- **Acceptance Criteria:**
  1. Event to dictionary conversion
  2. Dictionary to event restoration
  3. Compression-friendly format
  4. Version field included
  5. Follows modular pattern

**Implementation Notes:**
- Prepare for EventSerializer in I8
- Use short keys for space efficiency
- Reference: docs/design/modular_serialization_architecture.md

### Task 35: Implement event timestamp tracking
**User Story:** As a developer, I want all events to have timestamps, so that we can track when events occur and sort them chronologically.

**Design Reference:** `docs/design/living_world_event_system_mvp.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B1, T1
- **Acceptance Criteria:**
  1. Events store creation timestamp
  2. Events store trigger timestamp
  3. Time format matches TimeManager
  4. Sorting by timestamp works
  5. Serializable timestamps

**Implementation Notes:**
- Use TimeManager time format
- Both scheduled and actual times
- Consider timezone issues
- Reference: docs/design/time_management_system_mvp.md

### Task 36: Create event notification categories
**User Story:** As a player, I want different types of events to use appropriate notification styles, so that I can quickly understand their importance.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Event notification categories defined
  2. Map event types to notification types
  3. Priority levels per category
  4. Visual distinction planned
  5. Audio cues planned

**Implementation Notes:**
- Categories: World, Security, Economic, Social
- Different urgency levels
- Prepare for audio in Phase 2
- Reference: docs/design/prompt_notification_system_design.md

### Task 37: Implement UI visual styling for notification types
**User Story:** As a player, I want different notification types to have distinct visual styles, so that I can quickly understand the importance and category of each message.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Color schemes defined for each type (INFO: blue, WARNING: yellow, CRITICAL: red, CONFIRM: green, STORY: purple)
  2. Icon system for notification categories
  3. Border styles by notification type (CRITICAL gets pulsing border)
  4. Animation patterns for different priorities
  5. Consistent with game's aesthetic
  6. Header styling matches notification type
  7. Support for BBCode rich text formatting

**Implementation Notes:**
- Visual distinction helps quick recognition
- Pulsing borders for critical alerts
- Consider colorblind accessibility
- Reference: docs/design/prompt_notification_system_design.md (UI Specifications section)

### Task 38: Create modal dialog UI component
**User Story:** As a player, I want notifications to appear as modal dialogs that pause the game, so that I never miss important information during gameplay.

**Design Reference:** `docs/design/prompt_notification_system_design.md`

**Status History:**
- **⏳ PENDING** (05/26/25)

**Requirements:**
- **Linked to:** B2, U2
- **Acceptance Criteria:**
  1. Centered modal window with title and message areas
  2. Single "OK" button for acknowledgment
  3. Game time pauses while modal is displayed
  4. All player input blocked except modal interaction
  5. Supports multi-line text with scrolling if needed
  6. Proper word wrapping for long messages
  7. Keyboard support (Enter/Space to dismiss)

**Implementation Notes:**
- Modal design per UI specification in design doc
- Must handle text overflow gracefully
- Z-order ensures always on top
- Reference: docs/design/prompt_notification_system_design.md (UI Specifications section)

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