extends "res://src/districts/shipping/shipping_district.gd"

func _ready():
    district_name = "Shipping District"
    district_description = "The station's dock area where ships arrive with cargo and passengers."
    
    # Call parent _ready
    ._ready()
    
    # Add NPCs
    _add_npcs()

# Add NPCs to the district
func _add_npcs():
    # Load NPC scenes
    var security_officer = load("res://src/characters/npc/security_officer.gd").new()
    security_officer.position = Vector2(300, 400)
    add_child(security_officer)
    
    # Add sprite for the NPC
    var officer_sprite = ColorRect.new()
    officer_sprite.rect_size = Vector2(32, 48)
    officer_sprite.rect_position = Vector2(-16, -48)
    officer_sprite.color = Color(0.8, 0.2, 0.2)  # Red for security
    security_officer.add_child(officer_sprite)
    
    # Add label for the NPC
    var officer_label = Label.new()
    officer_label.text = "Security Officer"
    officer_label.rect_position = Vector2(-40, -60)
    security_officer.add_child(officer_label)
