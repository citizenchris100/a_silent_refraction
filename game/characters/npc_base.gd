extends "res://addons/escoria/character.gd"

# NPC attributes
var suspicion_level: float = 0.0
var is_assimilated: bool = false
var trust_level: float = 0.0
var backstory: Dictionary = {}
var daily_routine: Array = []
var observed_behaviors: Array = []

# Methods to interact with NPC
func observe_behavior(behavior_id: String) -> void:
    # Add the observed behavior to the list if not already present
    if not behavior_id in observed_behaviors:
        observed_behaviors.append(behavior_id)
        
    # Different behaviors might affect suspicion differently
    match behavior_id:
        "acting_strange":
            increase_suspicion(0.2)
        "normal_routine":
            decrease_suspicion(0.1)
        _:
            # Default behavior doesn't affect suspicion
            pass

func increase_suspicion(amount: float) -> void:
    suspicion_level = min(suspicion_level + amount, 1.0)
    
    # If suspicion gets too high, NPC might report player
    if suspicion_level >= 0.8:
        _consider_reporting_player()

func decrease_suspicion(amount: float) -> void:
    suspicion_level = max(suspicion_level - amount, 0.0)

func increase_trust(amount: float) -> void:
    trust_level = min(trust_level + amount, 1.0)

func decrease_trust(amount: float) -> void:
    trust_level = max(trust_level - amount, 0.0)

func _consider_reporting_player() -> void:
    # This method would be called when suspicion is high
    # It would trigger a narrative event where the NPC reports the player
    # to the assimilated faction if appropriate
    if is_assimilated and suspicion_level >= 0.9:
        # Trigger a reporting event
        escoria.run_esc_script("npc_reports_player", [global_id])
