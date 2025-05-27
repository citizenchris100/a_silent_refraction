# System Integration Matrix
**Status: 📚 REFERENCE**
**Last Updated: May 26, 2025**

## Overview

This document provides a comprehensive matrix of how all game systems interact with each other in "A Silent Refraction". Updated to reflect the complete design documentation created during the Phase 1-2 design sprint (May 24-26, 2025).

## Integration Matrix

### Legend
- **→** Direct dependency (System A depends on System B)
- **↔** Bidirectional interaction (Systems exchange data/events)
- **○** Indirect relationship (through shared system)
- **◉** Designed integration (documented but not implemented)
- **✓** Well-integrated in design
- **!** Redundancy to be resolved during implementation

## System-to-System Relationships

| From ↓ / To → | Save | Sleep | Assimilation | Coalition | Economy | Detection | Quest | NPC | Dialog | Audio | Prompt | Time | District |
|----------------|------|-------|--------------|-----------|---------|-----------|-------|-----|--------|-------|--------|------|----------|
| **Save**       | -    | →     | →            | →         | →       | →         | →     | →   | →      | ◉     | ◉      | →    | →        |
| **Sleep**      | →    | -     | ↔            | ↔         | ↔       | ↔         | ↔     | ◉   | ○      | ◉     | ◉      | →    | ○        |
| **Assimilation** | ←  | ↔     | -            | ↔         | ↔       | ↔         | ↔     | →   | ○      | ◉     | ◉      | →    | →        |
| **Coalition**  | ←    | ↔     | ↔            | -         | ↔       | ↔         | ↔     | →   | →      | ◉     | ◉      | →    | →        |
| **Economy**    | ←    | ↔     | ↔            | ↔         | -       | ○         | ↔     | ○   | ○      | ◉     | →      | →    | →        |
| **Detection**  | ←    | ↔     | ↔            | ↔         | ○       | -         | ↔     | →   | →      | ◉     | →      | →    | →        |
| **Quest**      | ←    | ↔     | ↔            | ↔         | ↔       | ↔         | -     | →   | →      | ◉     | ◉      | →    | →        |
| **NPC**        | ←    | ◉     | ←            | ←         | ○       | ←         | ←     | -   | →      | ◉     | ◉      | →    | →        |
| **Dialog**     | ←    | ○     | ○            | ←         | ○       | ←         | ←     | ←   | -      | ◉     | ◉      | ○    | ○        |
| **Audio**      | ◉    | ◉     | ◉            | ◉         | ◉       | ◉         | ◉     | ◉   | ◉      | -     | ◉      | ◉    | →        |
| **Prompt**     | ◉    | ◉     | ◉            | ◉         | →       | →         | ◉     | ◉   | ◉      | ◉     | -      | ○    | ○        |
| **Time**       | ←    | ←     | ←            | ←         | ←       | ←         | ←     | ←   | ○      | ◉     | ○      | -    | ○        |
| **District**   | ←    | ○     | ←            | ←         | ←       | ←         | ←     | ←   | ○      | ←     | ○      | ○    | -        |

## Additional Systems (Phase 2)

The following systems were designed during the Phase 1-2 sprint and extend the core functionality:

| System | Design Document | Integration Status |
|--------|----------------|-------------------|
| **Investigation** | investigation_clue_tracking_system_design.md | ◉ Designed |
| **Observation** | observation_system_full_design.md | ◉ Designed |
| **Trust/Relationships** | npc_trust_relationship_system_design.md | ◉ Designed |
| **Gender Selection** | character_gender_selection_system.md | ◉ Designed |
| **Disguise** | disguise_clothing_system_design.md | ◉ Designed |
| **Puzzles** | puzzle_system_design.md | ◉ Designed |
| **Jobs/Work** | job_work_quest_system_design.md | ◉ Designed |
| **Living World** | living_world_event_system_mvp.md & full.md | ◉ Designed |
| **Transportation** | tram_transportation_system_design.md | ◉ Designed |
| **Morning Report** | morning_report_manager_design.md | ◉ Designed |
| **Trading Floor** | trading_floor_minigame_system_design.md | ◉ Designed |
| **Crime/Security** | crime_security_event_system_design.md | ◉ Designed |
| **Multiple Endings** | multiple_endings_system_design.md | ◉ Designed |
| **Visual Systems** | sprite_perspective_scaling, foreground_occlusion | ◉ Designed |

## Detailed Integration Points

### 1. Save System Integration Points

**Design Status:** ✓ Complete (save_system_design.md, modular_serialization_architecture.md)

**Dependencies:**
- → Sleep: Saves only occur during sleep
- → All Systems: Collects serialized data via self-registration pattern

**Design Features:**
- ◉ Modular serialization with self-registering systems
- ◉ Compressed save files
- ◉ Integration with PromptNotificationSystem planned
- ◉ Audio feedback integration designed
- ◉ MorningReportManager integration

### 2. Sleep System Integration Points

**Dependencies:**
- → Save: Triggers save operation
- → Time: Advances time to morning
- ↔ Assimilation: Processes overnight spread
- ↔ Coalition: Executes overnight missions
- ↔ Economy: Handles rent, overnight costs
- ↔ Detection: Reduces heat level
- ↔ Quest: Checks time-sensitive quests

**Issues:**
- ! Custom warning dialogs (should use PromptNotificationSystem)
- ✗ No audio cues for sleep warnings or wake events

### 3. Assimilation System Integration Points

**Dependencies:**
- → NPC: Marks NPCs as assimilated
- → District: Affects district safety levels
- ↔ Coalition: Impacts coalition strength
- ↔ Economy: Economic warfare mechanics
- ↔ Detection: Increases surveillance
- ↔ Quest: Triggers assimilation-related quests

**Issues:**
- ✗ No audio response to assimilation events
- ○ Uses PromptNotificationSystem indirectly through MorningReportManager

### 4. Coalition System Integration Points

**Dependencies:**
- → NPC: Recruits and manages coalition members
- → District: Establishes safe houses
- → Dialog: Special dialog options for members
- ↔ Assimilation: Fights spread
- ↔ Economy: Funding and resources
- ↔ Detection: Underground operations
- ↔ Quest: Coalition missions

**Issues:**
- ✗ No audio for coalition activities
- ○ Limited notification integration

### 5. Economy System Integration Points

**Dependencies:**
- → District: Shop locations and prices
- → PromptNotificationSystem: Transaction confirmations
- ↔ Sleep: Rent payments, overnight costs
- ↔ Assimilation: Market disruption
- ↔ Coalition: Funding operations
- ↔ Quest: Job quests, economic goals

**Issues:**
- ✗ No audio feedback for transactions
- Good integration with notifications

### 6. Detection System Integration Points

**Dependencies:**
- → NPC: Alerts security NPCs
- → District: Lockdown mechanics
- → Dialog: Confrontation dialogs
- → PromptNotificationSystem: Alerts and warnings
- ↔ Sleep: Heat decay overnight
- ↔ Assimilation: Increased surveillance
- ↔ Coalition: Avoiding detection
- ↔ Quest: Stealth missions

**Issues:**
- ✗ No audio alerts for detection states
- Good notification integration

### 7. Audio System Integration Points

**Design Status:** ✓ Complete (audio_system_iteration3_mvp.md, audio_system_technical_implementation.md)

**Designed Features:**
- → District: Diegetic audio sources with spatial positioning
- → Time: Time-based audio changes
- ◉ Event-driven audio system architecture
- ◉ DiegeticAudioController for in-world sounds
- ◉ Integration with perspective scaling system
- ◉ Audio bus hierarchy for different sound types

**Planned Integrations:**
- ◉ Save: Success/failure feedback sounds
- ◉ Sleep: Sleep/wake audio transitions
- ◉ Assimilation: Environmental audio changes
- ◉ Coalition: Mission briefing audio
- ◉ Economy: Transaction confirmation sounds
- ◉ Detection: Alert escalation audio
- ◉ Quest: Completion fanfares
- ◉ NPC: Dialog UI sounds
- ◉ Prompt: Notification audio cues

### 8. PromptNotificationSystem Integration Points

**Current Integrations:**
- ← Audio: Should provide audio cues
- → Dialog: Being integrated for UI consistency
- Used by: Economy, Detection, partially by Sleep/Save

**Needed Integrations:**
- Full integration with Sleep warnings
- Full integration with Save confirmations
- MorningReportManager integration
- Audio cue support

### 9. Time Management System Integration Points

**Dependencies:**
- Provides time to all systems
- ← Sleep: Time advancement
- ← All Systems: Time-based events

**Good Integration:**
- Central time authority
- Well-integrated across systems

### 10. District System Integration Points

**Dependencies:**
- Provides locations for all systems
- ← All Systems: Location-based events

**Good Integration:**
- Foundation for spatial systems
- Well-integrated

## Key Integration Patterns

### 1. Serialization Pattern
All stateful systems must self-register their serializers:
```
System → Serializer → SaveManager
```

### 2. Overnight Processing Pattern
```
Sleep → Time → [Assimilation, Coalition, Economy, Quest] → MorningReportManager → PromptNotificationSystem
```

### 3. Notification Pattern
```
System Event → PromptNotificationSystem → Display (with optional Audio)
```

### 4. Detection Escalation Pattern
```
Player Action → Detection → NPC Alert → Dialog/Confrontation → Game Over
```

## Identified Issues and Solutions

### 1. Audio System Isolation
**Problem:** Audio system has no integration with game events
**Solution:** 
- Create AudioEventBridge that subscribes to system events
- Add audio_cue parameter to PromptNotificationSystem
- Implement reactive audio for all major events

### 2. UI/Dialog Redundancy
**Problem:** Multiple systems implement custom dialogs
**Solution:**
- Migrate all to PromptNotificationSystem
- Implement MorningReportManager for consolidated reports
- Future: Add multi-choice support to prompt system

### 3. Missing Event Feedback
**Problem:** Many system interactions lack feedback
**Solution:**
- Standardize event emission from all systems
- Create EventFeedbackManager to ensure all events have audio/visual response

### 4. Serialization Inconsistency
**Problem:** Not all systems follow self-registration pattern
**Solution:**
- Update all stateful systems to self-register
- Remove centralized registration from SaveManager
- Document pattern in each system

## Integration Priority Recommendations

### High Priority
1. Complete PromptNotificationSystem integration across all systems
2. Implement AudioEventBridge for system event audio
3. Finish MorningReportManager integration
4. Standardize serialization self-registration

### Medium Priority
1. Add audio cues to all user actions
2. Create comprehensive event feedback system
3. Implement detection audio alerts
4. Add save/load audio feedback

### Low Priority
1. Enhance ambient audio based on game state
2. Add audio variations for different districts
3. Implement dynamic audio based on assimilation level

## System Dependency Order

For initialization and processing, systems should be initialized in this order:

1. **Core Infrastructure**
   - ServiceRegistry
   - SaveManager
   - TimeManager
   - PromptNotificationSystem

2. **Foundation Systems**
   - DistrictManager
   - AudioManager
   - NPCManager

3. **Game Systems**
   - EconomyManager
   - AssimilationManager
   - DetectionManager
   - QuestManager
   - CoalitionManager

4. **Interaction Systems**
   - DialogManager
   - SleepManager

5. **Utility Systems**
   - MorningReportManager
   - DebugManager

## Conclusion

The updated integration matrix reveals that the Phase 1-2 design sprint (May 24-26, 2025) has comprehensively addressed what were initially perceived as integration gaps:

1. **Audio System**: Fully designed with event-driven architecture and integration points for all systems
2. **UI/Notification**: PromptNotificationSystem and MorningReportManager designs provide consistency
3. **Feedback Systems**: Audio and visual feedback patterns established for all player actions
4. **Additional Systems**: 14+ new systems designed that weren't in the original matrix

The challenge has shifted from design to implementation prioritization. All major systems have been thoughtfully designed with clear integration points, patterns, and dependencies. The game architecture is remarkably complete at the design level.