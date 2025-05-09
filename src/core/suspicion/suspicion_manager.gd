extends Node

signal global_suspicion_changed(level)

var global_suspicion_level = 0.0 setget set_global_suspicion
var npc_suspicion_weights = {}

# Map of relevant NPCs
var tracked_npcs = {}

func _ready():
    # Wait for the scene to be fully loaded
    yield(get_tree(), "idle_frame")
    
    # Find NPCs
    for npc in get_tree().get_nodes_in_group("npc"):
        track_npc(npc)

# Track a new NPC
func track_npc(npc):
    if npc and not tracked_npcs.has(npc):
        tracked_npcs[npc] = npc.suspicion_level
        npc_suspicion_weights[npc] = 1.0  # Default equal weighting
        
        # Connect to NPC signals
        if not npc.is_connected("suspicion_changed", self, "_on_npc_suspicion_changed"):
            npc.connect("suspicion_changed", self, "_on_npc_suspicion_changed", [npc])
        
        if not npc.is_connected("tree_exiting", self, "_on_npc_exiting"):
            npc.connect("tree_exiting", self, "_on_npc_exiting", [npc])
        
        # Update global suspicion
        calculate_global_suspicion()

# Stop tracking an NPC
func _on_npc_exiting(npc):
    if tracked_npcs.has(npc):
        tracked_npcs.erase(npc)
        npc_suspicion_weights.erase(npc)
        
        # Update global suspicion
        calculate_global_suspicion()

# Handle suspicion change for a specific NPC
func _on_npc_suspicion_changed(old_level, new_level, npc):
    if tracked_npcs.has(npc):
        tracked_npcs[npc] = new_level
        
        # Update global suspicion
        calculate_global_suspicion()

# Set the weight of an NPC in the global suspicion calculation
func set_npc_weight(npc, weight):
    if tracked_npcs.has(npc):
        npc_suspicion_weights[npc] = weight
        calculate_global_suspicion()

# Calculate global suspicion level based on weighted average of all tracked NPCs
func calculate_global_suspicion():
    var total_suspicion = 0.0
    var total_weight = 0.0
    
    for npc in tracked_npcs.keys():
        var weight = npc_suspicion_weights[npc]
        total_suspicion += tracked_npcs[npc] * weight
        total_weight += weight
    
    if total_weight > 0:
        set_global_suspicion(total_suspicion / total_weight)
    else:
        set_global_suspicion(0.0)

# Set global suspicion level
func set_global_suspicion(value):
    var old_level = global_suspicion_level
    global_suspicion_level = clamp(value, 0.0, 1.0)
    
    if global_suspicion_level != old_level:
        emit_signal("global_suspicion_changed", global_suspicion_level)

# Get suspicion level for a specific NPC
func get_npc_suspicion(npc):
    if tracked_npcs.has(npc):
        return tracked_npcs[npc]
    return 0.0
