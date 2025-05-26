# Trading Floor Mini-Game System Design

## Overview

The Trading Floor Mini-Game is a Tetris-style block game that serves as the core mechanic for the trader job in the Financial District. Unlike other jobs that involve point-and-click interactions in the game world, this job transports players into a retro Game Boy-style mini-game where their performance directly translates to in-game credits.

## Design Philosophy

- **KISS Principle**: Simple implementation over complex features
- **Retro Aesthetic**: Authentic Game Boy feel without overdoing effects
- **Performance-Based Pay**: Direct score-to-credits conversion
- **Gender Integration**: Harassment and bias affect gameplay
- **Time Management**: Playing consumes in-game time

## Visual Design

### Game Boy Aesthetic
```gdscript
# Shader for Game Boy look
shader_type canvas_item;

uniform vec4 color_darkest = vec4(0.06, 0.22, 0.06, 1.0);   // Dark green
uniform vec4 color_dark = vec4(0.19, 0.38, 0.19, 1.0);      // Medium dark
uniform vec4 color_light = vec4(0.55, 0.67, 0.06, 1.0);     // Light green
uniform vec4 color_lightest = vec4(0.74, 0.89, 0.42, 1.0);  // Pea green

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    // 4-color quantization
    if (gray < 0.25) {
        COLOR = color_darkest;
    } else if (gray < 0.5) {
        COLOR = color_dark;
    } else if (gray < 0.75) {
        COLOR = color_light;
    } else {
        COLOR = color_lightest;
    }
}
```

### Resolution
- Game renders at 160x144 (original Game Boy resolution)
- Scaled up 4x for modern displays (640x576)
- Pixel-perfect rendering maintained

## Game Mechanics

### Core Gameplay
Based on classic block-falling games:

```gdscript
class_name BlockTrader
extends Node2D

# Game constants
const GRID_WIDTH = 10
const GRID_HEIGHT = 18
const BLOCK_SIZE = 8  # Pixels
const FALL_SPEED_BASE = 1.0
const SCORE_PER_LINE = 100

# Game state
var grid: Array = []  # 2D array of blocks
var current_piece: TradingBlock
var next_piece: TradingBlock
var score: int = 0
var lines_cleared: int = 0
var level: int = 1
var fall_timer: float = 0.0
var game_active: bool = false

# Gender modifiers
var gender_modifier: float = 1.0
var harassment_active: bool = false

func _ready():
    _initialize_grid()
    _apply_gender_effects()
    _spawn_next_piece()

func _initialize_grid():
    grid = []
    for y in range(GRID_HEIGHT):
        var row = []
        for x in range(GRID_WIDTH):
            row.append(null)
        grid.append(row)

func _apply_gender_effects():
    # Female players face additional challenges
    if GameManager.player_gender == "female":
        gender_modifier = JobWorkQuestSystem.get_gender_modifier(JobType.TRADER)
        
        # Harassment events affect gameplay
        if randf() < 0.3:
            harassment_active = true
            # Randomly obscure parts of the screen
            _trigger_harassment_effect()

func _process(delta):
    if not game_active:
        return
    
    # Handle input
    _process_input()
    
    # Fall logic
    fall_timer += delta * _get_fall_speed()
    if fall_timer >= 1.0:
        fall_timer = 0.0
        _move_piece_down()
    
    # Check for completed lines
    _check_lines()
    
    # Update score display
    _update_score_display()

func _get_fall_speed() -> float:
    var speed = FALL_SPEED_BASE + (level - 1) * 0.5
    
    # Gender modifier affects difficulty
    if gender_modifier < 1.0:
        speed *= 1.2  # Faster falling for women (harder)
    
    return speed

func _check_lines():
    var lines_to_clear = []
    
    for y in range(GRID_HEIGHT):
        var full = true
        for x in range(GRID_WIDTH):
            if grid[y][x] == null:
                full = false
                break
        
        if full:
            lines_to_clear.append(y)
    
    if lines_to_clear.size() > 0:
        _clear_lines(lines_to_clear)
        _calculate_score(lines_to_clear.size())

func _calculate_score(lines: int):
    var base_score = lines * SCORE_PER_LINE * level
    
    # Apply gender modifier to score
    var final_score = int(base_score * gender_modifier)
    
    score += final_score
    lines_cleared += lines
    
    # Level up every 10 lines
    if lines_cleared >= level * 10:
        level += 1
        _show_level_up()
```

### Block Types
```gdscript
enum BlockType {
    I_PIECE,  # Straight line
    O_PIECE,  # Square
    T_PIECE,  # T-shape
    S_PIECE,  # S-shape
    Z_PIECE,  # Z-shape
    L_PIECE,  # L-shape
    J_PIECE   # J-shape
}

class TradingBlock:
    var type: int
    var rotation: int = 0
    var position: Vector2
    var color_index: int  # For Game Boy palette
    
    func get_shape() -> Array:
        # Return 2D array representing block shape
        match type:
            BlockType.I_PIECE:
                return _get_i_shape(rotation)
            BlockType.O_PIECE:
                return [[1,1],[1,1]]  # No rotation needed
            # ... etc
```

### Harassment Effects
```gdscript
func _trigger_harassment_effect():
    # Different harassment types affect gameplay
    var effect_type = randi() % 3
    
    match effect_type:
        0:  # "Helpful" colleague blocks view
            var overlay = preload("res://src/minigame/harassment_overlay.tscn").instance()
            overlay.show_text("Let me show you how it's done...")
            add_child(overlay)
            # Blocks portion of screen for 5 seconds
            
        1:  # Patronizing explanation slows input
            input_delay = 0.3  # 300ms input lag
            show_notification("A colleague is explaining basic math to you...")
            
        2:  # Credit theft reduces score
            score_multiplier = 0.7
            show_notification("Your scores are being attributed to male colleagues...")
```

## UI Flow

### Main Terminal Screen
```gdscript
class TradingTerminal extends Control:
    onready var main_menu = $MainMenu
    onready var game_screen = $GameScreen
    onready var leaderboard = $Leaderboard
    
    func _ready():
        _apply_gameboy_theme()
        _show_main_menu()
    
    func _show_main_menu():
        main_menu.visible = true
        game_screen.visible = false
        
        # Menu options
        main_menu.add_option("PLAY GAME", "_start_game")
        main_menu.add_option("LEADERBOARD", "_show_leaderboard")
        main_menu.add_option("PRACTICE MODE", "_start_practice")
        main_menu.add_option("EXIT TERMINAL", "_exit_terminal")
    
    func _show_leaderboard():
        leaderboard.visible = true
        leaderboard.display_scores(TradingLeaderboard.get_entries())
        
        # Show player's best score if exists
        var player_best = SaveManager.get_trader_high_score()
        if player_best > 0:
            leaderboard.highlight_score(player_best)
```

### Game Screen Layout
```
+---------------------------+
|  SCORE: 00000  LEVEL: 01  |
|                           |
|  +--------+  NEXT:        |
|  |        |  +--+         |
|  | GAME   |  |  |         |
|  | AREA   |  +--+         |
|  |        |               |
|  |        |  LINES: 000   |
|  |        |               |
|  +--------+  TIME: 03:45  |
|                           |
|  [HARASSMENT MSG HERE]    |
+---------------------------+
```

## Score System

### Base Scoring
```gdscript
const SCORING_TABLE = {
    "single": 100,
    "double": 300,
    "triple": 500,
    "tetris": 800,
    "soft_drop": 1,  # Per line
    "hard_drop": 2   # Per line
}

func calculate_line_score(lines: int, level: int) -> int:
    var base = 0
    
    match lines:
        1: base = SCORING_TABLE.single
        2: base = SCORING_TABLE.double
        3: base = SCORING_TABLE.triple
        4: base = SCORING_TABLE.tetris
    
    return base * level
```

### Pay Calculation
```gdscript
func calculate_shift_pay(total_score: int, shift_data: ShiftData) -> int:
    # Check minimum score requirement
    if total_score < shift_data.minimum_score:
        return 0
    
    # Linear conversion
    var credits = total_score * shift_data.score_to_credits
    
    # Apply shift-specific modifiers
    if shift_data.pay_modifier:
        credits *= shift_data.pay_modifier
    
    # Apply gender-based pay reduction if applicable
    if shift_data.incidents.has("credit_theft"):
        credits *= 0.7  # 30% stolen by male colleagues
    
    return int(credits)
```

## Time Management

```gdscript
# Time conversion constants
const REAL_SECONDS_PER_GAME_MINUTE = 4.0  # 1 real second = 15 game minutes

func _on_game_tick(delta: float):
    # Advance game time while playing
    var game_minutes = delta / REAL_SECONDS_PER_GAME_MINUTE
    TimeManager.advance_time(game_minutes)
    
    # Update time display
    time_label.text = "TIME: %02d:%02d" % [
        TimeManager.get_current_hour(),
        TimeManager.get_current_minute()
    ]
    
    # Check for shift end
    if TimeManager.get_current_minutes() >= current_shift.end_time:
        _force_end_game("Shift Complete!")
```

## Persistence

### Save Data
```gdscript
# In TradingFloorSerializer
func serialize_minigame_data() -> Dictionary:
    return {
        "high_score": player_high_score,
        "total_games_played": games_played,
        "total_earnings": lifetime_earnings,
        "leaderboard_position": current_leaderboard_position,
        "harassment_incidents": harassment_count,
        "gender_penalties_applied": gender_penalty_total
    }
```

### Leaderboard Persistence
```gdscript
func save_leaderboard():
    var data = {
        "entries": [],
        "last_evolution_day": TimeManager.current_day
    }
    
    for entry in leaderboard.entries:
        data.entries.append({
            "name": entry.name,
            "score": entry.score,
            "date": entry.date,
            "is_player": entry.get("is_player", false)
        })
    
    SaveManager.save_minigame_data("trader_leaderboard", data)
```

## Performance Considerations

1. **Rendering**: Use viewport scaling to maintain pixel-perfect graphics
2. **Input**: Process input in _unhandled_input for responsive controls
3. **Memory**: Reuse block instances rather than creating new ones
4. **Effects**: Keep visual effects simple (KISS principle)

## Integration Points

1. **Job System**: Launched via JobWorkQuestSystem.start_trader_shift()
2. **Time Manager**: Consumes game time while playing
3. **Gender System**: Modifiers and harassment events affect gameplay
4. **Save System**: High scores and progress persist between sessions
5. **UI Manager**: Replaces main game UI while active

## Implementation Notes

1. Start with basic Tetris mechanics
2. Add Game Boy visual style
3. Implement score-to-credits conversion
4. Add gender modifiers and harassment events
5. Create leaderboard system
6. Integrate with job shift system
7. Add time consumption mechanics
8. Implement save/load functionality

The system prioritizes simplicity while maintaining the 1950s gender dynamics theme and providing a fun, retro mini-game experience that serves as both a money-making mechanic and a commentary on workplace discrimination.