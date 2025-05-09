extends Control

export var show_percentage = true
export var show_label = true
export var label_text = "Station Alert Level"

onready var meter_fill = $Background/Fill
onready var meter_label = $Label
onready var status_label = $StatusLabel

var suspicion_level = 0.0 setget set_suspicion_level
var suspicion_manager = null

func _ready():
    # Find suspicion manager
    yield(get_tree(), "idle_frame")
    suspicion_manager = _find_suspicion_manager()
    
    if suspicion_manager:
        suspicion_manager.connect("global_suspicion_changed", self, "set_suspicion_level")
        set_suspicion_level(suspicion_manager.global_suspicion_level)
    
    # Set label text
    if status_label and show_label:
        status_label.text = label_text
    elif status_label:
        status_label.visible = false

# Find the suspicion manager in the scene
func _find_suspicion_manager():
    var root = get_tree().get_root()
    for node in root.get_children():
        for child in node.get_children():
            if child.get_class() == "Node" and child.get_script() and child.get_script().get_path().ends_with("suspicion_manager.gd"):
                return child
    return null

# Update the suspicion meter
func set_suspicion_level(value):
    suspicion_level = clamp(value, 0.0, 1.0)
    
    if meter_fill:
        # Update fill width based on suspicion level
        var bg_width = $Background.rect_size.x
        meter_fill.rect_size.x = bg_width * suspicion_level
        
        # Update color based on suspicion level
        if suspicion_level >= 0.8:
            meter_fill.color = Color(0.9, 0.1, 0.1) # Red
        elif suspicion_level >= 0.5:
            meter_fill.color = Color(0.9, 0.9, 0.1) # Yellow
        else:
            meter_fill.color = Color(0.1, 0.9, 0.1) # Green
    
    # Update label text
    if meter_label and show_percentage:
        var percentage = int(suspicion_level * 100)
        meter_label.text = str(percentage) + "%"
    elif meter_label:
        meter_label.visible = false
