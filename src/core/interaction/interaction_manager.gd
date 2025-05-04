extends Node

# Current selected verb (look, use, talk, etc.)
var current_verb = "look"

# Current selected inventory item (for "use X with Y" style interactions)
var current_inventory_item = null

# Handle interaction between verb, object, and optionally an inventory item
func interact(verb, object, inventory_item = null):
    print("Interacting: " + verb + " + " + object.name + 
          (inventory_item != null ? " + " + inventory_item.name : ""))
    
    # Each object handles its own interactions
    if object.has_method("interact"):
        return object.interact(verb, inventory_item)
    
    # Default generic responses
    match verb:
        "look":
            return "You see " + object.name
        "use":
            if inventory_item != null:
                return "You can't use " + inventory_item.name + " with " + object.name
            else:
                return "You can't use that"
        "talk":
            return object.name + " doesn't respond"
        _:
            return "You can't " + verb + " that"
