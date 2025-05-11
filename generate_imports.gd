extends SceneTree

# This script helps generate .import files for animation frames
# Run with: godot --script generate_imports.gd

func _init():
    print("Starting import file generation script")
    
    # Scan for animation frames
    scan_directory("src/assets/backgrounds/animated_elements")
    
    print("Import file generation complete")
    quit()

func scan_directory(path):
    print("Scanning directory: " + path)
    
    var dir = Directory.new()
    if dir.open(path) == OK:
        dir.list_dir_begin(true, true)
        var file_name = dir.get_next()
        
        while file_name != "":
            var full_path = path + "/" + file_name
            
            if dir.current_is_dir():
                # Recursively scan subdirectories
                scan_directory(full_path)
            elif file_name.ends_with(".png") and not file_name.ends_with(".import"):
                # Found a PNG, make sure it has import metadata
                ensure_import_file(full_path)
                
            file_name = dir.get_next()
        
        dir.list_dir_end()
    else:
        print("Could not open directory: " + path)

func ensure_import_file(image_path):
    var import_path = image_path + ".import"
    var dir = Directory.new()
    
    if not dir.file_exists(import_path):
        print("Creating import file for: " + image_path)
        
        # Force the resource to be imported
        var image = load(image_path)
        if image:
            print("Successfully imported: " + image_path)
        else:
            print("Failed to import: " + image_path)
    else:
        print("Import file already exists for: " + image_path)