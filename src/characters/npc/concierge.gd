extends "res://src/characters/npc/base_npc.gd"

var has_package = true

func _ready():
    npc_name = "Concierge"
    description = "The concierge of the Barracks, dressed in a neat uniform."
    is_assimilated = false
    
    # Call parent _ready
    ._ready()

# Override dialog initialization
func initialize_dialog():
    dialog_tree = {
        "root": {
            "text": "Welcome to the Barracks. How may I assist you today?",
            "options": [
                {"text": "I'm just checking in.", "next": "checkin", "suspicion_change": -0.1},
                {"text": "What's happening on the station?", "next": "station_info"},
                {"text": "Nothing, thanks.", "next": "exit"}
            ]
        },
        "checkin": {
            "text": "Ah yes, Mr. Alex. Your room is 306 on the third floor. Is there anything else?",
            "options": [
                {"text": "Could you tell me about the station?", "next": "station_info"},
                {"text": "No, that's all.", "next": "exit"}
            ]
        },
        "station_info": {
            "text": "The station is currently on lockdown. No ships in or out until further notice. Security says it's just a routine drill, but...",
            "options": [
                {"text": "But what?", "next": "suspicious", "suspicion_change": -0.2},
                {"text": "I'm sure it's nothing.", "next": "agree", "suspicion_change": 0.1},
                {"text": "Thanks for the info.", "next": "exit"}
            ]
        },
        "suspicious": {
            "text": "Well... I've noticed some strange behavior from several station personnel lately. They seem... different. Like they're not themselves.",
            "options": [
                {"text": "How so?", "next": "explain_suspicions", "suspicion_change": -0.2},
                {"text": "You're being paranoid.", "next": "paranoid", "suspicion_change": 0.2},
                {"text": "I see.", "next": "exit"}
            ]
        },
        "explain_suspicions": {
            "text": "They move differently. Speak differently. And they all seem to be working together on something. I've overheard some of them mentioning 'assimilation'.",
            "options": [
                {"text": "That sounds concerning.", "next": "package", "suspicion_change": -0.3},
                {"text": "I'm sure there's a reasonable explanation.", "next": "agree", "suspicion_change": 0.2},
                {"text": "Interesting. I need to go.", "next": "exit"}
            ]
        },
        "package": {
            "text": "Listen, could you do me a favor? I have a package that needs to be delivered to the Bank Teller in the Trading Floor district. I can't leave my post.",
            "options": [
                {"text": "I'll deliver it for you.", "next": "give_package", "suspicion_change": -0.2},
                {"text": "Why can't you use the normal delivery service?", "next": "delivery_service", "suspicion_change": -0.1},
                {"text": "Sorry, I can't help.", "next": "exit", "suspicion_change": 0.1}
            ]
        },
        "give_package": {
            "text": "Thank you! Here's the package. Please take it to the Bank Teller as soon as possible. It's important.",
            "options": [
                {"text": "I'll head there now.", "next": "exit"}
            ]
        },
        "delivery_service": {
            "text": "I don't trust the regular channels right now. Something strange is happening, and I need someone I can trust.",
            "options": [
                {"text": "Alright, I'll take it.", "next": "give_package", "suspicion_change": -0.2},
                {"text": "Sorry, I can't help.", "next": "exit", "suspicion_change": 0.1}
            ]
        },
        "agree": {
            "text": "Yes, you're probably right. Sorry to bother you with my concerns.",
            "options": [
                {"text": "No problem.", "next": "exit"}
            ]
        },
        "paranoid": {
            "text": "Perhaps you're right. I should focus on my duties.",
            "options": [
                {"text": "Good idea.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Have a pleasant stay on the station.",
            "options": []
        }
    }

# Override choose_dialog_option to handle package giving
func choose_dialog_option(option_index):
    var dialog = get_current_dialog()
    if dialog and option_index < dialog.options.size():
        var option = dialog.options[option_index]
        
        # If giving package
        if current_dialog_node == "give_package" and has_package:
            has_package = false
            # Here you would add the package to the player's inventory
            # For now, just print a message
            print("Concierge package added to inventory")
        
        # Call parent method to handle the rest
        return .choose_dialog_option(option_index)
    return null

# Override become_suspicious
func become_suspicious():
    # When concierge becomes suspicious, he will refuse to talk
    dialog_tree = {
        "root": {
            "text": "I'm sorry, I'm very busy right now and can't talk.",
            "options": [
                {"text": "Alright.", "next": "exit"}
            ]
        },
        "exit": {
            "text": "Good day.",
            "options": []
        }
    }
    
    print(npc_name + " has become suspicious!")
