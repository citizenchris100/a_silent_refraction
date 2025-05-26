# Investigation/Clue Tracking System Design Document

## Overview

The Investigation/Clue Tracking System extends the Quest Log UI to automatically collect, organize, and present discovered information as a cohesive narrative. When players find important evidence during investigation quests, the system prompts them to acknowledge the discovery and stores it for later review within the quest interface, building a complete picture of the conspiracy.

## Core Design Principles

### Seamless Quest Integration
- Clues are quest-specific discoveries, not a separate system
- All clue viewing happens within the Quest Log UI
- Investigation progress drives NPC reactions and dialog options
- Evidence forms a narrative when viewed together

### Player Agency
- Players must actively participate in investigation quests
- Clues are explicitly discovered through gameplay actions
- Prompt system ensures players notice important finds
- Evidence can be reviewed anytime through quest interface

## System Architecture

### Component Structure

```gdscript
# src/core/systems/investigation_clue_system.gd
extends Node

class_name InvestigationClueSystem

signal clue_discovered(quest_id: String, clue_id: String)
signal narrative_updated(quest_id: String)
signal investigation_completed(quest_id: String)

# Clue data structure
class ClueData:
    var id: String = ""
    var quest_id: String = ""
    var name: String = ""
    var description: String = ""
    var full_text: String = ""
    var source_type: String = ""  # "document", "conversation", "observation", "physical"
    var source_npc: String = ""
    var found_location: String = ""
    var found_time: int = 0
    var found_day: int = 0
    var narrative_position: int = 0  # Order in the narrative
    var connections: Array = []  # Other clue IDs this relates to
    var trust_required: Dictionary = {}  # Trust levels needed to understand
    var reveals_npc_state: Dictionary = {}  # NPCs revealed as assimilated

# Storage per quest
var quest_clues: Dictionary = {}  # {quest_id: [ClueData]}
var quest_narratives: Dictionary = {}  # {quest_id: compiled narrative}
```

### Integration with Quest System

```gdscript
# Extension to QuestData structure in Quest Log
class InvestigationQuestData extends QuestData:
    var required_clues: Array = []  # Clue IDs needed to complete
    var optional_clues: Array = []  # Bonus clues for better understanding
    var clue_sources: Dictionary = {}  # Where to find each clue
    var narrative_threshold: int = 0  # Minimum clues for basic narrative
    var full_narrative_threshold: int = 0  # Clues for complete picture
```

## Clue Discovery Flow

### 1. Discovery Trigger

```gdscript
func discover_clue(quest_id: String, clue_id: String, context: Dictionary) -> void:
    var quest = QuestManager.get_quest(quest_id)
    if not quest or quest.status != "active":
        return
    
    var clue_def = get_clue_definition(quest_id, clue_id)
    if not clue_def:
        return
    
    # Check if already discovered
    if has_discovered_clue(quest_id, clue_id):
        return
    
    # Validate discovery conditions
    if not validate_discovery_conditions(clue_def, context):
        return
    
    # Create clue instance
    var clue = create_clue_instance(clue_def, context)
    
    # Show discovery prompt
    show_clue_prompt(clue)
    
    # Store clue
    store_clue(quest_id, clue)
    
    # Update quest progress
    QuestManager.update_objective_progress(quest_id, "investigate", 1)
    
    # Check for narrative updates
    update_narrative_if_ready(quest_id)
```

### 2. Discovery Prompt

```gdscript
func show_clue_prompt(clue: ClueData) -> void:
    var prompt_message = _format_clue_prompt(clue)
    
    # Use the centralized Prompt/Notification System
    PromptNotificationSystem.show_story(
        "clue_" + clue.id,
        prompt_message,
        "Evidence Discovered"
    )
    
    # Queue follow-up notification
    PromptNotificationSystem.show_info(
        "clue_stored_" + clue.id,
        "This information has been added to your quest log.\nView it anytime under: %s" % clue.quest_name,
        "Evidence Stored"
    )

func _format_clue_prompt(clue: ClueData) -> String:
    var message = ""
    
    match clue.source_type:
        "document":
            message = "You've found an important document:\n\n"
            message += "『%s』\n\n" % clue.name
            message += clue.full_text
        
        "conversation":
            message = "You overheard something significant:\n\n"
            message += "%s said:\n" % clue.source_npc
            message += '"%s"' % clue.full_text
        
        "observation":
            message = "You noticed something important:\n\n"
            message += clue.full_text
        
        "physical":
            message = "You discovered physical evidence:\n\n"
            message += "Item: %s\n" % clue.name
            message += clue.full_text
    
    return message
```

## Quest Log Integration

### Clue Display in Quest Details

```gdscript
# Addition to Quest Log UI display
func display_investigation_progress(quest: InvestigationQuestData):
    var clues = InvestigationClueSystem.get_quest_clues(quest.id)
    
    # Show discovery progress
    $ClueProgress.text = "Evidence Found: %d/%d" % [
        clues.size(),
        quest.required_clues.size()
    ]
    
    # Show optional clues if any found
    var optional_found = count_optional_clues_found(quest, clues)
    if optional_found > 0:
        $ClueProgress.text += " (+%d bonus)" % optional_found
    
    # Display narrative section if enough clues
    if clues.size() >= quest.narrative_threshold:
        $NarrativeSection.visible = true
        $NarrativeSection/Title.text = "Investigation Summary"
        $NarrativeSection/Content.text = InvestigationClueSystem.get_narrative(quest.id)
        
        # Show completeness
        var completeness = calculate_narrative_completeness(quest, clues)
        $NarrativeSection/Completeness.text = "Understanding: %d%%" % completeness
    else:
        $NarrativeSection.visible = false
        $ClueHint.text = "Gather more evidence to form conclusions"
    
    # List individual clues
    $ClueList.clear()
    for clue in clues:
        add_clue_to_list(clue)
```

### Narrative Construction

```gdscript
func update_narrative_if_ready(quest_id: String) -> void:
    var quest = QuestManager.get_quest(quest_id)
    var clues = get_quest_clues(quest_id)
    
    if clues.size() < quest.narrative_threshold:
        return
    
    # Sort clues by narrative position
    clues.sort_custom(self, "_sort_by_narrative_position")
    
    # Build narrative
    var narrative = _construct_narrative(quest, clues)
    quest_narratives[quest_id] = narrative
    
    # Notify quest log to update
    emit_signal("narrative_updated", quest_id)
    
    # Check if investigation is complete
    if _is_investigation_complete(quest, clues):
        emit_signal("investigation_completed", quest_id)
        unlock_conclusion_dialogs(quest_id)

func _construct_narrative(quest: InvestigationQuestData, clues: Array) -> String:
    var narrative = ""
    var narrative_template = get_narrative_template(quest.id)
    
    # Group clues by topic
    var grouped = group_clues_by_connection(clues)
    
    # Build narrative sections
    for group in grouped:
        narrative += _build_narrative_section(group, narrative_template)
        narrative += "\n\n"
    
    # Add conclusions if all required clues found
    if has_all_required_clues(quest, clues):
        narrative += _build_conclusion_section(quest, clues)
    
    return narrative

func _build_narrative_section(clue_group: Array, template: Dictionary) -> String:
    var section = template.get(clue_group[0].narrative_position, "")
    
    # Replace placeholders with clue content
    for clue in clue_group:
        var placeholder = "{%s}" % clue.id
        if section.find(placeholder) != -1:
            section = section.replace(placeholder, clue.description)
    
    return section
```

## NPC Integration

### Dialog Unlocking

```gdscript
func unlock_conclusion_dialogs(quest_id: String) -> void:
    var quest = QuestManager.get_quest(quest_id)
    var clues = get_quest_clues(quest_id)
    
    # Update NPC dialog trees based on discovered evidence
    for npc_id in quest.involved_npcs:
        var npc = NPCManager.get_npc(npc_id)
        if not npc:
            continue
        
        # Check which dialog branches to unlock
        for clue in clues:
            if clue.reveals_npc_state.has(npc_id):
                npc.unlock_dialog_branch("confrontation_" + clue.id)
            
            if clue.connections.has(npc_id):
                npc.unlock_dialog_branch("evidence_" + clue.id)
    
    # Special handling for coalition members
    if quest.coalition_investigation:
        CoalitionManager.update_intel_sharing(quest_id, clues)
```

### Trust-Based Revelations

```gdscript
func validate_discovery_conditions(clue_def: Dictionary, context: Dictionary) -> bool:
    # Check trust requirements
    if clue_def.has("trust_required"):
        for npc_id in clue_def.trust_required:
            var required_trust = clue_def.trust_required[npc_id]
            var current_trust = NPCTrustManager.get_trust_dimensions(npc_id)
            
            for dimension in required_trust:
                if current_trust.get(dimension, 0) < required_trust[dimension]:
                    return false
    
    # Check location requirements
    if clue_def.has("location_required"):
        if context.get("current_location", "") != clue_def.location_required:
            return false
    
    # Check disguise requirements
    if clue_def.has("disguise_required"):
        if DisguiseManager.current_role != clue_def.disguise_required:
            return false
    
    return true
```

## Clue Types and Sources

### Document Clues
```gdscript
# Found in file cabinets, computers, desks
func examine_document(object: InteractiveObject) -> void:
    if object.has_clue and object.quest_id != "":
        var context = {
            "current_location": GameManager.current_room,
            "examining_object": object.name,
            "time_of_day": TimeManager.current_time
        }
        InvestigationClueSystem.discover_clue(
            object.quest_id,
            object.clue_id,
            context
        )
```

### Conversation Clues
```gdscript
# Overheard or obtained through dialog
func process_dialog_choice(npc: BaseNPC, choice: DialogChoice) -> void:
    # Normal dialog processing...
    
    # Check if choice reveals clue
    if choice.has("reveals_clue"):
        var context = {
            "source_npc": npc.id,
            "trust_level": NPCTrustManager.get_total_trust(npc.id),
            "dialog_branch": choice.branch_id
        }
        InvestigationClueSystem.discover_clue(
            choice.quest_id,
            choice.reveals_clue,
            context
        )
```

### Observation Clues
```gdscript
# Environmental observations
func observe_scene_detail(detail_id: String) -> void:
    var active_investigations = QuestManager.get_active_investigations()
    
    for quest in active_investigations:
        if quest.observation_clues.has(detail_id):
            var context = {
                "observation_type": "environmental",
                "detail_id": detail_id,
                "observer_disguise": DisguiseManager.current_role
            }
            InvestigationClueSystem.discover_clue(
                quest.id,
                detail_id,
                context
            )
```

### Physical Evidence
```gdscript
# Items that serve as clues
func pickup_item(item: ItemData) -> void:
    # Normal item pickup...
    
    if item.is_evidence:
        for quest_id in item.evidence_for_quests:
            var context = {
                "item_id": item.id,
                "found_location": GameManager.current_room,
                "container": item.found_in_container
            }
            InvestigationClueSystem.discover_clue(
                quest_id,
                item.clue_id,
                context
            )
```

## Serialization

```gdscript
# src/core/serializers/investigation_serializer.gd
extends BaseSerializer

class_name InvestigationSerializer

func get_serializer_id() -> String:
    return "investigation_system"

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("investigation_system", self, 45)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "quest_clues": _serialize_all_clues(),
        "quest_narratives": InvestigationClueSystem.quest_narratives,
        "unlocked_dialogs": _serialize_unlocked_dialogs(),
        "investigation_flags": InvestigationClueSystem.investigation_flags
    }

func deserialize(data: Dictionary) -> void:
    if "quest_clues" in data:
        _deserialize_all_clues(data.quest_clues)
    
    if "quest_narratives" in data:
        InvestigationClueSystem.quest_narratives = data.quest_narratives
    
    if "unlocked_dialogs" in data:
        _deserialize_unlocked_dialogs(data.unlocked_dialogs)
    
    if "investigation_flags" in data:
        InvestigationClueSystem.investigation_flags = data.investigation_flags

func _serialize_all_clues() -> Dictionary:
    var serialized = {}
    
    for quest_id in InvestigationClueSystem.quest_clues:
        serialized[quest_id] = []
        for clue in InvestigationClueSystem.quest_clues[quest_id]:
            serialized[quest_id].append({
                "id": clue.id,
                "found_time": clue.found_time,
                "found_day": clue.found_day,
                "source_npc": clue.source_npc,
                "found_location": clue.found_location
            })
    
    return serialized
```

## Example Investigation Quest

```gdscript
# Missing Personnel Investigation
var investigation_quest = {
    "id": "missing_personnel",
    "name": "Where Have They Gone?",
    "category": "investigation",
    "type": "InvestigationQuestData",
    
    # Clue requirements
    "required_clues": [
        "personnel_transfer_log",
        "janitor_testimony",
        "medical_inconsistency",
        "security_footage_gap"
    ],
    
    "optional_clues": [
        "suspicious_schedule_change",
        "overheard_conversation",
        "disposal_manifest"
    ],
    
    # Narrative thresholds
    "narrative_threshold": 3,  # Basic understanding
    "full_narrative_threshold": 6,  # Complete picture
    
    # Clue definitions
    "clue_definitions": {
        "personnel_transfer_log": {
            "name": "Personnel Transfer Records",
            "source_type": "document",
            "location": "hr_office_cabinet",
            "full_text": "Multiple personnel transferred to 'Special Project Lambda' in Engineering. No return dates listed. Signatures appear rushed and inconsistent.",
            "narrative_position": 1,
            "reveals_pattern": true
        },
        
        "janitor_testimony": {
            "name": "Janitor's Story",
            "source_type": "conversation",
            "source_npc": "janitor_kim",
            "trust_required": {"janitor_kim": {"personal": 40}},
            "full_text": "I seen 'em go down to Engineering late at night. Groups of three or four. Never seen 'em come back up. Management says they transferred, but their lockers still got stuff in 'em.",
            "narrative_position": 2,
            "connections": ["personnel_transfer_log"]
        },
        
        "medical_inconsistency": {
            "name": "Medical Records Anomaly",
            "source_type": "document",
            "location": "medical_computer",
            "disguise_required": "medical_staff",
            "full_text": "Pre-transfer medical exams show unusual brain activity patterns. Post-transfer records missing. Dr. Martinez's notes mention 'concerning neurological changes' before her own transfer.",
            "narrative_position": 3,
            "reveals_npc_state": {"dr_martinez": "missing"}
        }
    },
    
    # Narrative template
    "narrative_template": {
        1: "Personnel records show an unusual pattern of transfers to Engineering's 'Special Project Lambda.' {personnel_transfer_log}",
        2: "Witness accounts suggest these transfers may not be voluntary. {janitor_testimony}",
        3: "Medical evidence points to something affecting the transferred personnel before they disappeared. {medical_inconsistency}",
        "conclusion": "The evidence strongly suggests that missing personnel are being taken to Engineering after showing signs of assimilation. The cover story of 'transfers' is being used to hide the true nature of their disappearance."
    }
}
```

## Investigation Mechanics

### Clue Connections
```gdscript
func analyze_clue_connections(quest_id: String) -> Dictionary:
    var clues = get_quest_clues(quest_id)
    var connections = {}
    
    for clue in clues:
        for connected_id in clue.connections:
            if has_discovered_clue(quest_id, connected_id):
                if not connections.has(clue.id):
                    connections[clue.id] = []
                connections[clue.id].append(connected_id)
    
    return connections
```

### Progressive Understanding
```gdscript
func calculate_narrative_completeness(quest: InvestigationQuestData, clues: Array) -> int:
    var required_found = 0
    var optional_found = 0
    
    for clue in clues:
        if quest.required_clues.has(clue.id):
            required_found += 1
        elif quest.optional_clues.has(clue.id):
            optional_found += 1
    
    var required_percent = (required_found * 70) / quest.required_clues.size()
    var optional_percent = (optional_found * 30) / max(1, quest.optional_clues.size())
    
    return required_percent + optional_percent
```

## Coalition Integration

### Intel Sharing
```gdscript
func share_investigation_with_coalition(quest_id: String) -> void:
    var clues = get_quest_clues(quest_id)
    var narrative = quest_narratives.get(quest_id, "")
    
    if narrative == "":
        PromptNotificationSystem.show_warning(
            "insufficient_intel",
            "You need more evidence before sharing with the Coalition.",
            "Insufficient Intel"
        )
        return
    
    # Share with coalition
    CoalitionManager.add_shared_intel(quest_id, narrative, clues)
    
    # Boost trust with key members
    var trust_boost = calculate_intel_value(clues)
    CoalitionManager.boost_network_trust("ideological", trust_boost)
    
    PromptNotificationSystem.show_confirm(
        "intel_shared",
        "Intelligence shared with Coalition network.\nTrust increased by %d points." % trust_boost,
        "Intel Shared"
    )
```

## Performance Considerations

1. **Lazy Loading**
   - Load clue definitions on quest activation
   - Cache narrative templates
   - Only process active investigations

2. **Memory Management**
   - Limit stored clues to 100 per quest
   - Compress old investigation data
   - Clear completed investigation details after 30 game days

## Testing Scenarios

1. **Clue Discovery Flow**
   - Test all clue types discovery
   - Verify prompt display
   - Check quest log integration

2. **Narrative Building**
   - Test with minimum clues
   - Test with all clues
   - Verify narrative coherence

3. **Save/Load**
   - Save mid-investigation
   - Load and continue
   - Verify narrative preservation

## Template Compliance

### Interactive Object Template Integration
Clue objects follow `template_interactive_object_design.md`:
- All clues are interactive objects with standard verb interactions
- EXAMINE verb reveals clue details and triggers discovery
- USE verb may reveal additional information with proper tools
- State tracking for discovered/undiscovered clues
- Visual feedback changes after discovery

### Quest Template Integration  
Investigation quests follow `template_quest_design.md`:
- Uses modular quest structure with clue collection objectives
- Dynamic objective updates as clues are discovered
- Branching paths based on evidence found
- Time-sensitive clues that may disappear
- Quest completion varies based on evidence quality

## Implementation Notes

The Investigation/Clue Tracking System enhances investigation quests by:
1. Providing clear feedback when evidence is discovered
2. Storing clues within the quest context for easy review
3. Building coherent narratives from collected evidence
4. Driving NPC reactions based on investigation progress
5. Integrating with Coalition for intel sharing
6. Supporting multiple investigation threads simultaneously

The system maintains simplicity by treating clues as quest-specific data rather than a global system, ensuring investigations feel purposeful and connected to their narrative context.