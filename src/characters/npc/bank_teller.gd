extends "res://src/characters/npc/base_npc.gd"

var has_received_package = false
var has_return_package = true

func _ready():
    npc_name = "Bank Teller"
    description = "A professional-looking bank teller behind the counter."
    is_assimilated = false
    
    # Call parent _ready
    ._ready()

# Override dialog initialization
func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Welcome to the Station Bank. How may I assist you today?",
            "options": [
                {"text": "I need to make a withdrawal.", "next": "withdrawal"},
                {"text": "I have a package for you from the Concierge.", "next": "package_delivery", "suspicion_change": -0.2},
                {"text": "Just looking around.", "next": "exit"}
            ]
        },
        "withdrawal": {
            "text": "I'm sorry, all financial transactions are suspended during the lockdown. Station policy.",
            "options": [
                {"text": "What about the package from the Concierge?", "next": "package_delivery", "suspicion_change": -0.2},
                {"text": "I understand.", "next": "exit"}
            ]
        },
        "package_delivery": {
            "text": "Ah, you have the package from the Concierge? Thank you.",
            "options": [
                {"text": "Here it is.", "next": "receive_package", "suspicion_change": -0.3},
                {"text": "Actually, I don't have it yet.", "next": "no_package", "suspicion_change": 0.2}
            ]
        },
        "receive_package": {
            "text": "Thank you. This is very important. In return, could you take this back to the Concierge? It's equally important.",
            "options": [
                {"text": "Of course.", "next": "give_return_package", "suspicion_change": -0.2},
                {"text": "What's so important about these packages?", "next": "important_question", "suspicion_change": -0.1},
                {"text": "I'd rather not.", "next": "exit", "suspicion_change": 0.2}
            ]
        },
        "no_package": {
            "text": "Oh, I see. Please come back when you have it. It's very important.",
            "options": [
                {"text": "I'll get it to you.", "next": "exit"},
                {"text": "What's in the package?", "next": "whats_inside", "suspicion_change": 0.1}
            ]
        },
        "important_question": {
            "text": "Let's just say some of us are concerned about recent... changes on the station. We're trying to understand what's happening.",
            "options": [
                {"text": "I'll take the return package.", "next": "give_return_package", "suspicion_change": -0.2},
                {"text": "What kind of changes?", "next": "explain_changes", "suspicion_change": -0.1}
            ]
        },
        "explain_changes": {
            "text": "People are acting strangely. Security is tighter. And there are rumors of some kind of... assimilation occurring.",
            "options": [
                {"text": "Assimilation?", "next": "assimilation_info", "suspicion_change": -0.2},
                {"text": "I'll take the return package now.", "next": "give_return_package", "suspicion_change": -0.1}
            ]
        },
        "assimilation_info": {
            "text": "People being replaced or controlled somehow. The Concierge and I are part of a group trying to figure out what's happening. The package you delivered contains evidence.",
            "options": [
                {"text": "I want to help.", "next": "offer_help", "suspicion_change": -0.3},
                {"text": "I'll take the return package.", "next": "give_return_package", "suspicion_change": -0.1}
            ]
        },
        "offer_help": {
            "text": "That's good to hear. Take this package back to the Concierge. It contains a key card that might come in handy if you get in trouble.",
            "options": [
                {"text": "Thank you.", "next": "give_return_package", "suspicion_change": -0.2}
            ]
        },
        "give_return_package": {
            "text": "Here you go. Be careful who you trust. Not everyone is who they appear to be.",
            "options": [
                {"text": "I'll be careful.", "next": "exit"}
            ]
        },
        "whats_inside": {
            "text": "That's confidential. Just deliver it as requested.",
            "options": [
                {"text": "Fine.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Have a good day.",
            "options": []
        }
    }

# Override choose_dialog_option to handle package exchange
func choose_dialog_option(option_index):
    var dialog = get_current_dialog()
    if dialog and option_index < dialog.options.size():
        var option = dialog.options[option_index]
        
        # Handle package receiving
        if current_dialog_node == "receive_package" and not has_received_package:
            has_received_package = true
            # Here you would remove the package from player inventory
            print("Concierge package removed from inventory")
        
        # Handle return package giving
        if current_dialog_node == "give_return_package" and has_return_package:
            has_return_package = false
            # Here you would add the return package to player inventory
            print("Bank Teller return package added to inventory")
        
        # Call parent method to handle the rest
        return .choose_dialog_option(option_index)
    return null

# Override become_suspicious
func become_suspicious():
    # When bank teller becomes suspicious, dialog changes
    dialog_tree = {
        "root": {
            "text": "I'm busy with other customers right now.",
            "options": [
                {"text": "Alright.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Next customer, please.",
            "options": []
        }
    }
    
    print(npc_name + " has become suspicious!")
