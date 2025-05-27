# Design Document to Iteration Mapping
**Created:** May 27, 2025
**Purpose:** Comprehensive mapping of all design documents to their implementation iterations

## Overview

This document provides a complete mapping of all design documents in `docs/design/` to their corresponding iteration plans. The project follows a three-phase development approach:
- **Phase 1 (Iterations 1-8):** MVP Systems and Foundational Content  
- **Phase 2 (Iterations 9-16):** Full Systems Development
- **Phase 3 (Iterations 17-22):** Full Content Implementation

## Design Document Mapping by Phase

### Phase 1: MVP Systems (Iterations 1-8)

| Design Document | Iteration | Status | Notes |
|----------------|-----------|---------|-------|
| `audio_system_iteration3_mvp.md` | 3 | Mapped | MVP audio implementation |
| `audio_system_technical_implementation.md` | 3 | Mapped | Technical implementation details |
| `barracks_system_design.md` | 7 | Mapped | Basic barracks for save/sleep |
| `character_gender_selection_system.md` | 3, 6 | Mapped | Character creation and mechanics |
| `dialog_system_refactoring_plan.md` | 6 | Mapped | Dialog system refactoring |
| `economy_system_design.md` | 7 | Mapped | Basic economy implementation |
| `foreground_occlusion_mvp_plan.md` | 3 | Mapped | MVP occlusion system |
| `inventory_system_design.md` | 7 | Mapped | Basic inventory system |
| `inventory_ui_design.md` | 7 | Mapped | Inventory UI implementation |
| `living_world_event_system_mvp.md` | 8 | Mapped | MVP living world events |
| `main_menu_start_game_ui_design.md` | 6 | Mapped | Main menu UI |
| `modular_serialization_architecture.md` | 4 | Mapped | Serialization architecture |
| `morning_report_manager_design.md` | 7 | Mapped | Morning report system |
| `multi_perspective_character_system_plan.md` | 3 | Mapped | Character perspective system |
| `point_and_click_navigation_refactoring_plan.md` | 3 | Mapped | Navigation refactoring |
| `prompt_notification_system_design.md` | 5 | Mapped | Notification system |
| `save_system_design.md` | 7 | Mapped | Save system implementation |
| `scumm_hover_text_system_design.md` | 8 | Mapped | SCUMM-style hover text |
| `serialization_system.md` | 4 | Mapped | Core serialization |
| `sleep_system_design.md` | 7 | Mapped | Sleep mechanics |
| `sprite_perspective_scaling_plan.md` | 3 | Mapped | MVP sprite scaling |
| `template_dialog_design.md` | 6 | Mapped | Dialog templates |
| `template_district_design.md` | 8 | Mapped | District templates |
| `template_integration_standards.md` | 3, 6, 8 | Mapped | Integration standards |
| `template_interactive_object_design.md` | 8 | Mapped | Interactive object templates |
| `template_npc_design.md` | 8 | Mapped | NPC templates |
| `time_calendar_display_ui_design.md` | 5, 8 | Mapped | Time display UI |
| `time_management_system_mvp.md` | 5, 7 | Mapped | MVP time system |
| `tram_transportation_system_design.md` | 8 | Mapped | Basic tram system |
| `verb_ui_system_refactoring_plan.md` | 6 | Mapped | Verb UI refactoring |

### Phase 2: Full Systems (Iterations 9-16)

| Design Document | Iteration | Status | Notes |
|----------------|-----------|---------|-------|
| `assimilation_system_design.md` | 12 | Mapped | Full assimilation mechanics |
| `coalition_resistance_system_design.md` | 12 | Mapped | Coalition system |
| `crime_security_event_system_design.md` | 12 | Mapped | Crime/security events |
| `detection_game_over_system_design.md` | 9 | Mapped | Detection and game over |
| `disguise_clothing_system_design.md` | 10 | Mapped | Disguise mechanics |
| `district_access_control_system_design.md` | 9 | Mapped | District access control |
| `foreground_occlusion_full_plan.md` | 14, 16 | Mapped | Full occlusion system |
| `investigation_clue_tracking_system_design.md` | 9, 15 | Mapped | Investigation system |
| `job_work_quest_system_design.md` | 11 | Mapped | Job/work quest system |
| `living_world_event_system_full.md` | 12, 15 | Mapped | Full living world |
| `multiple_endings_system_design.md` | 12 | Mapped | Multiple endings |
| `npc_trust_relationship_system_design.md` | 10 | Mapped | NPC trust system |
| `observation_system_full_design.md` | 9, 15 | Mapped | Full observation system |
| `performance_optimization_plan.md` | 15 | Mapped | Performance optimization |
| `puzzle_system_design.md` | 15 | Mapped | Puzzle mechanics |
| `quest_log_ui_design.md` | 11 | Mapped | Quest log UI |
| `sprite_perspective_scaling_full_plan.md` | 14, 16 | Mapped | Full sprite scaling |
| `suspicion_system_full_design.md` | 9 | Mapped | Full suspicion system |
| `template_quest_design.md` | 11 | Mapped | Quest templates |
| `time_management_system_full.md` | 7 | Mapped | Full time system |
| `trading_floor_minigame_system_design.md` | 11 | Mapped | Trading minigame |

### Phase 3: Content Implementation (Iterations 17-22)

| Design Document | Iteration | Status | Notes |
|----------------|-----------|---------|-------|
| `phase3_content_implementation_roadmap.md` | 17-22 | Mapped | Master content roadmap |

### Unmapped Design Documents

| Design Document | Suggested Iteration | Reason |
|----------------|-------------------|---------|
| `hardware_validation_plan.md` | N/A | Testing/validation document, not a system |

## Key Findings

1. **Excellent Coverage**: 50 out of 51 design documents are properly mapped to iterations
2. **Phased Approach Working**: Clear progression from MVP → Full Systems → Content
3. **Template Pattern**: Templates established in Phase 1 are used throughout development
4. **Integration Points**: Systems designed to work together are implemented in logical groups

## Recommendations

1. **Phase 1 Status**: All MVP systems are properly mapped and ready for implementation
2. **Phase 2 Status**: All full system implementations are properly scheduled
3. **Phase 3 Status**: Content implementation follows the roadmap document
4. **No Major Gaps**: All critical systems have implementation tasks assigned

## Usage Notes

- This mapping should be referenced when starting each iteration
- Design documents should be reviewed before implementation begins
- Any new design documents should be added to this mapping
- Phase boundaries are guidelines; some overlap is expected and acceptable