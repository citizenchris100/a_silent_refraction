# NPC Trust/Relationship System Design

## Overview

The NPC Trust/Relationship System manages the complex web of interpersonal connections between the player and NPCs, as well as between NPCs themselves. Trust is not just a number - it's a multi-faceted relationship affected by actions, time, shared experiences, and the spreading assimilation. The system creates meaningful social gameplay where building trust opens doors, reveals information, and ultimately determines who will stand with you against the alien threat.

## Core Concepts

### Relationship Philosophy
- **Trust is earned slowly, lost quickly**: Building takes time, betrayal is instant
- **Actions speak louder**: What you do matters more than what you say
- **NPCs remember everything**: Past interactions affect future opportunities
- **Relationships decay**: Without maintenance, trust erodes over time
- **Network effects**: NPCs talk to each other about you

### Trust Dimensions
1. **Personal Trust**: How much they trust you as an individual
2. **Professional Respect**: Recognition of your competence
3. **Emotional Bond**: Personal connection and friendship
4. **Ideological Alignment**: Shared beliefs about the station's future
5. **Fear/Intimidation**: Negative relationship based on power

## System Architecture

### Core Components

#### 1. Relationship Manager (Singleton)
```gdscript
# src/core/systems/relationship_manager.gd
extends Node

signal trust_changed(npc_id, old_value, new_value)
signal relationship_milestone(npc_id, milestone_type)
signal trust_decayed(npc_id, amount)
signal reputation_changed(faction, change)
signal relationship_revealed(npc1_id, npc2_id, relationship_type)

# Multi-dimensional relationships
var relationships: Dictionary = {}  # npc_id: RelationshipData
var npc_connections: Dictionary = {}  # npc_id: {other_npc_id: relationship_value}
var faction_standings: Dictionary = {}  # faction: reputation_value
var interaction_history: Array = []

func get_relationship(npc_id: String) -> RelationshipData:
    if not npc_id in relationships:
        relationships[npc_id] = RelationshipData.new()
        relationships[npc_id].npc_id = npc_id
        _initialize_relationship(relationships[npc_id])
    
    return relationships[npc_id]

func modify_trust(npc_id: String, dimension: String, amount: float, reason: String = ""):
    var relationship = get_relationship(npc_id)
    var old_total = relationship.get_total_trust()
    
    # Apply personality modifiers
    amount = _apply_personality_modifiers(npc_id, dimension, amount)
    
    # Apply change
    relationship.modify_dimension(dimension, amount)
    
    # Log interaction
    _log_interaction(npc_id, dimension, amount, reason)
    
    # Check for ripple effects
    _process_trust_ripples(npc_id, dimension, amount)
    
    # Check milestones
    var new_total = relationship.get_total_trust()
    _check_trust_milestones(npc_id, old_total, new_total)
    
    emit_signal("trust_changed", npc_id, old_total, new_total)

func _apply_personality_modifiers(npc_id: String, dimension: String, base_amount: float) -> float:
    var npc = NPCRegistry.get_npc(npc_id)
    var modified = base_amount
    
    # Personality affects trust gain/loss rates
    match npc.personality_type:
        "paranoid":
            if base_amount < 0:
                modified *= 1.5  # Loses trust faster
            else:
                modified *= 0.5  # Gains trust slower
        
        "trusting":
            if base_amount > 0:
                modified *= 1.3  # Gains trust faster
            else:
                modified *= 0.7  # Loses trust slower
        
        "analytical":
            # Consistent but smaller changes
            modified *= 0.8
        
        "emotional":
            # Larger swings both ways
            modified *= 1.4 if abs(base_amount) > 10 else 1.0
    
    # Apply gender-based modifiers
    modified = _apply_gender_trust_modifiers(npc_id, dimension, modified)
    
    return modified

func _apply_gender_trust_modifiers(npc_id: String, dimension: String, base_amount: float) -> float:
    var npc = NPCRegistry.get_npc(npc_id)
    var player_gender = GameManager.player_gender
    var npc_gender = npc.gender
    var modified = base_amount
    
    # Get NPC's gender-aware personality traits
    var progressiveness = npc.personality.get("progressiveness", 0.5)
    var sexism_level = npc.personality.get("sexism_level", 0.3)
    var competitiveness = npc.personality.get("competitiveness", 0.5)
    var gender_comfort = npc.personality.get("gender_comfort", 0.7)
    
    if player_gender == npc_gender:
        # Same gender interactions
        if dimension == "professional" and competitiveness > 0.6:
            # High competition reduces professional trust gains
            if base_amount > 0:
                modified *= (1.0 - competitiveness * 0.3)
        elif dimension == "personal" and progressiveness > 0.6:
            # Progressive NPCs bond easier with same gender
            if base_amount > 0:
                modified *= 1.2
    else:
        # Opposite gender interactions
        if sexism_level > 0.5:
            # Sexist NPCs have trust barriers
            if player_gender == "female" and dimension == "professional":
                # Less likely to respect professional competence
                if base_amount > 0:
                    modified *= (1.0 - sexism_level * 0.4)
            elif player_gender == "male" and npc_gender == "female":
                # Female NPC with high sexism might overcompensate
                if dimension == "personal":
                    modified *= 1.1  # Easier personal trust
        
        # Gender comfort affects all opposite-gender trust building
        if dimension in ["personal", "emotional"]:
            modified *= gender_comfort
    
    # Traditional values create additional barriers
    if progressiveness < 0.3:
        if player_gender != npc_gender and dimension == "professional":
            # Traditional NPCs struggle with non-traditional roles
            modified *= 0.7
    
    return modified

func _process_trust_ripples(source_npc: String, dimension: String, amount: float):
    # NPCs talk to each other
    if not source_npc in npc_connections:
        return
    
    for connected_npc in npc_connections[source_npc]:
        var connection_strength = npc_connections[source_npc][connected_npc]
        
        # Strong connections spread trust changes
        if connection_strength > 0.5:
            var ripple_amount = amount * connection_strength * 0.3
            
            # They'll tell their friends about you
            modify_trust(connected_npc, dimension, ripple_amount, "heard_from_" + source_npc)
            
            # But only one degree of separation in MVP
            if MVP_MODE:
                continue
            
            # In full implementation, recursively spread with decay

func get_faction_standing(faction: String) -> float:
    return faction_standings.get(faction, 0.0)

func modify_faction_standing(faction: String, amount: float):
    var old_standing = get_faction_standing(faction)
    faction_standings[faction] = clamp(old_standing + amount, -100, 100)
    
    # Faction changes affect all members
    for npc_id in NPCRegistry.get_npcs_by_faction(faction):
        var faction_influence = NPCRegistry.get_npc(npc_id).faction_loyalty
        modify_trust(npc_id, "ideological", amount * faction_influence, "faction_standing")
    
    emit_signal("reputation_changed", faction, amount)
```

#### 2. Relationship Data Structure
```gdscript
# src/core/relationships/relationship_data.gd
extends Resource

class_name RelationshipData

var npc_id: String = ""

# Trust dimensions (0-100)
var personal_trust: float = 10.0      # Default low trust
var professional_respect: float = 20.0 # Neutral professional
var emotional_bond: float = 0.0       # No bond initially
var ideological_alignment: float = 30.0 # Neutral ideology
var fear_intimidation: float = 0.0    # No fear initially

# Relationship state
var first_meeting_complete: bool = false
var last_interaction_time: float = 0.0
var total_interactions: int = 0
var positive_interactions: int = 0
var negative_interactions: int = 0
var favors_done: int = 0
var favors_owed: int = 0

# Special flags
var knows_player_name: bool = false
var has_shared_meal: bool = false
var saved_their_life: bool = false
var betrayed_trust: bool = false
var romantic_interest: bool = false

# Memory of specific events
var remembered_events: Array = []

func get_total_trust() -> float:
    # Weighted average of positive dimensions minus negative
    var positive = (personal_trust * 0.4 + 
                   professional_respect * 0.3 + 
                   emotional_bond * 0.2 + 
                   ideological_alignment * 0.1)
    
    var negative = fear_intimidation * 0.5
    
    return clamp(positive - negative, 0, 100)

func modify_dimension(dimension: String, amount: float):
    match dimension:
        "personal":
            personal_trust = clamp(personal_trust + amount, 0, 100)
        "professional":
            professional_respect = clamp(professional_respect + amount, 0, 100)
        "emotional":
            emotional_bond = clamp(emotional_bond + amount, 0, 100)
        "ideological":
            ideological_alignment = clamp(ideological_alignment + amount, 0, 100)
        "fear":
            fear_intimidation = clamp(fear_intimidation + amount, 0, 100)

func get_relationship_type() -> String:
    var total = get_total_trust()
    
    if betrayed_trust:
        return "betrayed"
    elif fear_intimidation > 50:
        return "fearful"
    elif emotional_bond > 70 and romantic_interest:
        return "romantic"
    elif emotional_bond > 60:
        return "close_friend"
    elif professional_respect > 70:
        return "respected_colleague"
    elif total > 60:
        return "friend"
    elif total > 40:
        return "acquaintance"
    elif total > 20:
        return "neutral"
    else:
        return "distrustful"
```

#### 3. Trust Building Mechanics
```gdscript
# src/core/relationships/trust_building.gd
extends Node

class_name TrustBuilding

# Actions that build trust
const TRUST_ACTIONS = {
    # Conversation
    "meaningful_conversation": {"personal": 5, "emotional": 3},
    "share_personal_story": {"personal": 8, "emotional": 5},
    "remember_detail": {"personal": 3, "emotional": 2},
    "use_their_name": {"personal": 2},
    
    # Professional
    "complete_favor": {"personal": 5, "professional": 10},
    "solve_problem": {"professional": 15, "personal": 5},
    "share_expertise": {"professional": 8},
    "respect_boundaries": {"professional": 5, "personal": 3},
    
    # Emotional
    "comfort_in_distress": {"emotional": 15, "personal": 10},
    "share_meal": {"emotional": 8, "personal": 5},
    "give_thoughtful_gift": {"emotional": 12, "personal": 8},
    "defend_publicly": {"emotional": 10, "professional": 5},
    
    # Ideological
    "agree_on_issue": {"ideological": 10},
    "support_their_cause": {"ideological": 15, "personal": 5},
    "challenge_respectfully": {"ideological": 5, "professional": 3},
    
    # Major events
    "save_their_life": {"personal": 30, "emotional": 25, "professional": 20},
    "trust_with_secret": {"personal": 20, "emotional": 15},
    "coalition_recruitment": {"ideological": 20, "personal": 15},
    
    # Gender-specific positive actions
    "prove_competence_despite_bias": {"professional": 20, "personal": 10},
    "stand_up_to_harassment": {"personal": 15, "emotional": 10},
    "break_gender_expectations_positively": {"personal": 12, "professional": 8},
    "show_solidarity_same_gender": {"personal": 10, "emotional": 8},
    "respectful_opposite_gender": {"personal": 8, "professional": 5}
}

# Actions that damage trust
const TRUST_DAMAGE = {
    "break_promise": {"personal": -20, "professional": -15},
    "betray_secret": {"personal": -40, "emotional": -30},
    "fail_critical_task": {"professional": -25, "personal": -10},
    "caught_lying": {"personal": -30, "professional": -20},
    "harm_their_friend": {"emotional": -25, "personal": -20},
    "oppose_ideology": {"ideological": -20},
    "threaten": {"fear": 20, "personal": -30, "emotional": -40},
    
    # Gender-specific negative actions
    "sexist_comment": {"personal": -15, "professional": -10, "emotional": -8},
    "unwanted_advances": {"personal": -25, "emotional": -20, "fear": 10},
    "dismiss_due_to_gender": {"professional": -20, "personal": -15},
    "competitive_undermining": {"professional": -15, "personal": -10},
    "patronizing_behavior": {"professional": -12, "personal": -8}
}

static func calculate_trust_change(action: String, npc_personality: String) -> Dictionary:
    var base_change = {}
    
    if action in TRUST_ACTIONS:
        base_change = TRUST_ACTIONS[action].duplicate()
    elif action in TRUST_DAMAGE:
        base_change = TRUST_DAMAGE[action].duplicate()
    else:
        return {}
    
    # Personality modifies impact
    return _apply_personality_to_change(base_change, npc_personality)

static func get_available_trust_actions(npc_id: String, context: Dictionary) -> Array:
    var available = []
    var relationship = RelationshipManager.get_relationship(npc_id)
    var npc = NPCRegistry.get_npc(npc_id)
    
    # Contextual actions
    if context.has("npc_distressed") and context.npc_distressed:
        available.append("comfort_in_distress")
    
    if context.has("meal_time") and context.meal_time:
        if not relationship.has_shared_meal:
            available.append("share_meal")
    
    if relationship.total_interactions > 3 and not relationship.knows_player_name:
        available.append("share_personal_story")
    
    # Trust level gates certain actions
    var trust = relationship.get_total_trust()
    if trust > 30:
        available.append("trust_with_secret")
    
    if trust > 50 and not npc.coalition_member:
        available.append("coalition_recruitment")
    
    return available
```

### Integration Systems

#### Dialog Integration
```gdscript
# Trust affects dialog options
func get_trust_gated_dialog(npc_id: String) -> Array:
    var relationship = RelationshipManager.get_relationship(npc_id)
    var trust = relationship.get_total_trust()
    var options = []
    
    # Base options always available
    options.append_array(DialogRegistry.get_base_options(npc_id))
    
    # Trust-gated options
    if trust >= 20:
        options.append({
            "text": "How are you really doing?",
            "branch": "personal_check_in",
            "trust_required": 20
        })
    
    if trust >= 40:
        options.append({
            "text": "Can I ask you something personal?",
            "branch": "personal_question",
            "trust_required": 40
        })
    
    if trust >= 60:
        options.append({
            "text": "I need your help with something important...",
            "branch": "request_major_favor",
            "trust_required": 60
        })
    
    if relationship.professional_respect >= 50:
        options.append({
            "text": "What's your professional opinion on this?",
            "branch": "professional_advice",
            "dimension": "professional"
        })
    
    # Special relationship options
    if relationship.romantic_interest and relationship.emotional_bond >= 60:
        options.append({
            "text": "[Express romantic interest]",
            "branch": "romantic_advance",
            "special": true
        })
    
    return options

# NPCs remember what you talk about
func process_dialog_memory(npc_id: String, topic: String, player_response: String):
    var relationship = RelationshipManager.get_relationship(npc_id)
    
    var memory = {
        "topic": topic,
        "response": player_response,
        "time": TimeManager.current_time,
        "trust_level": relationship.get_total_trust()
    }
    
    relationship.remembered_events.append(memory)
    
    # They'll reference this later
    DialogManager.add_callback_reference(npc_id, topic, memory)
```

#### Time-Based Decay
```gdscript
# Relationships need maintenance
func process_daily_decay():
    for npc_id in RelationshipManager.relationships:
        var relationship = RelationshipManager.relationships[npc_id]
        var days_since_interaction = TimeManager.days_since(relationship.last_interaction_time)
        
        if days_since_interaction > 3:
            # Natural decay without interaction
            var decay_rate = 1.0 * (days_since_interaction - 3)
            
            # Different dimensions decay differently
            relationship.emotional_bond = max(0, relationship.emotional_bond - decay_rate * 1.5)
            relationship.personal_trust = max(10, relationship.personal_trust - decay_rate)
            # Professional respect decays slowest
            relationship.professional_respect = max(15, relationship.professional_respect - decay_rate * 0.5)
            
            # Fear fades fastest
            relationship.fear_intimidation = max(0, relationship.fear_intimidation - decay_rate * 2)
            
            RelationshipManager.emit_signal("trust_decayed", npc_id, decay_rate)

# Special occasions to maintain relationships
func check_relationship_opportunities():
    var opportunities = []
    
    # Birthdays (if tracked)
    for npc_id in NPCRegistry.get_all_npcs():
        if TimeManager.is_npc_birthday(npc_id):
            opportunities.append({
                "type": "birthday",
                "npc": npc_id,
                "action": "give_birthday_gift",
                "trust_bonus": {"personal": 15, "emotional": 10}
            })
    
    # Shared meals
    if TimeManager.is_meal_time():
        var nearby_npcs = NPCManager.get_nearby_npcs()
        for npc in nearby_npcs:
            if RelationshipManager.get_relationship(npc.id).get_total_trust() > 30:
                opportunities.append({
                    "type": "meal",
                    "npc": npc.id,
                    "action": "invite_to_meal"
                })
    
    return opportunities
```

#### Coalition Integration
```gdscript
# Trust gates coalition recruitment
func check_coalition_recruitment(npc_id: String) -> Dictionary:
    var relationship = RelationshipManager.get_relationship(npc_id)
    var npc = NPCRegistry.get_npc(npc_id)
    
    # Base requirements
    var requirements = {
        "trust_needed": 70,
        "current_trust": relationship.get_total_trust(),
        "can_recruit": false,
        "reason": ""
    }
    
    # Personality affects requirements
    match npc.personality_type:
        "paranoid":
            requirements.trust_needed = 85
            requirements.reason = "Needs very high trust due to paranoia"
        "idealistic":
            requirements.trust_needed = 60
            if relationship.ideological_alignment > 50:
                requirements.trust_needed = 50
                requirements.reason = "Ideological alignment reduces requirement"
        "pragmatic":
            requirements.trust_needed = 65
            if relationship.professional_respect > 60:
                requirements.trust_needed = 55
                requirements.reason = "Professional respect helps"
    
    # Special cases
    if relationship.saved_their_life:
        requirements.trust_needed -= 20
        requirements.reason = "You saved their life"
    
    if relationship.betrayed_trust:
        requirements.trust_needed = 100  # Impossible
        requirements.reason = "Trust has been betrayed"
    
    requirements.can_recruit = relationship.get_total_trust() >= requirements.trust_needed
    
    return requirements
```

#### Assimilation Integration
```gdscript
# Assimilation affects relationships
func on_npc_assimilated(npc_id: String):
    var relationship = RelationshipManager.get_relationship(npc_id)
    
    # If high trust, this is devastating
    if relationship.get_total_trust() > 60:
        # Other NPCs who trusted them become paranoid
        for other_npc in npc_connections[npc_id]:
            if npc_connections[npc_id][other_npc] > 0.5:
                var shock_effect = {
                    "personal": -20,
                    "emotional": -15,
                    "fear": 10
                }
                RelationshipManager.modify_trust(other_npc, "multiple", shock_effect, 
                    "friend_assimilated")
                
                # They become harder to recruit
                NPCRegistry.get_npc(other_npc).personality_type = "paranoid"
    
    # Player relationship becomes complex
    if relationship.get_total_trust() > 50:
        # Option for special dialog trying to reach them
        DialogManager.unlock_branch(npc_id, "try_to_reach_assimilated_friend")

# Pre-assimilation behavior changes
func detect_assimilation_signs(npc_id: String) -> Array:
    var signs = []
    var relationship = RelationshipManager.get_relationship(npc_id)
    
    # High trust reveals subtle changes
    if relationship.get_total_trust() > 60:
        signs.append("They seem distracted lately")
        
    if relationship.professional_respect > 70:
        signs.append("Their work quality has dropped")
        
    if relationship.emotional_bond > 50:
        signs.append("They've been avoiding your usual lunch meetings")
        
    return signs
```

## MVP Implementation

### Basic Features

1. **Single Trust Value**
   - 0-100 simple scale
   - Basic actions add/subtract
   - Threshold unlocks at 30, 50, 70

2. **Core Actions**
   - Complete quests: +10 trust
   - Help with problems: +5 trust
   - Fail promises: -20 trust
   - Dialog choices: ±5 trust

3. **Simple Decay**
   - -1 trust per day without interaction
   - Minimum trust: 0
   - No complex personality modifiers

### MVP Relationship States
```gdscript
const RELATIONSHIP_STATES = {
    "stranger": {"min": 0, "max": 19},
    "acquaintance": {"min": 20, "max": 39},
    "friend": {"min": 40, "max": 69},
    "close_friend": {"min": 70, "max": 89},
    "best_friend": {"min": 90, "max": 100}
}
```

## Full Implementation

### Advanced Features

#### 1. Relationship Networks
```gdscript
# NPCs have relationships with each other
class NPCRelationshipNetwork:
    var relationships: Dictionary = {}  # {npc1_id: {npc2_id: relationship_value}}
    
    func get_mutual_connections(npc_id: String, player_trusted_npcs: Array) -> Array:
        var mutual = []
        
        for trusted_npc in player_trusted_npcs:
            if get_relationship(npc_id, trusted_npc) > 0.5:
                mutual.append({
                    "npc": trusted_npc,
                    "strength": get_relationship(npc_id, trusted_npc),
                    "type": _get_relationship_type(npc_id, trusted_npc)
                })
        
        return mutual
    
    func influence_through_network(source_npc: String, target_npc: String, 
                                  influence_type: String) -> bool:
        # Can source influence target?
        var relationship = get_relationship(source_npc, target_npc)
        
        if relationship > 0.6:  # Strong enough to influence
            match influence_type:
                "vouch_for_player":
                    var boost = relationship * 20
                    RelationshipManager.modify_trust(target_npc, "personal", boost,
                        "vouched_by_" + source_npc)
                    return true
                
                "warn_about_player":
                    var penalty = relationship * -15
                    RelationshipManager.modify_trust(target_npc, "personal", penalty,
                        "warned_by_" + source_npc)
                    return true
        
        return false
```

#### 2. Cultural & Professional Barriers
```gdscript
# Different groups have inherent trust barriers
class TrustBarriers:
    const FACTION_BARRIERS = {
        "military_civilian": -20,      # Military distrusts civilians
        "corporate_worker": -15,        # Class divide
        "security_criminal": -40,       # Natural enemies
        "medical_everyone": 10,         # Medical trusted by all
        "maintenance_everyone": 5       # Maintenance generally trusted
    }
    
    const GENDER_PROFESSION_BARRIERS = {
        # Additional barriers for non-traditional gender roles
        "female_security": -15,         # Female in authority faces skepticism
        "female_dock_worker": -20,      # Female in physical labor
        "male_nurse": -10,              # Male in caregiving role
        "female_corporate_exec": -15,   # Glass ceiling effect
        "male_secretary": -12           # Male in support role
    }
    
    static func get_initial_trust_modifier(player_background: String, npc_faction: String) -> float:
        var key = player_background + "_" + npc_faction
        var base_modifier = FACTION_BARRIERS.get(key, 0.0)
        
        # Add gender-profession barriers
        var player_gender = GameManager.player_gender
        var gender_key = player_gender + "_" + player_background
        var gender_modifier = GENDER_PROFESSION_BARRIERS.get(gender_key, 0.0)
        
        return base_modifier + gender_modifier
    
    static func get_gender_barrier_modifier(player_gender: String, profession: String, 
                                          npc_progressiveness: float) -> float:
        var gender_key = player_gender + "_" + profession
        var base_barrier = GENDER_PROFESSION_BARRIERS.get(gender_key, 0.0)
        
        # Progressive NPCs have reduced gender barriers
        if npc_progressiveness > 0.7:
            base_barrier *= 0.3  # 70% reduction
        elif npc_progressiveness > 0.5:
            base_barrier *= 0.6  # 40% reduction
        elif npc_progressiveness < 0.3:
            base_barrier *= 1.3  # 30% increase for traditional NPCs
        
        return base_barrier
    
    static func get_barrier_breaking_actions(player_background: String, npc_faction: String) -> Array:
        # Special actions that break down barriers
        match player_background + "_" + npc_faction:
            "civilian_military":
                return ["show_discipline", "respect_rank", "prove_competence"]
            "criminal_security":
                return ["help_solve_case", "turn_informant", "save_officer_life"]
            _:
                return ["prove_yourself", "find_common_ground"]
```

#### 3. Romance System
```gdscript
# Optional romantic relationships
class RomanceSystem:
    var romance_flags: Dictionary = {}  # npc_id: RomanceData
    
    func check_romance_potential(npc_id: String) -> bool:
        var npc = NPCRegistry.get_npc(npc_id)
        var relationship = RelationshipManager.get_relationship(npc_id)
        
        # Requirements
        if not npc.romance_available:
            return false
        
        if relationship.emotional_bond < 50:
            return false
        
        if relationship.personal_trust < 60:
            return false
        
        # Check gender preferences and era constraints
        if not _check_gender_romance_compatibility(npc_id):
            return false
        
        # Check compatibility
        return _check_romantic_compatibility(npc_id)
    
    func _check_gender_romance_compatibility(npc_id: String) -> bool:
        var npc = NPCRegistry.get_npc(npc_id)
        var player_gender = GameManager.player_gender
        
        # 1950s setting - heteronormative constraints for most NPCs
        var npc_progressiveness = npc.personality.get("progressiveness", 0.5)
        
        # Most NPCs only pursue opposite-gender romance
        if npc.gender == player_gender:
            # Same-gender romance only for very progressive NPCs
            if npc_progressiveness < 0.9:
                return false
            # Even then, it's secret/hidden
            npc.romance_flags["secret_relationship"] = true
        
        # Additional barriers based on gender dynamics
        if player_gender == "female":
            # Some male NPCs won't date women who work in "men's jobs"
            if GameManager.player_job in ["dock_worker", "security"]:
                if npc.personality.get("sexism_level", 0.3) > 0.6:
                    return false
        
        return true
    
    func initiate_romance(npc_id: String) -> Dictionary:
        if not check_romance_potential(npc_id):
            return {"success": false, "reason": "not_interested"}
        
        # Check if right moment
        var context = _evaluate_romantic_context()
        if not context.appropriate:
            return {"success": false, "reason": "bad_timing"}
        
        # Attempt based on trust
        var relationship = RelationshipManager.get_relationship(npc_id)
        var chance = (relationship.emotional_bond - 50) * 2  # 0-100% based on bond
        
        if randf() * 100 < chance:
            relationship.romantic_interest = true
            return {"success": true, "response": "positive"}
        else:
            # Doesn't destroy friendship but awkward
            relationship.emotional_bond -= 10
            return {"success": false, "reason": "not_mutual", "trust_preserved": true}
```

#### 4. Faction Reputation
```gdscript
# Actions affect entire groups
class FactionReputation:
    var standings: Dictionary = {
        "security": 0,
        "medical": 0,
        "maintenance": 0,
        "corporate": 0,
        "civilian": 0,
        "criminal": 0
    }
    
    func modify_standing(faction: String, amount: float, reason: String):
        standings[faction] = clamp(standings[faction] + amount, -100, 100)
        
        # Opposed factions react
        var opposed = get_opposed_faction(faction)
        if opposed:
            standings[opposed] -= amount * 0.5
        
        # Affect all members
        for npc_id in NPCRegistry.get_npcs_by_faction(faction):
            var loyalty = NPCRegistry.get_npc(npc_id).faction_loyalty
            RelationshipManager.modify_trust(npc_id, "ideological", 
                amount * loyalty, "faction_reputation")
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/relationship_serializer.gd
extends BaseSerializer

class_name RelationshipSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("relationships", self, 65)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "relationships": _serialize_relationships(),
        "npc_connections": RelationshipManager.npc_connections,
        "faction_standings": RelationshipManager.faction_standings,
        "interaction_history": _compress_interaction_history(),
        "romance_data": _serialize_romance_data(),
        "gender_trust_events": _serialize_gender_events()
    }

func _serialize_relationships() -> Dictionary:
    var data = {}
    
    for npc_id in RelationshipManager.relationships:
        var rel = RelationshipManager.relationships[npc_id]
        
        # Only save non-default values
        var rel_data = {}
        
        if rel.personal_trust != 10.0:
            rel_data["pt"] = rel.personal_trust
        if rel.professional_respect != 20.0:
            rel_data["pr"] = rel.professional_respect
        if rel.emotional_bond != 0.0:
            rel_data["eb"] = rel.emotional_bond
        if rel.ideological_alignment != 30.0:
            rel_data["ia"] = rel.ideological_alignment
        if rel.fear_intimidation != 0.0:
            rel_data["fi"] = rel.fear_intimidation
        
        # Flags
        if rel.first_meeting_complete:
            rel_data["fmt"] = true
        if rel.knows_player_name:
            rel_data["kpn"] = true
        if rel.betrayed_trust:
            rel_data["bt"] = true
        
        # Counters
        rel_data["ti"] = rel.total_interactions
        rel_data["pi"] = rel.positive_interactions
        
        # Recent memories only
        if rel.remembered_events.size() > 0:
            rel_data["mem"] = _compress_memories(rel.remembered_events)
        
        if rel_data.size() > 0:
            data[npc_id] = rel_data
    
    return data

func deserialize(data: Dictionary) -> void:
    # Clear current relationships
    RelationshipManager.relationships.clear()
    
    # Restore relationships
    var relationships = data.get("relationships", {})
    for npc_id in relationships:
        var rel = RelationshipData.new()
        rel.npc_id = npc_id
        
        var rel_data = relationships[npc_id]
        
        # Restore dimensions
        rel.personal_trust = rel_data.get("pt", 10.0)
        rel.professional_respect = rel_data.get("pr", 20.0)
        rel.emotional_bond = rel_data.get("eb", 0.0)
        rel.ideological_alignment = rel_data.get("ia", 30.0)
        rel.fear_intimidation = rel_data.get("fi", 0.0)
        
        # Restore flags
        rel.first_meeting_complete = rel_data.get("fmt", false)
        rel.knows_player_name = rel_data.get("kpn", false)
        rel.betrayed_trust = rel_data.get("bt", false)
        
        # Restore counters
        rel.total_interactions = rel_data.get("ti", 0)
        rel.positive_interactions = rel_data.get("pi", 0)
        
        # Restore memories
        if "mem" in rel_data:
            rel.remembered_events = _decompress_memories(rel_data.mem)
        
        RelationshipManager.relationships[npc_id] = rel
    
    # Restore other data
    RelationshipManager.npc_connections = data.get("npc_connections", {})
    RelationshipManager.faction_standings = data.get("faction_standings", {})
    _decompress_interaction_history(data.get("interaction_history", []))
    _deserialize_romance_data(data.get("romance_data", {}))
```

## UI Components

### Relationship Status Display
```gdscript
# src/ui/relationships/relationship_hud.gd
extends Control

onready var npc_name = $NPCName
onready var trust_bar = $TrustBar
onready var relationship_icon = $RelationshipIcon
onready var trust_breakdown = $TrustBreakdown

func show_for_npc(npc_id: String):
    var npc = NPCRegistry.get_npc(npc_id)
    var relationship = RelationshipManager.get_relationship(npc_id)
    
    npc_name.text = npc.name
    trust_bar.value = relationship.get_total_trust()
    
    # Color based on relationship
    var color = _get_relationship_color(relationship.get_relationship_type())
    trust_bar.modulate = color
    
    # Show icon
    relationship_icon.texture = _get_relationship_icon(relationship.get_relationship_type())
    
    # Breakdown if high enough trust
    if relationship.get_total_trust() > 40:
        trust_breakdown.show()
        trust_breakdown.set_values({
            "Personal": relationship.personal_trust,
            "Professional": relationship.professional_respect,
            "Emotional": relationship.emotional_bond,
            "Ideological": relationship.ideological_alignment
        })
    
    show()
```

### Relationship Journal
```gdscript
# src/ui/relationships/relationship_journal.gd
extends Control

onready var npc_list = $NPCList
onready var detail_panel = $DetailPanel
onready var history_log = $HistoryLog

func _ready():
    _populate_npc_list()

func _populate_npc_list():
    npc_list.clear()
    
    # Group by relationship type
    var grouped = {}
    for npc_id in RelationshipManager.relationships:
        var rel = RelationshipManager.relationships[npc_id]
        var type = rel.get_relationship_type()
        
        if not type in grouped:
            grouped[type] = []
        
        grouped[type].append(npc_id)
    
    # Add to list
    for type in ["close_friend", "friend", "acquaintance", "neutral", "distrustful"]:
        if type in grouped:
            npc_list.add_item("=== " + type.capitalize() + " ===")
            
            for npc_id in grouped[type]:
                var npc = NPCRegistry.get_npc(npc_id)
                var trust = RelationshipManager.get_relationship(npc_id).get_total_trust()
                npc_list.add_item("  %s (Trust: %d)" % [npc.name, trust])
```

## Gender-Aware Trust Display

The UI should reflect gender dynamics affecting relationships:

```gdscript
func get_trust_barrier_description(npc_id: String) -> String:
    var npc = NPCRegistry.get_npc(npc_id)
    var barriers = []
    
    # Check for gender-based professional barriers
    var player_job = GameManager.player_job
    var player_gender = GameManager.player_gender
    var gender_barrier = TrustBarriers.get_gender_barrier_modifier(
        player_gender, player_job, npc.personality.progressiveness
    )
    
    if gender_barrier < -10:
        match player_job:
            "dock_worker":
                if player_gender == "female":
                    barriers.append("Skeptical of women in physical labor")
            "security":
                if player_gender == "female":
                    barriers.append("Doubts female authority")
            "nurse":
                if player_gender == "male":
                    barriers.append("Suspicious of men in caregiving")
    
    # Check for gender personality conflicts
    if npc.personality.sexism_level > 0.6:
        if player_gender == "female":
            barriers.append("Traditional views on women's roles")
    
    if npc.personality.competitiveness > 0.7 and npc.gender == player_gender:
        barriers.append("Sees you as competition")
    
    return "\n".join(barriers) if barriers.size() > 0 else ""

func show_relationship_tooltip(npc_id: String):
    var tooltip = ""
    var relationship = RelationshipManager.get_relationship(npc_id)
    var npc = NPCRegistry.get_npc(npc_id)
    
    # Show base trust info
    tooltip += "Trust: %d/100\n" % relationship.get_total_trust()
    
    # Show gender dynamics if relevant
    if abs(1.0 - npc.personality.gender_comfort) > 0.3:
        if npc.personality.gender_comfort < 0.5:
            tooltip += "[color=yellow]Uncomfortable around %s gender[/color]\n" % \
                ("opposite" if npc.gender != GameManager.player_gender else "same")
    
    # Show barriers
    var barriers = get_trust_barrier_description(npc_id)
    if barriers:
        tooltip += "\n[color=red]Trust Barriers:[/color]\n" + barriers
    
    UI.show_tooltip(tooltip)
```

## Balance Considerations

### Trust Building Rates
- **Small actions**: +2-5 trust (greetings, small favors)
- **Medium actions**: +5-15 trust (quests, meaningful conversations)
- **Major actions**: +15-30 trust (saving life, major favors)
- **Betrayals**: -20-40 trust (broken promises, lies)

### Decay Rates
- **No interaction**: -1 trust/day after 3 days
- **Negative event**: Accelerated decay
- **High bond**: Slower decay (friendship endures)
- **Fear**: Decays fastest (-2/day)

### Threshold Mechanics
- **20 Trust**: Basic personal questions
- **40 Trust**: Ask for favors
- **60 Trust**: Share secrets
- **70 Trust**: Coalition recruitment
- **90 Trust**: Would die for you

## Testing Considerations

1. **Trust Calculations**
   - All dimensions calculate correctly
   - Personality modifiers apply properly
   - Ripple effects work as intended
   - Decay happens appropriately

2. **Integration Testing**
   - Dialog options unlock at thresholds
   - Coalition recruitment requirements work
   - Assimilation affects relationships
   - Save/load preserves relationships

3. **Balance Testing**
   - Can build trust reasonably
   - Can't exploit system
   - Meaningful choices have impact
   - Recovery from mistakes possible

4. **Edge Cases**
   - Betrayed trust locks properly
   - Romance doesn't break on rejection
   - Network effects don't infinite loop
   - Faction standings calculate correctly

This system creates a rich social landscape where every interaction matters, relationships require maintenance, and the trust you build becomes crucial for survival as the station falls into chaos.