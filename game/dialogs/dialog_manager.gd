extends Node

signal dialog_finished

# Dialog data structure:
# {
#   "dialog_id": {
#     "questions": [
#       {
#         "id": "question_id",
#         "text": "Question text",
#         "suspicion_increase": 0.1,
#         "trust_consequences": {
#           "high_trust": 0.1,
#           "medium_trust": 0.0,
#           "low_trust": -0.1
#         },
#         "reveals_assimilation": false
#       }
#     ],
#     "responses": {
#       "question_id": {
#         "assimilated": {
#           "text": "Response if NPC is assimilated",
#           "tells": ["subtle_hint", "contradicts_human_behavior"],
#           "suspicion_of_player_increase": 0.2
#         },
#         "normal": {
#           "text": "Response if NPC is normal",
#           "tells": [],
#           "suspicion_of_player_increase": 0.0
#         }
#       }
#     }
#   }
# }

var dialogs = {}
var current_dialog_id = ""
var current_npc = null

func _ready():
    # Load all dialog files
    var dir = DirAccess.open("res://game/dialogs/data")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if file_name.ends_with(".json"):
                var dialog_data = load_dialog_file("res://game/dialogs/data/" + file_name)
                if dialog_data:
                    var dialog_id = file_name.get_basename()
                    dialogs[dialog_id] = dialog_data
            file_name = dir.get_next()

func load_dialog_file(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    if file:
        var json_text = file.get_as_text()
        var json = JSON.new()
        var error = json.parse(json_text)
        if error == OK:
            return json.get_data()
    return {}

func start_dialog(dialog_id: String, npc_node) -> void:
    if dialog_id in dialogs:
        current_dialog_id = dialog_id
        current_npc = npc_node
        # Emit signal to update UI
        escoria.run_esc_script("show_dialog_ui", [dialog_id])
    else:
        push_error("Dialog not found: " + dialog_id)

func ask_question(question_id: String) -> Dictionary:
    if current_dialog_id == "" or current_npc == null:
        return {}
        
    var dialog_data = dialogs[current_dialog_id]
    if not "responses" in dialog_data or not question_id in dialog_data.responses:
        return {}
        
    # Get the appropriate response based on whether NPC is assimilated
    var response_key = "assimilated" if current_npc.is_assimilated else "normal"
    var response = dialog_data.responses[question_id][response_key]
    
    # Apply suspicion increase to player
    current_npc.suspicion_level += response.suspicion_of_player_increase
    
    # Find the question data to apply trust and suspicion changes
    for question in dialog_data.questions:
        if question.id == question_id:
            # Apply suspicion increase to NPC
            current_npc.suspicion_level += question.suspicion_increase
            
            # Apply trust consequences based on current trust level
            var trust_change = 0.0
            if current_npc.trust_level >= 0.7:
                trust_change = question.trust_consequences.high_trust
            elif current_npc.trust_level >= 0.3:
                trust_change = question.trust_consequences.medium_trust
            else:
                trust_change = question.trust_consequences.low_trust
                
            current_npc.trust_level += trust_change
            
            # If this question can reveal assimilation, record that
            if question.reveals_assimilation and current_npc.is_assimilated:
                # Add some evidence that this NPC might be assimilated
                escoria.get_global("player_knowledge").add_assimilation_evidence(current_npc.global_id)
            
            break
            
    return response

func end_dialog() -> void:
    current_dialog_id = ""
    current_npc = null
    emit_signal("dialog_finished")
