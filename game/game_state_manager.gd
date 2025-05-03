extends Node

# Game progress trackers
var coalition_strength: float = 0.0
var investigation_progress: float = 0.0
var time_remaining: float = 100.0  # Represents game time units
var game_difficulty: String = "normal"

# NPC tracking
var known_npcs: Dictionary = {}
var coalition_members: Array = []
var suspected_assimilated: Array = []
var confirmed_assimilated: Array = []

# Player knowledge
var player_knowledge: Dictionary = {
    "clues_found": [],
    "locations_unlocked": ["shipping"],
    "assimilation_evidence": {} # NPC ID -> evidence array
}

# Game ending states
enum GameEnding {
    COALITION_VICTORY,
    ESCAPE_VICTORY,
    ASSIMILATED_DEFEAT,
    TIME_OUT_DEFEAT
}

func _ready():
    # Initialize game state
    reset_game_state()

func reset_game_state() -> void:
    coalition_strength = 0.0
    investigation_progress = 0.0
    time_remaining = 100.0
    
    known_npcs.clear()
    coalition_members.clear()
    suspected_assimilated.clear()
    confirmed_assimilated.clear()
    
    player_knowledge = {
        "clues_found": [],
        "locations_unlocked": ["shipping"],
        "assimilation_evidence": {}
    }

func register_npc(npc_id: String, npc_data: Dictionary) -> void:
    known_npcs[npc_id] = npc_data
    
func add_to_coalition(npc_id: String) -> bool:
    # Can't add if already in coalition
    if npc_id in coalition_members:
        return false
        
    # Can't add if confirmed assimilated
    if npc_id in confirmed_assimilated:
        return false
        
    coalition_members.append(npc_id)
    update_coalition_strength()
    return true
    
func remove_from_coalition(npc_id: String) -> void:
    if npc_id in coalition_members:
        coalition_members.erase(npc_id)
        update_coalition_strength()
        
func update_coalition_strength() -> void:
    # Base calculation on number of members and their influence/trust levels
    var base_strength = coalition_members.size() * 0.1
    var bonus_strength = 0.0
    
    for member_id in coalition_members:
        if member_id in known_npcs:
            bonus_strength += known_npcs[member_id].get("influence", 0.0) * 0.05
            
    coalition_strength = min(base_strength + bonus_strength, 1.0)
    
func spend_time(amount: float) -> bool:
    # Returns false if time ran out
    time_remaining = max(time_remaining - amount, 0.0)
    return time_remaining > 0.0
    
func add_investigation_progress(amount: float) -> void:
    investigation_progress = min(investigation_progress + amount, 1.0)
    
    # Unlock new areas based on investigation progress
    if investigation_progress >= 0.2 and not "mall" in player_knowledge.locations_unlocked:
        player_knowledge.locations_unlocked.append("mall")
    if investigation_progress >= 0.4 and not "commerce" in player_knowledge.locations_unlocked:
        player_knowledge.locations_unlocked.append("commerce")
    if investigation_progress >= 0.6 and not "barracks" in player_knowledge.locations_unlocked:
        player_knowledge.locations_unlocked.append("barracks")
    if investigation_progress >= 0.8 and not "engineering" in player_knowledge.locations_unlocked:
        player_knowledge.locations_unlocked.append("engineering")
    
func add_clue(clue_id: String) -> void:
    if not clue_id in player_knowledge.clues_found:
        player_knowledge.clues_found.append(clue_id)
        add_investigation_progress(0.05)
        
func add_assimilation_evidence(npc_id: String, evidence: String) -> void:
    if not npc_id in player_knowledge.assimilation_evidence:
        player_knowledge.assimilation_evidence[npc_id] = []
        
    if not evidence in player_knowledge.assimilation_evidence[npc_id]:
        player_knowledge.assimilation_evidence[npc_id].append(evidence)
        
        # If enough evidence, move to suspected list
        if player_knowledge.assimilation_evidence[npc_id].size() >= 3:
            if not npc_id in suspected_assimilated:
                suspected_assimilated.append(npc_id)
    
func confirm_assimilated(npc_id: String) -> void:
    if not npc_id in confirmed_assimilated:
        confirmed_assimilated.append(npc_id)
        
    # Remove from coalition if present
    if npc_id in coalition_members:
        remove_from_coalition(npc_id)
        
func check_game_ending() -> int:
    # Check if time ran out
    if time_remaining <= 0:
        return GameEnding.TIME_OUT_DEFEAT
        
    # Check for coalition victory
    if coalition_strength >= 0.7 and investigation_progress >= 0.5:
        return GameEnding.COALITION_VICTORY
        
    # Check for escape victory
    if coalition_strength >= 0.4 and investigation_progress >= 0.8:
        return GameEnding.ESCAPE_VICTORY
        
    # Check for defeat by assimilation
    var assimilated_strength = confirmed_assimilated.size() * 0.15
    if assimilated_strength >= 0.8:
        return GameEnding.ASSIMILATED_DEFEAT
        
    # Game still in progress
    return -1
