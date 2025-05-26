# Quest Log UI Design Document

## Overview

The Quest Log UI provides players with a comprehensive view of their active objectives, completed tasks, and discovered information. Following SCUMM-style adventure game conventions while integrating deeply with all game systems to surface critical information about time constraints, economic costs, coalition implications, and assimilation threats.

## Core Design Principles

### SCUMM-Style Integration
- Accessible via hotkey (Q) or verb action
- Non-intrusive overlay that doesn't pause the game
- Classic adventure game aesthetic with modern usability
- Text-based with minimal graphics

### Information Hierarchy
- Active quests prominently displayed with system-relevant metadata
- Time-critical quests highlighted with countdown timers
- Economic implications (costs/rewards) clearly visible
- Coalition and trust impacts shown upfront
- Assimilation-related quests marked with special indicators

## UI Structure

### Main Quest Log Window
```
┌──────────────────────────────────────────────────────────────┐
│ QUEST LOG                          Day 12, 14:30      [X]   │
├──────────────────────────────────────────────────────────────┤
│ ┌─────────────┐ ┌──────────────────────────────────────────┐ │
│ │ Categories  │ │ Quest: Wolf in Sheep's Clothing           │ │
│ │             │ │ Status: In Progress  [!] Day 15 Deadline  │ │
│ │ > Active(7) │ │ Location: Security Office                  │ │
│ │   Critical  │ │ Travel Cost: 20 credits, 60 min           │ │
│ │   Coalition │ │                                            │ │
│ │   Infiltr.  │ │ Description:                               │ │
│ │   Personal  │ │ "Infiltrate security while disguised..."  │ │
│ │             │ │                                            │ │
│ │ Complete(12)│ │ Objectives:                                │ │
│ │ Failed (3)  │ │ • Obtain security uniform ✓                │ │
│ │             │ │ • Report for duty (14:00-22:00)            │ │
│ │ Assimilation│ │ • Access personnel files                   │ │
│ │   Monitor   │ │ • Maintain cover (Suspicion < 30%)        │ │
│ │   Ratio:42% │ │                                            │ │
│ └─────────────┘ │ Rewards: 500¢, +20 Marcus trust           │ │
│                 │ Risks: Detection → Game Over               │ │
│                 └──────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### Quest Categories

#### Active Quests
- **Critical**: Main story and time-sensitive objectives (affects ending)
- **Coalition**: Recruitment, trust-building, network expansion
- **Infiltration**: Disguise-based role-playing missions
- **Personal**: Individual NPC requests (affects trust dimensions)
- **Investigation**: Evidence gathering and mystery solving
- **Economic**: Money-making opportunities and resource management

#### Completed Quests
- Shows actual time/money spent vs estimated
- Displays trust changes and coalition growth
- Tracks assimilation impact
- Notes if completion opened new opportunities

#### Failed Quests
- Shows reason (time expired, detected, wrong choice, etc.)
- Indicates cascading failures (NPCs lost to assimilation)
- Displays permanent consequences
- Shows if retriable (with new costs/risks)

#### Assimilation Monitor
- Current station ratio (X% assimilated)
- Days until evaluation (for ending determination)
- Recently assimilated NPCs
- Critical thresholds and warnings

## Quest Information Display

### Essential Information
```gdscript
class QuestDisplay:
    var quest_name: String
    var status: String  # "Active", "Complete", "Failed"
    var category: String
    var time_limit: int  # Day number, -1 if no limit
    var time_of_day_limit: String  # "14:00-22:00" for shifts
    var description: String
    var objectives: Array  # of ObjectiveData
    var rewards: Dictionary  # Credits, items, trust gains
    var costs: Dictionary  # Travel costs, item requirements
    var giver_npc: String
    var location: String
    var districts_involved: Array  # For travel planning
    var required_items: Array  # Items needed to complete
    var required_disguise: String  # Specific role needed
    var suspicion_threshold: int  # Max allowed before failure
    var coalition_members_needed: Array  # Specific skills required
    var assimilation_risk: bool  # Quest involves assimilated NPCs
```

### Objective Tracking
```gdscript
class ObjectiveData:
    var description: String
    var completed: bool
    var optional: bool
    var progress: int  # For multi-step objectives
    var max_progress: int
    var hints: Array  # Unlocked through investigation
    var time_window: String  # "Night only", "Business hours"
    var location_requirement: String  # Where objective must be completed
    var detection_risk: float  # 0.0 to 1.0
```

## Integration with Game Systems

### Time Management System
```gdscript
func display_time_constraints(quest: QuestData):
    # Show days remaining
    if quest.time_limit > 0:
        var days_left = quest.time_limit - TimeManager.current_day
        $TimeLabel.text = "Deadline: Day %d (%d days)" % [quest.time_limit, days_left]
        if days_left <= 2:
            $TimeLabel.modulate = Color.red
    
    # Show time windows for objectives
    for obj in quest.objectives:
        if obj.time_window != "":
            obj.description += " [%s]" % obj.time_window
    
    # Calculate total time investment
    var total_time = calculate_quest_time(quest)
    $EstimatedTime.text = "Est. time: %d hours" % [total_time / 60]
```

### Economy System
```gdscript
func display_economic_impact(quest: QuestData):
    # Show all costs upfront
    var total_cost = 0
    $CostBreakdown.clear()
    
    # Travel costs
    for district in quest.districts_involved:
        var cost = TramSystem.calculate_cost(current_district, district)
        total_cost += cost
        $CostBreakdown.add_item("Travel to %s: %d¢" % [district, cost])
    
    # Item requirements
    for item_id in quest.required_items:
        if not InventoryManager.has_item(item_id):
            var price = EconomyManager.get_item_price(item_id)
            total_cost += price
            $CostBreakdown.add_item("Buy %s: %d¢" % [item_id, price])
    
    # Show if player can afford it
    var player_credits = EconomyManager.get_credits()
    $TotalCost.text = "Total cost: %d¢ (You have: %d¢)" % [total_cost, player_credits]
    if total_cost > player_credits:
        $TotalCost.modulate = Color.red
        $TotalCost.text += " [INSUFFICIENT FUNDS]"
```

### Coalition System
```gdscript
func display_coalition_requirements(quest: QuestData):
    # Show required members
    if quest.coalition_members_needed.size() > 0:
        $CoalitionReq.text = "Coalition members needed:"
        for skill in quest.coalition_members_needed:
            var member = CoalitionManager.get_member_with_skill(skill)
            if member:
                $CoalitionReq.text += "\n✓ %s (%s)" % [member.name, skill]
            else:
                $CoalitionReq.text += "\n✗ Need someone with %s" % skill
    
    # Show network effects
    var trust_impact = quest.rewards.get("coalition_trust", 0)
    if trust_impact > 0:
        var network_bonus = CoalitionManager.calculate_network_bonus(trust_impact)
        $NetworkEffect.text = "Coalition growth: +%d (×%0.1f network)" % [trust_impact, network_bonus]
    
    # Infiltration warnings
    if quest.assimilation_risk:
        $InfiltrationWarning.visible = true
        $InfiltrationWarning.text = "⚠ Risk of coalition infiltration!"
```

### NPC Trust System
```gdscript
func display_trust_requirements(quest: QuestData):
    # Show trust prerequisites
    var giver = NPCManager.get_npc(quest.giver_npc)
    if giver:
        var trust_dims = NPCTrustManager.get_trust_dimensions(quest.giver_npc)
        $TrustReq.text = "Trust requirements:"
        
        # Check each dimension
        for dim in quest.trust_requirements:
            var current = trust_dims.get(dim, 0)
            var required = quest.trust_requirements[dim]
            if current >= required:
                $TrustReq.text += "\n✓ %s: %d/%d" % [dim, current, required]
            else:
                $TrustReq.text += "\n✗ %s: %d/%d" % [dim, current, required]
    
    # Show trust impact
    for npc_id in quest.rewards.get("trust_gains", {}):
        var gain = quest.rewards.trust_gains[npc_id]
        $TrustImpact.text += "\n+%d %s trust" % [gain, npc_id]
```

### Detection System
```gdscript
func display_detection_risks(quest: QuestData):
    # Overall risk assessment
    var risk_level = calculate_quest_risk(quest)
    $RiskMeter.value = risk_level * 100
    $RiskLabel.text = get_risk_description(risk_level)
    
    # Specific warnings
    if quest.required_disguise != "":
        $Warnings.add_item("Must maintain %s cover" % quest.required_disguise)
    
    if quest.suspicion_threshold > 0:
        $Warnings.add_item("Keep suspicion below %d%%" % quest.suspicion_threshold)
    
    # Show escape routes
    if risk_level > 0.7:
        var escape_routes = CoalitionManager.get_escape_routes(quest.location)
        $EscapeInfo.text = "Escape routes: %d available" % escape_routes.size()
```

### Assimilation System
```gdscript
func display_assimilation_impact(quest: QuestData):
    # Show if NPCs involved are assimilated
    var assimilated_npcs = []
    for npc_id in quest.involved_npcs:
        if AssimilationManager.is_assimilated(npc_id):
            assimilated_npcs.append(npc_id)
    
    if assimilated_npcs.size() > 0:
        $AssimWarning.visible = true
        $AssimWarning.text = "⚠ Involves assimilated: %s" % assimilated_npcs
    
    # Show impact on station ratio
    var impact = AssimilationManager.calculate_quest_impact(quest.id)
    if impact != 0:
        $AssimImpact.text = "Station ratio change: %+0.1f%%" % impact
```

### Puzzle System
```gdscript
func display_puzzle_requirements(quest: QuestData):
    # Show required item combinations
    for puzzle_id in quest.puzzle_requirements:
        var puzzle = PuzzleManager.get_puzzle(puzzle_id)
        $PuzzleReq.add_child(create_puzzle_hint(puzzle))
    
    # Investigation chains
    if quest.category == "investigation":
        var chain = PuzzleManager.get_investigation_chain(quest.id)
        $InvestChain.setup(chain)
```

### Disguise System
```gdscript
func display_disguise_requirements(quest: QuestData):
    if quest.required_disguise != "":
        var uniform = DisguiseManager.get_uniform(quest.required_disguise)
        $DisguiseReq.text = "Required: %s uniform" % quest.required_disguise
        
        if InventoryManager.has_item(uniform.item_id):
            $DisguiseReq.text += " ✓"
        else:
            $DisguiseReq.text += " ✗"
            $DisguiseReq.text += "\nObtain from: %s" % uniform.sources
        
        # Role obligations
        $RoleObligations.text = "While disguised you must:"
        for obligation in uniform.obligations:
            $RoleObligations.text += "\n• " + obligation
```

### Tram Transportation
```gdscript
func calculate_travel_requirements(quest: QuestData):
    # Optimize travel route
    var route = TramSystem.plan_optimal_route(
        GameManager.current_district,
        quest.districts_involved
    )
    
    # Show route details
    $RouteInfo.text = "Optimal route:"
    var total_cost = 0
    var total_time = 0
    
    for hop in route:
        var cost = hop.cost
        var time = hop.time
        total_cost += cost
        total_time += time
        $RouteInfo.text += "\n%s → %s: %d¢, %d min" % [hop.from, hop.to, cost, time]
    
    $RouteTotals.text = "Total: %d¢, %d minutes" % [total_cost, total_time]
```

### District Access
```gdscript
func check_access_requirements(quest: QuestData):
    var missing_access = []
    
    for district in quest.districts_involved:
        var required = DistrictAccessManager.get_requirements(district)
        for req in required:
            if not InventoryManager.has_item(req):
                missing_access.append(req)
    
    if missing_access.size() > 0:
        $AccessWarning.visible = true
        $AccessWarning.text = "Missing access: %s" % missing_access
```

## Quest Types and Display

### Critical Path Quests
```gdscript
# Affect ending determination
# Cannot be abandoned
# Show assimilation impact
# Display time until evaluation day
var critical_quest_display = {
    "icon": "★",
    "color": Color.yellow,
    "priority": 0,  # Always on top
    "show_ending_impact": true
}
```

### Coalition Building
```gdscript
# Network effect calculations
# Member skill requirements
# Trust threshold tracking
# Infiltration risk assessment
func display_coalition_quest(quest: QuestData):
    var network_size = CoalitionManager.get_network_size()
    $NetworkBonus.text = "Current network: ×%0.1f" % [1.0 + (network_size * 0.1)]
    
    # Show infiltration risk
    var risk = CoalitionManager.calculate_infiltration_risk()
    if risk > 0.3:
        $InfiltrationRisk.modulate = Color.red
```

### Investigation Chains
```gdscript
# Evidence web visualization
# Cross-district connections
# Red herring warnings
# Assimilated source detection
func display_investigation(quest: QuestData):
    var evidence_chain = quest.evidence_chain
    for evidence in evidence_chain:
        if AssimilationManager.is_source_compromised(evidence.source):
            $EvidenceWarning.text = "⚠ Source may be compromised"
```

### Economic Pressure
```gdscript
# ROI calculations
# Time vs money trade-offs
# Market fluctuation warnings
# Scarcity indicators
func display_economic_quest(quest: QuestData):
    var roi = (quest.rewards.credits - quest.costs.total) / quest.time_investment
    $ROI.text = "Return: %d¢/hour" % roi
    
    if EconomyManager.is_item_scarce(quest.reward_item):
        $ScarcityBonus.visible = true
```

### Infiltration Missions
```gdscript
# Role performance tracking
# Suspicion meter integration
# Shift schedule display
# Escape route planning
func display_infiltration(quest: QuestData):
    $CurrentCover.text = "Cover: %s" % DisguiseManager.current_role
    $SuspicionBar.value = DetectionManager.get_suspicion_level()
    $ShiftTime.text = "Next shift: %s" % quest.next_shift_time
    
    # Show performance requirements
    for task in quest.role_tasks:
        $TaskList.add_item("%s [%d/%d]" % [task.name, task.completed, task.required])
```

## User Interaction

### Quest Selection
- Click to expand full details
- Double-click to set as tracked
- Right-click for context menu
- Drag to reorder priority

### Filtering Options
- By category
- By location/district
- By time remaining
- By NPC giver
- By reward type

### Search Functionality
- Text search in descriptions
- NPC name lookup
- Item requirement search
- Location-based filtering

### Map Integration
- "Show on Map" button
- Quest marker system
- Optimal route planning
- Travel cost estimation

## Visual Design

### Color Coding
```gdscript
const QUEST_COLORS = {
    "active": Color(0.9, 0.9, 0.8),      # Cream
    "complete": Color(0.6, 0.8, 0.6),    # Green
    "failed": Color(0.8, 0.4, 0.4),      # Red
    "timed": Color(0.9, 0.7, 0.4),       # Orange
    "optional": Color(0.7, 0.7, 0.9)     # Blue
}
```

### Typography
- Monospace font for consistency
- Bold for quest names
- Italic for NPC quotes
- Strikethrough for completed objectives

### Icons
- Minimal icon use
- Clock for timed quests
- Star for main story
- Shield for coalition
- Question mark for mysteries

## Modular Serialization Integration

```gdscript
# src/core/serializers/quest_log_serializer.gd
extends BaseSerializer

class_name QuestLogSerializer

func get_serializer_id() -> String:
    return "quest_log"

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    var quest_manager = get_node("/root/Game/QuestManager")
    if not quest_manager:
        return {}
    
    return {
        "active_quests": _serialize_quest_list(quest_manager.active_quests),
        "completed_quests": _serialize_quest_list(quest_manager.completed_quests),
        "failed_quests": _serialize_quest_list(quest_manager.failed_quests),
        "quest_flags": quest_manager.quest_flags,
        "tracked_quest": quest_manager.tracked_quest_id,
        "filter_settings": quest_manager.current_filters,
        "quest_timers": _serialize_timers(quest_manager.quest_timers),
        "objective_progress": quest_manager.objective_progress,
        "investigation_state": quest_manager.investigation_state
    }

func deserialize(data: Dictionary) -> void:
    var quest_manager = get_node("/root/Game/QuestManager")
    if not quest_manager:
        return
    
    quest_manager.active_quests = _deserialize_quest_list(data.get("active_quests", []))
    quest_manager.completed_quests = _deserialize_quest_list(data.get("completed_quests", []))
    quest_manager.failed_quests = _deserialize_quest_list(data.get("failed_quests", []))
    quest_manager.quest_flags = data.get("quest_flags", {})
    quest_manager.tracked_quest_id = data.get("tracked_quest", "")
    quest_manager.current_filters = data.get("filter_settings", {})
    quest_manager.quest_timers = _deserialize_timers(data.get("quest_timers", {}))
    quest_manager.objective_progress = data.get("objective_progress", {})
    quest_manager.investigation_state = data.get("investigation_state", {})
    
    # Refresh UI if open
    if quest_manager.ui_open:
        quest_manager.refresh_quest_display()

func _serialize_quest_list(quests: Array) -> Array:
    var serialized = []
    for quest in quests:
        serialized.append({
            "id": quest.id,
            "status": quest.status,
            "objectives_completed": quest.objectives_completed,
            "time_started": quest.time_started,
            "time_completed": quest.time_completed,
            "custom_data": quest.custom_data
        })
    return serialized

func _deserialize_quest_list(data: Array) -> Array:
    var quests = []
    for quest_data in data:
        var quest = QuestManager.get_quest_definition(quest_data.id)
        if quest:
            quest.status = quest_data.get("status", "active")
            quest.objectives_completed = quest_data.get("objectives_completed", [])
            quest.time_started = quest_data.get("time_started", 0)
            quest.time_completed = quest_data.get("time_completed", 0)
            quest.custom_data = quest_data.get("custom_data", {})
            quests.append(quest)
    return quests

func _serialize_timers(timers: Dictionary) -> Dictionary:
    var serialized = {}
    for quest_id in timers:
        serialized[quest_id] = {
            "deadline_day": timers[quest_id].deadline_day,
            "deadline_time": timers[quest_id].deadline_time,
            "warning_sent": timers[quest_id].warning_sent
        }
    return serialized

func _deserialize_timers(data: Dictionary) -> Dictionary:
    # Reconstruct timer objects
    var timers = {}
    for quest_id in data:
        timers[quest_id] = QuestTimer.new()
        timers[quest_id].deadline_day = data[quest_id].deadline_day
        timers[quest_id].deadline_time = data[quest_id].deadline_time
        timers[quest_id].warning_sent = data[quest_id].warning_sent
    return timers

func migrate(data: Dictionary, from_version: int, to_version: int) -> Dictionary:
    # Handle future migrations
    if from_version == 1 and to_version == 2:
        # Example: Add investigation state to old saves
        if not "investigation_state" in data:
            data["investigation_state"] = {}
    return data

func _ready():
    # Self-register with medium-high priority (after game systems, before pure UI)
    SaveManager.register_serializer("quest_log", self, 40)
```

## Accessibility Features

### Keyboard Navigation
- Tab through categories
- Arrow keys for quest selection
- Enter to expand details
- Escape to close log

### Screen Reader Support
- Semantic structure
- Alt text for icons
- Descriptive labels
- Status announcements

### Visual Accommodations
- High contrast mode
- Adjustable font size
- Color blind friendly palette
- Reduced animation option

## Performance Considerations

### Lazy Loading
- Load quest details on demand
- Paginate long quest lists
- Cache rendered text
- Minimize update frequency

### Memory Management
```gdscript
const MAX_COMPLETED_QUESTS = 100
const QUEST_ARCHIVE_THRESHOLD = 50

func archive_old_quests():
    if completed_quests.size() > MAX_COMPLETED_QUESTS:
        # Move oldest to archive file
        var to_archive = completed_quests.slice(0, QUEST_ARCHIVE_THRESHOLD)
        save_to_archive(to_archive)
        completed_quests = completed_quests.slice(QUEST_ARCHIVE_THRESHOLD, -1)
```

## Quest Notification System

### New Quest Alert
```gdscript
func add_quest(quest_data: QuestData):
    active_quests.append(quest_data)
    UI.show_notification("New Quest: " + quest_data.name)
    if quest_data.timed:
        UI.flash_notification("TIME SENSITIVE!")
```

### Progress Updates
```gdscript
signal objective_completed(quest_id, objective_index)
signal quest_completed(quest_id)
signal quest_failed(quest_id, reason)
```

### Reminder System
- Daily summary of active quests
- Deadline warnings
- Stalled quest notifications
- Location-based reminders

## Debug Features

### Quest Manipulation
```gdscript
# Debug mode only
func debug_complete_quest(quest_id: String):
    if not OS.is_debug_build():
        return
    
    var quest = get_quest(quest_id)
    if quest:
        complete_quest(quest, true)  # Force completion
```

### State Verification
- Check for orphaned objectives
- Validate quest prerequisites
- Ensure proper state transitions
- Monitor performance metrics

## Implementation Notes

### Quest Definition Format
```gdscript
# Example quest definition with full system integration
var infiltration_quest = {
    "id": "infiltrate_security",
    "name": "Wolf in Sheep's Clothing",
    "category": "infiltration",
    "priority": "critical",  # Affects ending
    "description": "Infiltrate the security office while maintaining your cover.",
    
    # Time constraints
    "time_limit": 20,  # Day 20
    "shift_schedule": {
        "start": "14:00",
        "end": "22:00",
        "days": ["weekdays"]
    },
    
    # Location and travel
    "districts_involved": ["habitation", "security", "industrial"],
    "primary_location": "security_office",
    "travel_estimate": {
        "time": 90,  # minutes total
        "cost": 40   # credits round trip
    },
    
    # Requirements
    "required_items": ["security_uniform", "fake_id"],
    "required_disguise": "security_guard",
    "trust_requirements": {
        "Marcus": {"professional": 50},
        "Coalition": {"ideological": 30}
    },
    "coalition_skills_needed": ["hacking", "distraction"],
    
    # Objectives with metadata
    "objectives": [
        {
            "id": "get_uniform",
            "text": "Obtain security uniform",
            "optional": false,
            "location": "laundry_district",
            "time_window": "night",
            "detection_risk": 0.3
        },
        {
            "id": "report_duty",
            "text": "Report for duty shift",
            "optional": false,
            "location": "security_office",
            "time_window": "14:00-14:30",
            "detection_risk": 0.7,
            "role_performance": true
        },
        {
            "id": "access_files",
            "text": "Access personnel files",
            "optional": false,
            "location": "security_terminal",
            "detection_risk": 0.9,
            "requires_skill": "hacking"
        },
        {
            "id": "maintain_cover",
            "text": "Maintain cover (Suspicion < 30%)",
            "optional": false,
            "continuous": true,
            "suspicion_threshold": 30
        },
        {
            "id": "plant_evidence",
            "text": "Plant evidence (Coalition request)",
            "optional": true,
            "location": "evidence_locker",
            "detection_risk": 0.8,
            "coalition_bonus": 25
        }
    ],
    
    # Rewards and consequences
    "rewards": {
        "credits": 500,
        "trust_gains": {
            "Marcus": {"professional": 20, "personal": 10},
            "Coalition": {"ideological": 15}
        },
        "items": ["security_keycard", "personnel_files"],
        "unlocks_quests": ["security_blackmail", "coalition_heist"],
        "assimilation_prevention": 2  # Saves 2 NPCs
    },
    
    # Failure states
    "failure_conditions": {
        "detected_during_infiltration": {
            "type": "instant",
            "consequence": "game_over",
            "detection_state": "pursuing"
        },
        "missed_duty_shift": {
            "type": "time",
            "consequence": "quest_failed",
            "trust_loss": {"Marcus": 30}
        },
        "cover_blown": {
            "type": "suspicion",
            "threshold": 30,
            "consequence": "alert_security"
        }
    },
    
    # System hooks
    "on_start": "DisguiseManager.enable_role_tracking('security_guard')",
    "on_complete": "CoalitionManager.unlock_security_resources()",
    "on_fail": "DetectionManager.increase_base_suspicion(10)",
    
    # Assimilation data
    "assimilation_risk": true,
    "compromised_npcs": ["guard_johnson"],  # Already turned
    "at_risk_npcs": ["clerk_amy", "tech_bob"]  # May turn during quest
}
```

### Update Cycle
```gdscript
func _process(delta):
    # Update only visible quests
    if not visible:
        return
    
    # Throttle updates
    update_timer += delta
    if update_timer > UPDATE_INTERVAL:
        update_timer = 0.0
        update_active_quests()
        check_timed_quests()
```

## Future Enhancements

### Advanced Features (Post-MVP)
- Quest branching visualization
- Consequence preview system
- Custom quest notes
- Quest sharing between players
- Achievement integration

### UI Improvements
- Animated transitions
- Quest completion replay
- Statistical overview
- Relationship web view
- Timeline visualization

## Special Features

### Assimilation Tracking
```gdscript
# Real-time assimilation monitoring
func update_assimilation_display():
    var ratio = AssimilationManager.get_station_ratio()
    $AssimBar.value = ratio * 100
    $AssimBar.modulate = lerp(Color.green, Color.red, ratio)
    
    # Days until ending evaluation
    var days_left = MultipleEndingsManager.evaluation_day - TimeManager.current_day
    $EndingTimer.text = "Evaluation in %d days" % days_left
    
    # Show which ending player is heading toward
    if ratio < 0.35:
        $EndingPreview.text = "Trending: Escape"
    elif ratio >= 0.65:
        $EndingPreview.text = "Trending: Control Station"
    else:
        $EndingPreview.text = "Trending: Uncertain"
```

### Economic Pressure Indicator
```gdscript
# Show financial stress across all quests
func calculate_economic_pressure():
    var total_costs = 0
    var potential_earnings = 0
    var time_to_complete = 0
    
    for quest in active_quests:
        total_costs += calculate_quest_costs(quest)
        potential_earnings += quest.rewards.get("credits", 0)
        time_to_complete += estimate_completion_time(quest)
    
    var daily_burn_rate = total_costs / max(1, time_to_complete / 24)
    var current_credits = EconomyManager.get_credits()
    var days_until_broke = current_credits / daily_burn_rate
    
    if days_until_broke < 3:
        $EconomicWarning.visible = true
        $EconomicWarning.text = "⚠ FINANCIAL CRISIS: %d days of funds" % days_until_broke
```

### Trust Network Visualization
```gdscript
# Show how quests affect trust relationships
func display_trust_web():
    var trust_changes = {}
    
    for quest in active_quests:
        for npc_id in quest.rewards.get("trust_gains", {}):
            if not trust_changes.has(npc_id):
                trust_changes[npc_id] = 0
            trust_changes[npc_id] += quest.rewards.trust_gains[npc_id]
    
    # Show network effects
    for npc_id in trust_changes:
        var base_gain = trust_changes[npc_id]
        var network_multiplier = NPCTrustManager.get_network_multiplier(npc_id)
        var total_gain = base_gain * network_multiplier
        
        $TrustNetwork.add_line(npc_id, "+%d (×%.1f network)" % [base_gain, network_multiplier])
```

### Time Investment Calculator
```gdscript
# Help player understand time costs
func show_time_investment():
    var time_breakdown = {}
    
    for quest in active_quests:
        var quest_time = {
            "travel": calculate_travel_time(quest),
            "objectives": calculate_objective_time(quest),
            "role_shifts": calculate_shift_time(quest),
            "contingency": calculate_risk_buffer(quest)
        }
        time_breakdown[quest.id] = quest_time
    
    # Show if player has enough time before deadlines
    for quest in get_timed_quests():
        var time_needed = get_total_time(time_breakdown[quest.id])
        var time_available = (quest.time_limit - TimeManager.current_day) * 24
        
        if time_needed > time_available * 0.8:
            $TimeWarning.add_item("%s: TIGHT DEADLINE" % quest.name)
```

## Conclusion

The Quest Log UI serves as the player's strategic command center, surfacing critical information from all game systems in a unified interface. By deeply integrating with the economy, time management, coalition building, trust networks, detection risks, and assimilation spread, it transforms from a simple task list into an essential planning tool. The modular serialization ensures the system can evolve without breaking saves, while the comprehensive system integration provides players with all the information needed to navigate the game's interconnected challenges and make meaningful decisions about their path to either escape or control of the station.