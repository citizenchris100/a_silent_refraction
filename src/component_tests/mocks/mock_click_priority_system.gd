extends Node
# Mock Click Priority System for component testing

signal click_processed(click_data)
signal click_rejected(click_data)

# Priority levels
const PRIORITY_UI = 0        # Highest - UI always wins
const PRIORITY_OBJECT = 1    # Interactive objects
const PRIORITY_NPC = 2       # NPCs
const PRIORITY_MOVEMENT = 3  # Lowest - movement

func _ready():
	pass

func _on_click_detected(click_data):
	if click_data == null:
		emit_signal("click_rejected", {"reason": "null_data"})
		return
	
	if not click_data.has("position"):
		emit_signal("click_rejected", {"reason": "missing_position"})
		return
	
	# UI clicks are rejected for game world processing
	if click_data.get("is_ui_click", false):
		emit_signal("click_rejected", click_data)
		return
	
	# Determine priority
	var priority = PRIORITY_MOVEMENT
	if click_data.has("hit_object"):
		if click_data.hit_object != null:
			priority = PRIORITY_OBJECT
	
	# Process the click
	var processed_data = click_data.duplicate()
	processed_data["priority"] = priority
	processed_data["original_position"] = click_data.position
	
	emit_signal("click_processed", processed_data)

func _on_click_processed(click_data):
	# The feedback system would handle this
	pass