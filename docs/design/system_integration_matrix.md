# System Integration Matrix

## Overview

This document provides a comprehensive matrix of how all game systems interact with each other in "A Silent Refraction". It identifies touchpoints, dependencies, data flows, and potential areas of redundancy or missing integration.

## Integration Matrix

### Legend
- **→** Direct dependency (System A depends on System B)
- **↔** Bidirectional interaction (Systems exchange data/events)
- **○** Indirect relationship (through shared system)
- **✗** No current integration (but should have)
- **!** Redundancy identified

## System-to-System Relationships

| From ↓ / To → | Save | Sleep | Assimilation | Coalition | Economy | Detection | Quest | NPC | Dialog | Audio | Prompt | Time | District |
|----------------|------|-------|--------------|-----------|---------|-----------|-------|-----|--------|-------|--------|------|----------|
| **Save**       | -    | →     | →            | →         | →       | →         | →     | →   | →      | ✗     | !      | →    | →        |
| **Sleep**      | →    | -     | ↔            | ↔         | ↔       | ↔         | ↔     | ○   | ○      | ✗     | !      | →    | ○        |
| **Assimilation** | ←  | ↔     | -            | ↔         | ↔       | ↔         | ↔     | →   | ○      | ✗     | ○      | →    | →        |
| **Coalition**  | ←    | ↔     | ↔            | -         | ↔       | ↔         | ↔     | →   | →      | ✗     | ○      | →    | →        |
| **Economy**    | ←    | ↔     | ↔            | ↔         | -       | ○         | ↔     | ○   | ○      | ✗     | →      | →    | →        |
| **Detection**  | ←    | ↔     | ↔            | ↔         | ○       | -         | ↔     | →   | →      | ✗     | →      | →    | →        |
| **Quest**      | ←    | ↔     | ↔            | ↔         | ↔       | ↔         | -     | →   | →      | ✗     | ○      | →    | →        |
| **NPC**        | ←    | ○     | ←            | ←         | ○       | ←         | ←     | -   | →      | ✗     | ○      | →    | →        |
| **Dialog**     | ←    | ○     | ○            | ←         | ○       | ←         | ←     | ←   | -      | ✗     | !      | ○    | ○        |
| **Audio**      | ✗    | ✗     | ✗            | ✗         | ✗       | ✗         | ✗     | ✗   | ✗      | -     | ✗      | ○    | →        |
| **Prompt**     | ○    | →     | ○            | ○         | →       | →         | ○     | ○   | →      | ←     | -      | ○    | ○        |
| **Time**       | ←    | ←     | ←            | ←         | ←       | ←         | ←     | ←   | ○      | ○     | ○      | -    | ○        |
| **District**   | ←    | ○     | ←            | ←         | ←       | ←         | ←     | ←   | ○      | ←     | ○      | ○    | -        |

## Detailed Integration Points

### 1. Save System Integration Points

**Dependencies:**
- → Sleep: Saves only occur during sleep
- → All Systems: Collects serialized data from all stateful systems

**Issues:**
- ! Custom UI dialogs (should use PromptNotificationSystem)
- ✗ No audio feedback for save success/failure

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

**Current State:**
- → District: Basic ambient sounds
- ○ Time: Could respond to time of day
- Operates too independently

**Missing Integrations:**
- ✗ Save: No save success/failure sounds
- ✗ Sleep: No sleep/wake audio cues
- ✗ Assimilation: No spread audio effects
- ✗ Coalition: No mission audio
- ✗ Economy: No transaction sounds
- ✗ Detection: No alert sounds
- ✗ Quest: No completion sounds
- ✗ NPC: No dialog audio cues
- ✗ Dialog: No UI sounds
- ✗ Prompt: No notification sounds

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

This integration matrix reveals that while most game systems have good logical integration, there are significant gaps in:
1. Audio system integration with game events
2. UI/notification consistency
3. Feedback for player actions

Addressing these gaps will significantly improve the player experience and make the game world feel more cohesive and reactive.