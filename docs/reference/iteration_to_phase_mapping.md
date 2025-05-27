# Iteration to Phase Mapping
**Status: 📋 DESIGN**  
**Created: May 26, 2025**  
**Last Updated: May 26, 2025**

## Overview

This document maps iterations to their respective development phases, ensuring proper dependency sequencing for solo Kanban development. Each iteration builds on the previous, respecting system dependencies.

**Key Principle**: The number of iterations is flexible and can expand as needed. Each iteration should accomplish a cohesive goal that can be completed and tested independently.

## Phase 1: MVP Foundation (Iterations 1-8)
*Goal: Minimum viable systems to validate core gameplay*
*Validation: Intro Quest playable with all MVP systems*

### ✅ Iteration 1: Basic Environment Setup
**Status**: COMPLETE (100%)
- Basic Godot project structure
- Walking test scene
- Camera system fundamentals

### ✅ Iteration 2: NPC Framework
**Status**: IN PROGRESS (83%)
- Basic NPC interactions
- State machine implementation
- Simple dialog foundation

### ✅ Iteration 3: Navigation System Refactoring
**Status**: PLANNED
- Point-and-click navigation
- Walkable area system
- Camera bounds improvements

### 🔄 Iteration 4: Serialization Foundation
**Phase**: 1 - MVP Foundation  
**Dependencies**: Base classes (I2)
**Cohesive Goal**: "I can save and load game state"
**Systems**:
1. **Modular Serialization Architecture**
2. **Basic save/load testing framework**
3. **Serialization documentation**

### 🔄 Iteration 5: Time and Notification Systems  
**Phase**: 1 - MVP Foundation  
**Dependencies**: Serialization (I4)
**Cohesive Goal**: "Time flows and the game can communicate with the player"
**Systems**:
1. **Time Management System MVP**
2. **Prompt Notification System** 
3. **Basic calendar/clock UI**

### 🔄 Iteration 6: Dialog and Character Systems
**Phase**: 1 - MVP Foundation  
**Dependencies**: Time System (I5), Prompt Notifications (I5), Serialization (I4)
**Cohesive Goal**: "I can create my character and interact through dialog"
**Systems**:
1. **Character Gender Selection** 
2. **Dialog System Refactoring** (gender-aware)
3. **Verb UI System**
4. **Main Menu/Start Game UI**

### 🔄 Iteration 7: Economy and Save/Sleep
**Phase**: 1 - MVP Foundation  
**Dependencies**: Time System (I5), Prompt System (I5), Dialog (I6)
**Cohesive Goal**: "I can sleep, save my progress, and manage resources"
**Systems**:
1. **Economy System** (basic implementation)
2. **Save/Sleep Unified System** (circular dependency - implement together)
3. **Morning Report Manager**
4. **Barracks District** (player quarters)
5. **Inventory System** (basic implementation)
6. **Inventory UI Design**

### 🔄 Iteration 8: Districts and Living World MVP
**Phase**: 1 - MVP Foundation  
**Dependencies**: Save System (I7), Time System (I5), NPCs (I2)
**Cohesive Goal**: "I can explore districts with living NPCs and complete the Intro Quest"
**Systems**:
1. **District Template System**
2. **Spaceport District** (starting area)
3. **Engineering District** (for Intro Quest)
4. **Living World Event System MVP**
5. **SCUMM Hover Text System** (basic implementation)
6. **Time Calendar Display UI**

## Phase 2: Full Systems (Iterations 9+)
*Goal: Complete all game systems to full specification*
*Validation: First Quest exercises all major systems*
*Note: Number of iterations flexible based on system complexity*

### 🔄 Iteration 9: Core Gameplay Systems
**Phase**: 2 - Full Systems  
**Dependencies**: All Phase 1 systems
**Cohesive Goal**: "I can observe, investigate, and be detected"
**Systems**:
1. **Observation System** (full implementation)
2. **Suspicion/Detection System** (full implementation)
3. **Detection Game Over System**
4. **Interactive Object Templates**
5. **Investigation Clue Tracking System**
6. **District Access Control System**

### 🔄 Iteration 10: Advanced NPC Systems
**Phase**: 2 - Full Systems  
**Dependencies**: Living World (I8), Observation (I9)
**Cohesive Goal**: "NPCs have routines, relationships, and can be disguised as"
**Systems**:
1. **NPC Trust/Relationship System**
2. **Full NPC Templates** (with all behaviors)
3. **NPC Daily Routines** (full implementation)
4. **Disguise System**

### 🔄 Iteration 11: Quest and Progression Systems
**Phase**: 2 - Full Systems  
**Dependencies**: NPCs (I10), Investigation (I9)
**Cohesive Goal**: "I can accept, track, and complete quests"
**Systems**:
1. **Quest System Framework**
2. **Job/Work Quest System**
3. **Quest Log UI**
4. **First Quest Implementation** (Phase 2 validation)

### 🔄 Iteration 12: Assimilation and Coalition
**Phase**: 2 - Full Systems  
**Dependencies**: Quest System (I11), Trust System (I10)
**Cohesive Goal**: "The station reacts to assimilation with resistance and multiple endings"
**Systems**:
1. **Assimilation System**
2. **Coalition/Resistance System**
3. **Crime/Security Events**
4. **Multiple Endings Framework**

### 🔄 Iteration 13: Full Audio Integration
**Phase**: 2 - Full Systems  
**Dependencies**: All core systems for event hooks
**Cohesive Goal**: "The game sounds alive with reactive audio"
**Systems**:
1. **Audio Event Bridge**
2. **Diegetic Audio Implementation**
3. **District Ambiences**
4. **UI Audio Feedback**

### 🔄 Iteration 14: Visual Polish Systems
**Phase**: 2 - Full Systems  
**Dependencies**: Districts complete, NPCs complete
**Cohesive Goal**: "The game looks polished with perspective and occlusion"
**Systems**:
1. **Sprite Perspective Scaling** (full)
2. **Foreground Occlusion** (full)
3. **Animation Polish**
4. **Visual Effects**

### 🔄 Iteration 15: Advanced Features & Polish
**Phase**: 2 - Full Systems  
**Dependencies**: All core systems
**Cohesive Goal**: "All systems work together seamlessly and performantly"
**Systems**:
1. **Living World Events** (full)
2. **Investigation System** (full)
3. **Puzzle System Implementation**
4. **Transportation (Tram) System**
5. **Performance Optimization**

### 🔄 Iteration 16: Advanced Visual Systems
**Phase**: 2 - Full Systems  
**Dependencies**: Visual Polish (I14), Districts (I8)
**Cohesive Goal**: "Characters adapt to any perspective with advanced visual features"
**Systems**:
1. **Multi-Perspective Character System**
2. **Advanced Animation Systems**
3. **Shader Effects** (heat distortion, hologram, CRT)
4. **Environmental Visual Effects**

## Phase 3: Content Implementation (Iterations 17+)
*Goal: Create all game content using completed systems*
*Note: Number and scope of iterations determined by content volume*
*Principle: Each iteration should deliver playable content chunks*

### 🔄 Iteration 17: Remaining Districts
**Phase**: 3 - Content  
**Dependencies**: All systems complete
**Cohesive Goal**: "All districts are explorable with unique content"
**Content**:
1. **Security District** (full implementation)
2. **Medical District** (full implementation)
3. **Mall District** (full implementation)
4. **Trading Floor District** (full implementation)
5. **Trading Floor Minigame System**

### 🔄 Iteration 18: NPC Population Wave 1
**Phase**: 3 - Content  
**Dependencies**: All districts exist
**Content**:
1. Spaceport NPCs (20)
2. Security NPCs (20)
3. Medical NPCs (15)
4. Initial dialog trees

### 🔄 Iteration 19: NPC Population Wave 2
**Phase**: 3 - Content  
**Dependencies**: Wave 1 complete
**Content**:
1. Mall NPCs (30)
2. Trading Floor NPCs (25)
3. Barracks NPCs (25)
4. Engineering NPCs (15)

### 🔄 Iteration 20: Quest Content Wave 1
**Phase**: 3 - Content  
**Dependencies**: All NPCs exist
**Content**:
1. Main story quests
2. Job quests per district
3. Initial coalition missions

### 🔄 Iteration 21: Quest Content Wave 2
**Phase**: 3 - Content  
**Dependencies**: Wave 1 quests
**Content**:
1. Investigation quest chains
2. Side quests and personal stories
3. Hidden content and easter eggs

### 🔄 Iteration 22: Dialog and Polish
**Phase**: 3 - Content  
**Dependencies**: All content implemented
**Content**:
1. Complete dialog passes
2. Environmental storytelling
3. Final audio placement
4. Balance and tuning

### 🔄 Iteration 23: Final Polish and Ship
**Phase**: 3 - Content  
**Dependencies**: All content complete
**Tasks**:
1. Bug fixing
2. Performance optimization
3. Platform testing
4. Release preparation

## Key Principles

1. **Dependency Respect**: Each iteration only includes systems whose dependencies are met
2. **Solo Dev Focus**: One system at a time, completed before moving on
3. **Phase Boundaries**: 
   - Phase 1 ends when Intro Quest is playable
   - Phase 2 ends when First Quest validates all systems
   - Phase 3 ends when full game is shippable
4. **Iteration Flexibility**:
   - Iterations can be added as needed
   - Each iteration should have a cohesive goal
   - Complex systems may be split across multiple iterations
   - Simple systems may be combined in one iteration

## Critical Path Systems

These MUST be implemented in order:
1. Serialization Architecture (I4)
2. Time Management (I4) 
3. Save/Sleep System (I6)
4. Districts (I7)
5. NPCs with schedules (I7)

## Risk Mitigation

- **Circular Dependencies**: Save/Sleep implemented together in I6
- **Testing Gaps**: Each phase ends with validation quest
- **Scope Creep**: Phase boundaries are firm - no new systems in Phase 3

## Timeline Estimates

**Phase 1**: 8-10 weeks (Iterations 1-8)
- ~1-2 weeks per iteration for MVP systems
- Includes Intro Quest validation

**Phase 2**: 14-18 weeks (Iterations 9-16)  
- ~2-3 weeks per iteration for full systems
- 8 iterations covering all designed systems
- Includes First Quest validation

**Phase 3**: 16-24 weeks (Iterations 17+)
- Variable based on content volume
- ~1-2 weeks per content iteration
- Can parallelize some content creation

**Total**: 36-50 weeks (~9-12 months) for full game
*Note: Timeline is flexible and adjusts based on actual iteration count*

## Next Steps

1. Update all iteration plan files to match this mapping
2. Add epic descriptions and user stories to each iteration
3. Update iteration_planner.sh to match new structure
4. Begin work on Iteration 3 (Navigation)