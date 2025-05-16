extends Reference

# Command System for Debug Console
# Provides a structured approach to registering, categorizing, and executing debug commands

# Command structure:
# {
#   "name": "command_name",
#   "category": "category_name",
#   "description": "Command description",
#   "usage": "command_name <arg1> <arg2>",
#   "function": FuncRef,
#   "aliases": ["alias1", "alias2"],
#   "subcommands": [
#     {
#       "name": "subcommand_name",
#       "description": "Subcommand description",
#       "usage": "command_name subcommand_name [args]"
#     }
#   ]
# }

# Categories for commands
enum CommandCategory {
    GENERAL,    # Basic console commands
    DEBUG,      # Debug tool commands
    SCENE,      # Scene management
    CAMERA,     # Camera control
    ENTITY,     # Entity spawning/manipulation
    SYSTEM,     # System/engine commands
    DEVELOPMENT # Development-only commands
}

# Registered commands storage
var commands = {}
var aliases = {}
var categories = {}

# Initialize with default categories
func _init():
    # Setup categories with display names
    categories[CommandCategory.GENERAL] = "General"
    categories[CommandCategory.DEBUG] = "Debug Tools"
    categories[CommandCategory.SCENE] = "Scene Management"
    categories[CommandCategory.CAMERA] = "Camera Control"
    categories[CommandCategory.ENTITY] = "Entity Management"
    categories[CommandCategory.SYSTEM] = "System Commands"
    categories[CommandCategory.DEVELOPMENT] = "Development"
    
    # Initialize command storage for each category
    for category in categories:
        commands[category] = {}

# Register a command with the system
func register_command(name, function_ref, description="", usage="", category=CommandCategory.GENERAL, aliases_array=[]):
    # Validate inputs
    if name.empty():
        push_error("Command name cannot be empty")
        return false
    
    if not categories.has(category):
        push_error("Invalid command category: " + str(category))
        return false
    
    if not function_ref or not function_ref is FuncRef:
        push_error("Invalid function reference for command: " + name)
        return false
    
    # Create command data structure
    var command = {
        "name": name,
        "category": category,
        "description": description,
        "usage": usage if not usage.empty() else name,
        "function": function_ref,
        "aliases": aliases_array,
        "subcommands": []  # Initialize empty subcommands array
    }
    
    # Store command by category
    commands[category][name] = command
    
    # Register aliases
    for alias in aliases_array:
        aliases[alias] = name
    
    print("Registered command '" + name + "' in category '" + categories[category] + "'")
    return true
    
# Register a subcommand for an existing command
func register_subcommand(command_name, subcommand_name, description="", usage=""):
    # Get the parent command
    var command = get_command(command_name)
    if command == null:
        push_error("Cannot register subcommand for non-existent command: " + command_name)
        return false
    
    # Create subcommand data structure
    var subcommand = {
        "name": subcommand_name,
        "description": description,
        "usage": usage if not usage.empty() else command_name + " " + subcommand_name
    }
    
    # Add to parent command's subcommands array
    command.subcommands.append(subcommand)
    
    print("Registered subcommand '" + subcommand_name + "' for command '" + command_name + "'")
    return true

# Get a command by name, checking aliases if needed
func get_command(name):
    # First check if this is an alias
    if aliases.has(name):
        name = aliases[name]
    
    # Look through all categories for this command
    for category in commands:
        if commands[category].has(name):
            return commands[category][name]
    
    # Command not found
    return null

# Execute a command by name with arguments
func execute(name, args=[]):
    # Get the command
    var command = get_command(name)
    if command == null:
        return "Unknown command: " + name + "\nType 'help' for available commands."
    
    # Execute the command function
    return command.function.call_func(args)

# Get all commands in a specific category
func get_commands_by_category(category):
    if not commands.has(category):
        return []
    
    return commands[category].values()

# Get all registered commands across all categories
func get_all_commands():
    var all_commands = []
    for category in commands:
        all_commands.append_array(commands[category].values())
    return all_commands

# Get commands by partial name match (for autocomplete)
func get_commands_by_partial_name(partial_name):
    var matching = []
    var all_cmds = get_all_commands()
    
    for cmd in all_cmds:
        if cmd.name.begins_with(partial_name):
            matching.append(cmd)
        else:
            # Check aliases too
            for alias in cmd.aliases:
                if alias.begins_with(partial_name):
                    matching.append(cmd)
                    break
    
    return matching

# Generate help text for a specific command
func get_command_help(name):
    var command = get_command(name)
    if command == null:
        return "No help available for unknown command: " + name
    
    var help_text = command.name + " - " + command.description + "\n"
    help_text += "Usage: " + command.usage + "\n"
    
    if command.aliases.size() > 0:
        help_text += "Aliases: " + PoolStringArray(command.aliases).join(", ") + "\n"
    
    help_text += "Category: " + categories[command.category] + "\n"
    
    # Show subcommands if any
    if command.subcommands.size() > 0:
        help_text += "\nSubcommands:\n"
        for subcommand in command.subcommands:
            help_text += "  %-15s - %s\n" % [subcommand.name, subcommand.description]
            if "usage" in subcommand and subcommand.usage:
                help_text += "    Usage: %s\n" % subcommand.usage
    
    return help_text

# Generate help overview for all commands, organized by category
func get_help_overview(show_subcommands=false):
    var help_text = "Available Commands:\n\n"
    
    for category in categories:
        if commands[category].size() > 0:
            help_text += "=== " + categories[category] + " ===\n"
            
            for command_name in commands[category]:
                var command = commands[category][command_name]
                help_text += "  %-15s - %s\n" % [command.name, command.description]
                
                # Optionally show subcommands
                if show_subcommands and command.subcommands.size() > 0:
                    for subcommand in command.subcommands:
                        help_text += "    %-12s - %s\n" % [command.name + " " + subcommand.name, subcommand.description]
            
            help_text += "\n"
    
    help_text += "Type 'help <command>' for detailed information on a specific command."
    
    return help_text

# Generate usage example for a command
func get_command_usage(name):
    var command = get_command(name)
    if command == null:
        return "Unknown command: " + name
    
    return "Usage: " + command.usage