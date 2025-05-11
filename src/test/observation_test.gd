extends Node

# This is a test script for the observation mechanics
# Run with: godot -s observation_test.gd

# Mock BaseNPC for testing observation mechanics
class MockNPC:
    var npc_name = "Test NPC"
    var npc_id = "test_npc_01"
    var is_assimilated = true
    var known_assimilated = false
    var observation_time = 0.0
    var observation_threshold = 5.0
    var current_dialog_node = "greeting"  # Simulate having talked before
    
    # Simulate complete_observation function
    func complete_observation(detection_probability = 1.0):
        print("=== Observation Test ===")
        print("NPC: " + npc_name)
        print("Is Assimilated: " + str(is_assimilated))
        print("Detection Probability: " + str(detection_probability))
        
        # Success determination
        var success = false
        var detection_detail = ""
        
        # Use a fixed seed for testing
        seed(1234)
        
        if is_assimilated:
            if randf() < detection_probability * 0.8 + 0.1:
                success = true
                known_assimilated = true
                
                # Get detection details
                var clue_roll = randf()
                if clue_roll < 0.4:
                    detection_detail = "Their speech patterns seem oddly formal and they occasionally refer to themselves as 'we'."
                elif clue_roll < 0.7:
                    detection_detail = "You notice a subtle greenish tint to their skin tone."
                else:
                    detection_detail = "They hesitate unnaturally when asked about personal memories."
        
        # Generate result text
        var result_text = ""
        if success:
            result_text = "You notice subtle signs that " + npc_name + " has been assimilated! " + detection_detail
        else:
            if is_assimilated:
                result_text = "You don't notice anything unusual about " + npc_name + ", but something feels off..."
            else:
                result_text = "You don't notice anything unusual about " + npc_name + "."
        
        print("Success: " + str(success))
        print("Result Text: " + result_text)
        print("Known Assimilated: " + str(known_assimilated))
        print("===========================")
        return success

# Test function to simulate multiple observations
func test_multiple_observations():
    var assimilated_npc = MockNPC.new()
    assimilated_npc.is_assimilated = true
    
    var normal_npc = MockNPC.new()
    normal_npc.npc_name = "Normal NPC"
    normal_npc.is_assimilated = false
    
    print("\n=== Testing Detection Probabilities ===")
    
    # Test assimilated NPC detection at different probabilities
    print("\nAssimilated NPC Tests:")
    for prob in [0.2, 0.5, 0.8, 1.0]:
        print("\nTesting with probability: " + str(prob))
        assimilated_npc.complete_observation(prob)
    
    # Test normal NPC
    print("\nNormal NPC Test:")
    normal_npc.complete_observation(1.0)
    
    # Test effect of dialog history
    print("\n=== Testing Dialog History Effect ===")
    var new_npc = MockNPC.new()
    new_npc.npc_name = "New NPC"
    new_npc.is_assimilated = true
    
    # No dialog history
    new_npc.current_dialog_node = "root"
    var base_probability = 0.5
    print("\nWith no dialog history (prob=" + str(base_probability) + "):")
    new_npc.complete_observation(base_probability)
    
    # With dialog history
    new_npc.current_dialog_node = "personal_info"
    var enhanced_probability = base_probability * 1.2
    print("\nWith dialog history (prob=" + str(enhanced_probability) + "):")
    new_npc.complete_observation(enhanced_probability)
    
    print("\n=== Test Complete ===")

# Main entry
func _ready():
    test_multiple_observations()
    get_tree().quit()