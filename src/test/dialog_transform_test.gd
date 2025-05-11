extends Node

# This is a simple test script for the dialog transformation
# Run with: godot -s dialog_transform_test.gd

# Mock BaseNPC for testing
class MockNPC:
    var npc_name = "Test NPC"
    var is_assimilated = true
    
    # Copy of the transform function from base_npc.gd
    func transform_dialog_for_assimilation(original_text):
        var transformed_text = original_text
        
        # 1. Replace casual contractions with formal speech
        transformed_text = transformed_text.replace("don't", "do not")
        transformed_text = transformed_text.replace("can't", "cannot")
        transformed_text = transformed_text.replace("won't", "will not")
        transformed_text = transformed_text.replace("I'm", "I am")
        transformed_text = transformed_text.replace("you're", "you are")
        transformed_text = transformed_text.replace("we're", "we are")
        transformed_text = transformed_text.replace("they're", "they are")
        transformed_text = transformed_text.replace("isn't", "is not")
        transformed_text = transformed_text.replace("aren't", "are not")
        transformed_text = transformed_text.replace("wasn't", "was not")
        transformed_text = transformed_text.replace("weren't", "were not")
        transformed_text = transformed_text.replace("I'll", "I will")
        transformed_text = transformed_text.replace("you'll", "you will")
        transformed_text = transformed_text.replace("we'll", "we will")
        transformed_text = transformed_text.replace("they'll", "they will")
        
        # 2. Add subtle collective references
        transformed_text = transformed_text.replace("I think", "we believe")
        transformed_text = transformed_text.replace("I believe", "we believe")
        transformed_text = transformed_text.replace("in my opinion", "in our assessment")
        transformed_text = transformed_text.replace("my opinion", "our assessment")
        transformed_text = transformed_text.replace("I feel", "we feel") 
        transformed_text = transformed_text.replace("I know", "we know")
        transformed_text = transformed_text.replace("I want", "we want")
        transformed_text = transformed_text.replace("I need", "we need")
        
        # 3. Add slight formal/technical terminology
        transformed_text = transformed_text.replace(" good ", " optimal ")
        transformed_text = transformed_text.replace(" bad ", " non-optimal ")
        transformed_text = transformed_text.replace(" great ", " superior ")
        transformed_text = transformed_text.replace(" terrible ", " highly inefficient ")
        transformed_text = transformed_text.replace(" people ", " individuals ")
        transformed_text = transformed_text.replace(" person ", " individual ")
        transformed_text = transformed_text.replace(" everyone ", " all individuals ")
        transformed_text = transformed_text.replace(" place ", " location ")
        transformed_text = transformed_text.replace(" help ", " assist ")
        transformed_text = transformed_text.replace(" look ", " observe ")
        transformed_text = transformed_text.replace(" see ", " observe ")
        transformed_text = transformed_text.replace(" understand ", " comprehend ")
        transformed_text = transformed_text.replace(" know ", " are aware of ")
        
        # 4. Add occasional mild glitches or repetitions (with seed based on NPC name for consistency)
        seed(npc_name.hash())
        
        # Occasional word repetition
        if randf() < 0.3:  # 30% chance
            var words = transformed_text.split(" ")
            if words.size() > 4:
                var random_index = randi() % (words.size() - 3) + 2
                words.insert(random_index, words[random_index-1])  # Repeat a word
                transformed_text = PoolStringArray(words).join(" ")
        
        # Occasional unusual pauses
        if randf() < 0.25:  # 25% chance
            var words = transformed_text.split(" ")
            if words.size() > 3:
                var random_index = randi() % (words.size() - 2) + 1
                words[random_index] = words[random_index] + "... "  # Add pause
                transformed_text = PoolStringArray(words).join(" ")
        
        # Reset random seed
        randomize()
        
        return transformed_text

# Test the dialog transformation
func _ready():
    print("=== Dialog Transformation Test ===")
    var npc = MockNPC.new()
    
    # Test cases
    var test_cases = [
        "I don't know what you're talking about.",
        "I'll help you if I can't find it myself.",
        "I think this is a good place for everyone.",
        "In my opinion, people aren't going to like this.",
        "I feel that we're making great progress here.",
        "I know that I'll understand if you look at the terrible situation."
    ]
    
    # Test each dialog line
    for i in range(test_cases.size()):
        var original = test_cases[i]
        var transformed = npc.transform_dialog_for_assimilation(original)
        
        print("\nTest Case " + str(i+1) + ":")
        print("Original: " + original)
        print("Transformed: " + transformed)
        
        # Verify key transformations
        var changes = []
        if original.find("don't") >= 0 and transformed.find("do not") >= 0:
            changes.append("Contracted 'don't' → 'do not'")
        if original.find("I think") >= 0 and transformed.find("we believe") >= 0:
            changes.append("Personal 'I think' → collective 'we believe'")
        if original.find(" good ") >= 0 and transformed.find(" optimal ") >= 0:
            changes.append("Common 'good' → technical 'optimal'")
        
        print("Detected changes: " + str(changes))
    
    print("\n=== Test Complete ===")
    
    # Exit script
    get_tree().quit()