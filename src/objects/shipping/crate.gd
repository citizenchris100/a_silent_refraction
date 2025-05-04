extends "res://src/objects/base/interactive_object.gd"

func _ready():
    object_name = "Crate"
    description = "A standard shipping crate."
    
    # Set custom responses
    responses["Look at"] = "A standard metal shipping crate with the Aether Corp logo."
    responses["Use"] = "The crate is locked tight."
    responses["Pick up"] = "It's far too heavy to lift."
    responses["Open"] = "It seems to be locked."
    
    # Call parent _ready instead of using super
    ._ready()
