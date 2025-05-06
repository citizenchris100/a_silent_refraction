extends "res://src/characters/npc/base_npc_new.gd"

func _ready():
    npc_name = "Security Officer"
    description = "A stern-looking security officer in a uniform."
    is_assimilated = true  # This one is assimilated!
    
    # Call parent _ready
    ._ready()
    
    # Set visual color
    if visual_sprite is ColorRect:
        visual_sprite.color = Color(0.8, 0.2, 0.2)  # Red for security

# Override dialog initialization
func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Halt. This area is under security lockdown. State your business.",
            "options": [
                {"text": "I'm just passing through.", "next": "passing", "suspicion_change": 0.1},
                {"text": "What's going on with the lockdown?", "next": "lockdown_info"},
                {"text": "I'll go elsewhere.", "next": "exit"}
            ]
        },
        "passing": {
            "text": "No one is 'just passing through' during a security lockdown. What's your real purpose here?",
            "options": [
                {"text": "I'm delivering something to the Bank Teller.", "next": "bank_teller", "suspicion_change": 0.3},
                {"text": "I'm looking for my room.", "next": "room", "suspicion_change": 0.1},
                {"text": "None of your business.", "next": "hostile", "suspicion_change": 0.4}
            ]
        },
        "lockdown_info": {
            "text": "Standard security protocol. There's been a potential breach in station security. Nothing for law-abiding citizens to worry about.",
            "options": [
                {"text": "What kind of breach?", "next": "breach", "suspicion_change": 0.2},
                {"text": "How long will it last?", "next": "duration"},
                {"text": "I understand.", "next": "exit"}
            ]
        },
        "bank_teller": {
            "text": "The Bank Teller? What are you delivering?",
            "options": [
                {"text": "A package from the Concierge.", "next": "concierge_package", "suspicion_change": 0.5},
                {"text": "Just some documents.", "next": "documents", "suspicion_change": 0.3},
                {"text": "That's confidential.", "next": "confidential", "suspicion_change": 0.4}
            ]
        },
        "concierge_package": {
            "text": "A package from the Concierge, you say? I'll need to inspect that. Hand it over.",
            "options": [
                {"text": "Here it is.", "next": "hand_over", "suspicion_change": 0.5},
                {"text": "I'd rather not.", "next": "refuse", "suspicion_change": 0.6},
                {"text": "Actually, I don't have it yet.", "next": "no_package", "suspicion_change": 0.3}
            ]
        },
        "hand_over": {
            "text": "Thank you for your cooperation. This package contains contraband. You're under arrest.",
            "options": [
                {"text": "Wait, what?", "next": "game_over", "suspicion_change": 1.0}
            ]
        },
        "room": {
            "text": "Which room is yours?",
            "options": [
                {"text": "Room 306.", "next": "correct_room"},
                {"text": "I don't remember.", "next": "forget_room", "suspicion_change": 0.3}
            ]
        },
        "correct_room": {
            "text": "I see. Carry on, but stay out of restricted areas.",
            "options": [
                {"text": "Will do.", "next": "exit"}
            ]
        },
        "breach": {
            "text": "That's classified information. Your interest in security matters is noted.",
            "options": [
                {"text": "Just curious.", "next": "curious", "suspicion_change": 0.2},
                {"text": "Sorry for asking.", "next": "exit"}
            ]
        },
        "duration": {
            "text": "Until the situation is resolved. Now, state your business or move along.",
            "options": [
                {"text": "I'll move along.", "next": "exit"}
            ]
        },
        "hostile": {
            "text": "Hostility towards security personnel is a Class 3 violation. Final warning: state your business.",
            "options": [
                {"text": "I'm delivering something to the Bank Teller.", "next": "bank_teller", "suspicion_change": 0.3},
                {"text": "I'm looking for my room.", "next": "room", "suspicion_change": 0.1},
                {"text": "Still none of your business.", "next": "game_over", "suspicion_change": 1.0}
            ]
        },
        "documents": {
            "text": "All documents must be inspected during lockdown. Hand them over.",
            "options": [
                {"text": "Here they are.", "next": "hand_over", "suspicion_change": 0.5},
                {"text": "I'd rather not.", "next": "refuse", "suspicion_change": 0.6}
            ]
        },
        "confidential": {
            "text": "Nothing is confidential from station security during lockdown. Final warning: hand over what you're carrying.",
            "options": [
                {"text": "Fine, here it is.", "next": "hand_over", "suspicion_change": 0.5},
                {"text": "I refuse.", "next": "refuse", "suspicion_change": 0.6}
            ]
        },
        "refuse": {
            "text": "Refusing a direct order from security. You're coming with me to the brig for questioning.",
            "options": [
                {"text": "I'm not going anywhere.", "next": "game_over", "suspicion_change": 1.0},
                {"text": "Alright, I'll come quietly.", "next": "brig", "suspicion_change": 0.8}
            ]
        },
        "no_package": {
            "text": "Then you have no business with the Bank Teller. Move along.",
            "options": [
                {"text": "Alright.", "next": "exit"}
            ]
        },
        "forget_room": {
            "text": "You don't remember your own room number? That's suspicious. Come with me for verification.",
            "options": [
                {"text": "Actually, it's Room 306.", "next": "correct_room", "suspicion_change": 0.2},
                {"text": "I'm not going anywhere.", "next": "game_over", "suspicion_change": 1.0},
                {"text": "Alright, I'll come with you.", "next": "brig", "suspicion_change": 0.8}
            ]
        },
        "curious": {
            "text": "Curiosity can be dangerous during a security situation. I suggest you return to your room until the lockdown is lifted.",
            "options": [
                {"text": "I'll do that.", "next": "exit"},
                {"text": "I have things to do.", "next": "insist", "suspicion_change": 0.3}
            ]
        },
        "insist": {
            "text": "Your insistence is noted. Move along, and avoid restricted areas.",
            "options": [
                {"text": "Will do.", "next": "exit"}
            ]
        },
        "brig": {
            "text": "Smart choice. This way to the brig.",
            "options": [
                {"text": "OK.", "next": "brig_transition"}
            ]
        },
        "brig_transition": {
            "text": "You are escorted to the security brig...",
            "options": [
                {"text": "...", "next": "exit"}
            ]
        },
        "game_over": {
            "text": "You've been identified as a threat. Guards, seize this person!",
            "options": [
                {"text": "...", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Move along, citizen.",
            "options": []
        }
    }

# Override choose_dialog_option to handle game over
func choose_dialog_option(option_index):
    var dialog = get_current_dialog()
    if dialog and option_index < dialog.options.size():
        var option = dialog.options[option_index]
        
        # Handle game over
        if current_dialog_node == "game_over":
            # Here you would trigger game over
            print("GAME OVER - Player has been captured!")
            # For now, just print a message
        
        # Handle brig transition
        if current_dialog_node == "brig_transition":
            # Here you would transition to the brig scene
            print("Player has been taken to the brig!")
            # For now, just print a message
        
        # Call parent method to handle the rest
        return .choose_dialog_option(option_index)
    return null
