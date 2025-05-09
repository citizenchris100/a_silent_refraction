extends "res://src/characters/npc/base_npc.gd"

var has_package = true

func _ready():
    npc_name = "Concierge"
    description = "The concierge of the Barracks, dressed in a neat uniform."
    is_assimilated = false
    
    # Call parent _ready
    ._ready()
    
    # Set visual color
    if visual_sprite is ColorRect:
        visual_sprite.color = Color(0.2, 0.8, 0.2)  # Green

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
            # TODO: Add the package to the player's inventory when inventory system is ready
            print("Concierge package added to inventory")
        
        # Call parent method to handle the rest
        return .choose_dialog_option(option_index)
    return null

# Override update_dialog_for_suspicion method to modify dialog based on suspicion tier
func update_dialog_for_suspicion():
    # Store the current dialog node to restore after updating
    var current_node = current_dialog_node

    # Initialize base dialog tree
    initialize_dialog()

    # Modify dialog based on current suspicion tier
    match current_suspicion_tier:
        "low":
            # Slightly cautious but still helpful
            dialog_tree["root"]["text"] = "Yes? How can I help you today? *adjusts collar nervously*"
            # Add a new suspicious option
            dialog_tree["station_info"]["options"].append({
                "text": "Are you feeling alright?",
                "next": "feeling_alright",
                "suspicion_change": -0.1
            })
            # Add the new dialog node
            dialog_tree["feeling_alright"] = {
                "text": "Me? Yes, of course. Just a bit tired. These long shifts, you know...",
                "options": [
                    {"text": "I understand.", "next": "exit"},
                    {"text": "You seem nervous.", "next": "seem_nervous", "suspicion_change": 0.1}
                ]
            }
            dialog_tree["seem_nervous"] = {
                "text": "No, not at all. I should get back to work now.",
                "options": [
                    {"text": "Alright then.", "next": "exit"}
                ]
            }

        "medium":
            # More visibly uncomfortable
            dialog_tree["root"]["text"] = "Hello... um, is there something specific you need? I'm rather busy."
            # Modify existing responses to be more curt
            for node in ["checkin", "station_info", "suspicious"]:
                if dialog_tree.has(node):
                    dialog_tree[node]["text"] += " *glances at security camera*"

            # Make package delivery less likely
            if dialog_tree.has("package"):
                dialog_tree["package"]["options"] = [
                    {"text": "I'll deliver it for you.", "next": "give_package", "suspicion_change": -0.3},
                    {"text": "Sorry, I can't help.", "next": "exit", "suspicion_change": 0.0}
                ]

        "high", "critical":
            # When concierge becomes highly suspicious, he will refuse to talk
            dialog_tree = {
                "root": {
                    "text": "I'm sorry, I'm very busy right now and can't talk. *calls someone on communicator*",
                    "options": [
                        {"text": "Alright.", "next": "exit"},
                        {"text": "Who are you calling?", "next": "calling", "suspicion_change": 0.2}
                    ]
                },
                "calling": {
                    "text": "Just checking with my supervisor about... something. Please excuse me.",
                    "options": [
                        {"text": "I'll leave you to it.", "next": "exit"}
                    ]
                },
                "exit": {
                    "text": "Security will be doing rounds soon. Good day.",
                    "options": []
                }
            }

    # If we were in the middle of a conversation, try to restore the node
    # but fall back to root if the node no longer exists in the modified tree
    current_dialog_node = current_node if dialog_tree.has(current_node) else "root"

# Override become_suspicious for when suspicion crosses the main threshold
func become_suspicious():
    print(npc_name + " has become highly suspicious of the player!")
    update_dialog_for_suspicion()

    # If currently in dialog, update the dialog immediately
    if current_state == State.TALKING:
        var dialog_manager = _find_dialog_manager()
        if dialog_manager and is_instance_valid(dialog_manager):
            # Use a small delay to ensure dialog tree is updated first
            yield(get_tree().create_timer(0.1), "timeout")
            if is_instance_valid(dialog_manager):
                dialog_manager.show_dialog(self)
