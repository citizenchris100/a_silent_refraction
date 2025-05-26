# Tram Transportation System Design

## Overview

The Tram Transportation System is the exclusive method of inter-district travel on the station, creating meaningful time and economic costs for movement. The system enforces strategic planning as players must balance the need to investigate different districts against limited time and money. With no alternative transportation methods, the tram becomes a critical resource that can make or break investigation efforts.

## Core Concepts

### Transportation Philosophy
- **Exclusive access**: Trams are the ONLY way between districts
- **Mandatory costs**: Both time and money required for every trip
- **Distance-based pricing**: Further destinations cost more
- **No shortcuts**: Cannot bypass the tram system
- **Economic pressure**: No money means no travel

### Station Layout
The seven districts form a ring configuration:
1. **Spaceport** - Docking and arrivals
2. **Security** - Law enforcement center  
3. **Medical** - Health services hub
4. **Mall** - Commercial district
5. **Trading Floor** - Financial center
6. **Barracks** - Residential area
7. **Engineering** - Technical maintenance

## System Architecture

### Core Components

#### 1. Tram Manager (Singleton)
```gdscript
# src/core/systems/tram_manager.gd
extends Node

signal tram_ride_started(from_district, to_district)
signal tram_ride_completed(district)
signal tram_ride_failed(reason)
signal route_calculated(time_cost, credit_cost)

# District layout (ring configuration)
const DISTRICTS = [
    "spaceport", "security", "medical", "mall", 
    "trading_floor", "barracks", "engineering"
]

# Base costs
const BASE_FARE = 10  # Credits for adjacent district
const BASE_TIME = 0.5  # 30 minutes for adjacent district

# Current state
var current_district: String = "spaceport"  # Starting location
var in_transit: bool = false
var transit_start_time: float = 0.0

# Pricing modifiers
var surge_pricing: Dictionary = {}  # district: multiplier
var maintenance_delays: Dictionary = {}  # route: delay_hours

func calculate_route(from_district: String, to_district: String) -> Dictionary:
    if from_district == to_district:
        return {"distance": 0, "time": 0.0, "cost": 0}
    
    var from_index = DISTRICTS.find(from_district)
    var to_index = DISTRICTS.find(to_district)
    
    if from_index == -1 or to_index == -1:
        push_error("Invalid district names")
        return {}
    
    # Calculate shortest distance (can go either direction on ring)
    var forward_distance = (to_index - from_index) % DISTRICTS.size()
    var backward_distance = (from_index - to_index) % DISTRICTS.size()
    var distance = min(forward_distance, backward_distance)
    
    # Calculate costs
    var time_cost = BASE_TIME * distance
    var credit_cost = BASE_FARE * distance
    
    # Apply modifiers
    credit_cost = _apply_price_modifiers(credit_cost, from_district, to_district)
    time_cost = _apply_time_modifiers(time_cost, from_district, to_district)
    
    return {
        "distance": distance,
        "time": time_cost,
        "cost": int(credit_cost),
        "route": _get_route_districts(from_index, to_index, distance)
    }

func attempt_tram_ride(destination: String) -> bool:
    if in_transit:
        UI.show_notification("Already in transit!")
        return false
    
    if destination == current_district:
        UI.show_notification("Already at " + destination)
        return false
    
    var route_info = calculate_route(current_district, destination)
    
    # Check if player can afford it
    if not EconomyManager.can_afford(route_info.cost):
        emit_signal("tram_ride_failed", "insufficient_funds")
        UI.show_notification("Need %d credits for tram fare" % route_info.cost)
        return false
    
    # Show confirmation dialog
    var confirmed = yield(_show_travel_confirmation(destination, route_info), "completed")
    
    if not confirmed:
        return false
    
    # Process payment
    if not EconomyManager.spend_credits(route_info.cost, "tram_fare"):
        emit_signal("tram_ride_failed", "payment_failed")
        return false
    
    # Start travel
    _begin_transit(destination, route_info)
    return true

func _begin_transit(destination: String, route_info: Dictionary):
    in_transit = true
    transit_start_time = TimeManager.current_time
    
    emit_signal("tram_ride_started", current_district, destination)
    
    # Show transit UI
    TransitUI.show_transit_screen(current_district, destination, route_info)
    
    # Advance time
    TimeManager.advance_time(route_info.time)
    
    # Random events during travel
    _check_transit_events(route_info)
    
    # Complete travel
    _complete_transit(destination)

func _complete_transit(destination: String):
    current_district = destination
    in_transit = false
    
    # Update player location
    PlayerController.current_district = destination
    DistrictManager.load_district(destination)
    
    # Check for assimilation spread during travel
    AssimilationManager.process_time_passed(
        TimeManager.current_time - transit_start_time
    )
    
    emit_signal("tram_ride_completed", destination)
    
    # Coalition intel about new district
    _check_coalition_intel(destination)

func _apply_price_modifiers(base_cost: float, from: String, to: String) -> float:
    var cost = base_cost
    
    # Station corruption affects prices
    cost *= (1.0 + AssimilationManager.get_economic_corruption_factor())
    
    # Surge pricing in certain districts
    if from in surge_pricing:
        cost *= surge_pricing[from]
    if to in surge_pricing:
        cost *= max(surge_pricing[to], surge_pricing.get(from, 1.0))
    
    # Coalition discount
    if CoalitionManager.has_transit_alliance():
        cost *= 0.8  # 20% discount
    
    # Time of day pricing
    var hour = TimeManager.get_current_hour()
    if hour >= 6 and hour <= 9:  # Morning rush
        cost *= 1.2
    elif hour >= 17 and hour <= 20:  # Evening rush
        cost *= 1.3
    
    return cost

func _apply_time_modifiers(base_time: float, from: String, to: String) -> float:
    var time = base_time
    
    # Check for maintenance delays
    var route_key = from + "_to_" + to
    if route_key in maintenance_delays:
        time += maintenance_delays[route_key]
    
    # Assimilated interference
    if AssimilationManager.get_transport_disruption_level() > 0:
        time *= (1.0 + AssimilationManager.get_transport_disruption_level() * 0.5)
    
    # Security checks in certain districts
    if to == "security" or from == "security":
        time += 0.25  # 15 minute security screening
    
    return time
```

#### 2. Distance Calculation System
```gdscript
# src/core/systems/district_distance.gd
extends Node

class_name DistrictDistance

# District positions in ring (clockwise)
const DISTRICT_POSITIONS = {
    "spaceport": 0,
    "security": 1,
    "medical": 2,
    "mall": 3,
    "trading_floor": 4,
    "barracks": 5,
    "engineering": 6
}

static func get_distance(from: String, to: String) -> int:
    var from_pos = DISTRICT_POSITIONS.get(from, -1)
    var to_pos = DISTRICT_POSITIONS.get(to, -1)
    
    if from_pos == -1 or to_pos == -1:
        return -1
    
    # Calculate both directions around the ring
    var clockwise = (to_pos - from_pos + 7) % 7
    var counter_clockwise = (from_pos - to_pos + 7) % 7
    
    return min(clockwise, counter_clockwise)

static func get_adjacent_districts(district: String) -> Array:
    var pos = DISTRICT_POSITIONS.get(district, -1)
    if pos == -1:
        return []
    
    var prev_pos = (pos - 1 + 7) % 7
    var next_pos = (pos + 1) % 7
    
    var adjacent = []
    for d in DISTRICT_POSITIONS:
        if DISTRICT_POSITIONS[d] == prev_pos or DISTRICT_POSITIONS[d] == next_pos:
            adjacent.append(d)
    
    return adjacent

static func get_route(from: String, to: String) -> Array:
    var from_pos = DISTRICT_POSITIONS.get(from, -1)
    var to_pos = DISTRICT_POSITIONS.get(to, -1)
    
    if from_pos == -1 or to_pos == -1:
        return []
    
    var route = [from]
    
    # Determine shortest direction
    var clockwise = (to_pos - from_pos + 7) % 7
    var counter_clockwise = (from_pos - to_pos + 7) % 7
    
    var step = 1 if clockwise <= counter_clockwise else -1
    var current_pos = from_pos
    
    while current_pos != to_pos:
        current_pos = (current_pos + step + 7) % 7
        for d in DISTRICT_POSITIONS:
            if DISTRICT_POSITIONS[d] == current_pos:
                route.append(d)
                break
    
    return route
```

#### 3. Transit Events System
```gdscript
# src/core/systems/transit_events.gd
extends Node

class_name TransitEvents

var random_events = [
    {
        "id": "maintenance_delay",
        "chance": 0.1,
        "time_cost": 0.25,
        "message": "Tram delayed due to maintenance. Additional 15 minutes added."
    },
    {
        "id": "security_check",
        "chance": 0.05,
        "trigger": _trigger_security_check,
        "message": "Random security inspection!"
    },
    {
        "id": "coalition_contact",
        "chance": 0.15,
        "condition": "has_coalition",
        "trigger": _trigger_coalition_contact,
        "message": "A coalition member quietly passes you information."
    },
    {
        "id": "pickpocket",
        "chance": 0.08,
        "trigger": _trigger_pickpocket,
        "message": "You feel someone brush past you..."
    },
    {
        "id": "overheard_conversation", 
        "chance": 0.2,
        "trigger": _trigger_overheard,
        "message": "You overhear an interesting conversation."
    }
]

func check_events(route_info: Dictionary):
    for event in random_events:
        if randf() < event.chance:
            if _check_event_conditions(event):
                _execute_event(event, route_info)

func _trigger_security_check():
    # Check for contraband
    var contraband = InventoryManager.get_illegal_items()
    if contraband.size() > 0:
        UI.show_urgent_message("Security found contraband!")
        SuspicionManager.increase_global_suspicion(30, "contraband_on_tram")
        
        # Confiscate items
        for item in contraband:
            InventoryManager.remove_item(item.id, item.quantity)
    else:
        UI.show_message("Security check passed without incident.")

func _trigger_coalition_contact():
    var intel = CoalitionManager.get_random_intel()
    if intel:
        UI.show_message("Coalition intel: " + intel.message)
        CoalitionManager.add_intelligence(intel.type, intel.data)

func _trigger_pickpocket():
    if EconomyManager.player_credits > 50:
        var stolen = randi() % 30 + 10
        EconomyManager.spend_credits(stolen, "pickpocketed")
        UI.show_message("You've been pickpocketed! Lost %d credits" % stolen)
    else:
        UI.show_message("Someone tried to pickpocket you but found nothing.")

func _trigger_overheard():
    var rumors = [
        "Strange deliveries to Medical at night",
        "Security's been acting weird lately",
        "Dock workers keep disappearing",
        "Something's wrong with the water supply",
        "I heard screaming from Engineering"
    ]
    
    var rumor = rumors[randi() % rumors.size()]
    DialogManager.show_ambient_dialog("Passenger", rumor)
```

### Integration Systems

#### Time Management Integration
```gdscript
# Time costs compound with activities
func calculate_total_journey_time(destination: String, planned_activities: Array) -> float:
    var route = TramManager.calculate_route(current_district, destination)
    var total_time = route.time
    
    # Add activity time at destination
    for activity in planned_activities:
        total_time += activity.estimated_time
    
    # Add return journey if needed
    if planned_activities.has("return_home"):
        var return_route = TramManager.calculate_route(destination, "barracks")
        total_time += return_route.time
    
    return total_time

# Show time cost before travel
func show_journey_planner(destination: String):
    var ui = JourneyPlanner.instance()
    ui.destination = destination
    ui.show_time_breakdown()
    ui.show_credit_breakdown()
    ui.show_arrival_time()
```

#### Economy Integration
```gdscript
# Economic pressure from travel
func calculate_daily_travel_budget() -> int:
    var essential_trips = [
        {"from": "barracks", "to": "mall", "reason": "food"},
        {"from": "mall", "to": "barracks", "reason": "return"}
    ]
    
    var daily_cost = 0
    for trip in essential_trips:
        var route = TramManager.calculate_route(trip.from, trip.to)
        daily_cost += route.cost
    
    return daily_cost

# Emergency travel loan
func request_emergency_transit():
    if BankingSystem.can_provide_transit_loan():
        var loan_amount = 100  # Enough for several trips
        BankingSystem.provide_emergency_loan(loan_amount, "transit")
        UI.show_message("Emergency transit loan approved: %d credits" % loan_amount)
    else:
        UI.show_message("No emergency loans available. Find another way to earn credits.")
```

#### Assimilation Integration
```gdscript
# Assimilated affect transport
func apply_assimilation_transport_effects():
    # Leaders control pricing
    for leader_id in AssimilationManager.leader_npcs:
        var leader = NPCRegistry.get_npc(leader_id)
        if leader.role == "transit_administrator":
            TramManager.surge_pricing[leader.district] = 1.5
    
    # Drones cause delays
    var drone_density = AssimilationManager.get_drone_density()
    if drone_density > 0.3:
        TramManager.maintenance_delays["all_routes"] = 0.5  # 30 min delays
    
    # High corruption stops certain routes
    if AssimilationManager.get_station_corruption_level() > 0.8:
        TramManager.blocked_routes.append("engineering")  # Too dangerous

# Spread during travel
func process_travel_assimilation(duration: float):
    # Each hour of travel = chance of NPC assimilation
    var hours = duration
    var spread_chance = 0.02 * hours  # 2% per hour
    
    AssimilationManager.trigger_random_spread(spread_chance)
```

#### Coalition Integration
```gdscript
# Coalition transport network
class CoalitionTransit:
    var allied_conductors: Array = []  # NPCs who provide discounts
    var safe_routes: Dictionary = {}  # Routes with coalition watchers
    var emergency_extraction: bool = false  # Can call for emergency pickup
    
    func get_coalition_transit_benefits() -> Dictionary:
        return {
            "discount": 0.2 if allied_conductors.size() > 0 else 0.0,
            "intel": safe_routes.size() > 0,
            "extraction": emergency_extraction and CoalitionManager.members.size() > 10
        }
    
    func request_emergency_extraction():
        if not emergency_extraction:
            return false
        
        # Coalition member with vehicle helps
        var cost = 500  # Very expensive
        if CoalitionManager.shared_credits >= cost:
            CoalitionManager.shared_credits -= cost
            TramManager.instant_travel(PlayerController.current_district, "barracks")
            UI.show_message("Coalition extraction successful!")
            return true
        
        return false
```

## MVP Implementation

### Basic Features

1. **Simple Ring Layout**
   - 7 districts in fixed order
   - Distance = hops between districts
   - Always shortest path

2. **Fixed Pricing**
   - Adjacent district: 10 credits, 30 minutes
   - 2 districts: 20 credits, 1 hour
   - 3 districts: 30 credits, 1.5 hours
   - Maximum: 40 credits, 2 hours

3. **No Alternative Travel**
   - Tram or nothing
   - No money = stuck in district
   - Must plan trips carefully

4. **Basic UI**
   - Show route on map
   - Display cost and time
   - Confirmation before travel

### MVP Pricing Table
```gdscript
const SIMPLE_PRICING = {
    1: {"cost": 10, "time": 0.5},   # Adjacent
    2: {"cost": 20, "time": 1.0},   # 2 hops
    3: {"cost": 30, "time": 1.5},   # 3 hops
    4: {"cost": 40, "time": 2.0}    # Opposite side (max)
}
```

## Full Implementation

### Advanced Features

#### 1. Dynamic Pricing System
```gdscript
class DynamicPricing:
    var base_prices: Dictionary = {}
    var modifiers: Array = []
    
    func calculate_fare(from: String, to: String, time: float) -> int:
        var base = _get_base_fare(from, to)
        
        # Time of day modifier
        var hour = TimeManager.get_current_hour()
        var time_mult = _get_rush_hour_multiplier(hour)
        
        # Demand modifier
        var demand_mult = _get_demand_multiplier(to)
        
        # Corruption modifier
        var corruption_mult = 1.0 + AssimilationManager.get_economic_corruption_factor()
        
        # Special events
        var event_mult = _get_event_multiplier()
        
        return int(base * time_mult * demand_mult * corruption_mult * event_mult)
    
    func _get_rush_hour_multiplier(hour: int) -> float:
        if hour >= 7 and hour <= 9:
            return 1.5  # Morning rush
        elif hour >= 17 and hour <= 19:
            return 1.8  # Evening rush
        elif hour >= 0 and hour <= 5:
            return 0.5  # Late night discount
        else:
            return 1.0
```

#### 2. Transit Passes & Subscriptions
```gdscript
class TransitPass:
    var pass_types = {
        "daily": {"cost": 50, "duration": 1, "unlimited": true},
        "weekly": {"cost": 200, "duration": 7, "unlimited": true},
        "10_ride": {"cost": 80, "rides": 10, "discount": 0.2}
    }
    
    var active_passes: Array = []
    
    func purchase_pass(type: String) -> bool:
        var pass_data = pass_types[type]
        
        if not EconomyManager.can_afford(pass_data.cost):
            return false
        
        if EconomyManager.spend_credits(pass_data.cost, "transit_pass"):
            var pass = {
                "type": type,
                "purchase_date": TimeManager.current_day,
                "expiry": TimeManager.current_day + pass_data.get("duration", 999),
                "rides_remaining": pass_data.get("rides", -1)
            }
            
            active_passes.append(pass)
            return true
        
        return false
    
    func use_pass_for_ride() -> bool:
        for pass in active_passes:
            if _is_pass_valid(pass):
                if pass.rides_remaining > 0:
                    pass.rides_remaining -= 1
                return true
        
        return false
```

#### 3. Route Disruptions
```gdscript
class RouteDisruption:
    var disruption_types = {
        "maintenance": {
            "duration": 2.0,  # Hours
            "detour_cost": 1.5,
            "message": "Track maintenance - taking longer route"
        },
        "security_lockdown": {
            "duration": 4.0,
            "blocked": true,
            "message": "Security lockdown - route unavailable"
        },
        "drone_vandalism": {
            "duration": 1.0,
            "delay": 0.5,
            "message": "Vandalism cleanup causing delays"
        },
        "power_failure": {
            "duration": 3.0,
            "manual_operation": true,
            "speed_reduction": 0.5,
            "message": "Power failure - manual operation only"
        }
    }
    
    func create_disruption(route: String, type: String):
        var disruption = disruption_types[type]
        
        TramManager.active_disruptions[route] = {
            "type": type,
            "start_time": TimeManager.current_time,
            "end_time": TimeManager.current_time + disruption.duration,
            "effects": disruption
        }
        
        # Notify affected passengers
        UI.show_transit_alert(disruption.message)
```

#### 4. Transit Security & Scanning
```gdscript
class TransitSecurity:
    var security_levels = {
        "green": {"scan_chance": 0.05, "thoroughness": 0.3},
        "yellow": {"scan_chance": 0.2, "thoroughness": 0.6},
        "red": {"scan_chance": 0.5, "thoroughness": 0.9}
    }
    
    func perform_security_check(destination: String):
        var level = _get_district_security_level(destination)
        var config = security_levels[level]
        
        if randf() < config.scan_chance:
            UI.show_message("Security checkpoint - prepare for scanning")
            
            # Check for contraband
            var illegal_items = InventoryManager.get_illegal_items()
            
            if illegal_items.size() > 0 and randf() < config.thoroughness:
                _handle_contraband_detection(illegal_items)
            else:
                UI.show_message("Security check passed")
                
            # Add time delay
            TimeManager.advance_time(0.25)  # 15 minutes
```

### Full System Integration

#### Detection System Integration
```gdscript
# Can't escape if no money for tram
func attempt_escape_district():
    if DetectionManager.current_stage >= DetectionManager.DetectionStage.PURSUING:
        if not EconomyManager.can_afford(TramManager.calculate_emergency_fare()):
            UI.show_urgent_message("No money for tram - TRAPPED!")
            DetectionManager.advance_detection_stage()  # Makes escape harder
            return false
    
    return true

# Assimilated may follow on tram
func check_pursuit_continuation(destination: String):
    if DetectionManager.alerted_npcs.size() > 0:
        for pursuer in DetectionManager.alerted_npcs:
            if randf() < 0.3:  # 30% chance each pursuer follows
                NPCManager.move_npc_to_district(pursuer, destination)
                UI.show_message("You're being followed!")
```

#### Puzzle Integration
```gdscript
# Some puzzles require specific district access
func check_puzzle_district_requirements(puzzle: PuzzleData) -> bool:
    for requirement in puzzle.location_requirements:
        if not TramManager.can_afford_travel_to(requirement):
            UI.show_notification("Need tram fare to reach " + requirement)
            return false
    
    return true

# Multi-district puzzle chains
func calculate_investigation_travel_cost(evidence_locations: Array) -> Dictionary:
    var total_cost = 0
    var total_time = 0.0
    var current = PlayerController.current_district
    
    for location in evidence_locations:
        var route = TramManager.calculate_route(current, location)
        total_cost += route.cost
        total_time += route.time
        current = location
    
    # Return trip
    var return_route = TramManager.calculate_route(current, "barracks")
    total_cost += return_route.cost
    total_time += return_route.time
    
    return {"cost": total_cost, "time": total_time}
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/tram_serializer.gd
extends BaseSerializer

class_name TramSerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("tram", self, 50)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "current_district": TramManager.current_district,
        "in_transit": TramManager.in_transit,
        "transit_destination": TramManager.transit_destination,
        "surge_pricing": TramManager.surge_pricing,
        "disruptions": _serialize_disruptions(),
        "passes": TransitPass.active_passes,
        "travel_history": _compress_travel_history()
    }

func deserialize(data: Dictionary) -> void:
    TramManager.current_district = data.get("current_district", "spaceport")
    TramManager.in_transit = data.get("in_transit", false)
    TramManager.transit_destination = data.get("transit_destination", "")
    TramManager.surge_pricing = data.get("surge_pricing", {})
    
    _deserialize_disruptions(data.get("disruptions", {}))
    TransitPass.active_passes = data.get("passes", [])
    _decompress_travel_history(data.get("travel_history", []))
    
    # Update player location
    PlayerController.current_district = TramManager.current_district
    
    # Resume transit if needed
    if TramManager.in_transit:
        TransitUI.resume_transit_screen()

func _compress_travel_history() -> Array:
    # Only save last 20 trips
    var history = TramManager.travel_history
    var compressed = []
    
    var start = max(0, history.size() - 20)
    for i in range(start, history.size()):
        var trip = history[i]
        compressed.append({
            "f": trip.from_district,  # from
            "t": trip.to_district,    # to
            "c": trip.cost,           # cost
            "d": trip.timestamp - TimeManager.game_start_time  # relative time
        })
    
    return compressed
```

## UI Components

### Tram Station Interface
```gdscript
# src/ui/tram/tram_station_ui.gd
extends Control

onready var destination_list = $DestinationList
onready var route_display = $RouteDisplay
onready var cost_label = $CostLabel
onready var time_label = $TimeLabel
onready var travel_button = $TravelButton

func _ready():
    _populate_destinations()

func _populate_destinations():
    destination_list.clear()
    
    var current = TramManager.current_district
    
    for district in TramManager.DISTRICTS:
        if district == current:
            continue
        
        var item = destination_list.add_item(district.capitalize())
        
        # Show cost preview
        var route = TramManager.calculate_route(current, district)
        var cost_text = "%d cr, %s" % [route.cost, _format_time(route.time)]
        
        destination_list.set_item_metadata(destination_list.get_item_count() - 1, {
            "district": district,
            "route": route
        })
        
        # Color code by affordability
        if not EconomyManager.can_afford(route.cost):
            destination_list.set_item_custom_fg_color(
                destination_list.get_item_count() - 1, 
                Color.red
            )

func _on_destination_selected(index: int):
    var data = destination_list.get_item_metadata(index)
    
    # Show route visualization
    route_display.show_route(
        TramManager.current_district,
        data.district,
        data.route.route
    )
    
    # Update labels
    cost_label.text = "%d Credits" % data.route.cost
    time_label.text = _format_time(data.route.time)
    
    # Enable/disable travel based on funds
    travel_button.disabled = not EconomyManager.can_afford(data.route.cost)
    
    if travel_button.disabled:
        travel_button.text = "Cannot Afford"
    else:
        travel_button.text = "Board Tram"
```

### Transit Screen
```gdscript
# src/ui/tram/transit_screen.gd
extends Control

onready var progress_bar = $ProgressBar
onready var current_stop = $CurrentStop
onready var time_remaining = $TimeRemaining
onready var route_map = $RouteMap

var route_stops: Array = []
var current_stop_index: int = 0
var total_duration: float = 0.0

func show_transit(from: String, to: String, route_info: Dictionary):
    route_stops = route_info.route
    total_duration = route_info.time * 3600  # Convert to seconds for display
    current_stop_index = 0
    
    # Setup UI
    route_map.display_route(route_stops)
    progress_bar.max_value = route_stops.size() - 1
    
    # Start animation
    _animate_transit()
    
    show()

func _animate_transit():
    var tween = Tween.new()
    add_child(tween)
    
    var time_per_stop = total_duration / (route_stops.size() - 1)
    
    for i in range(1, route_stops.size()):
        yield(get_tree().create_timer(time_per_stop), "timeout")
        
        current_stop_index = i
        current_stop.text = "Now at: " + route_stops[i].capitalize()
        progress_bar.value = i
        
        # Random events can occur at stops
        if randf() < 0.1:
            _show_random_event()
    
    # Arrival
    hide()
    tween.queue_free()
```

## Balance Considerations

### Travel Costs
- **Adjacent district**: 10 credits (affordable daily)
- **Opposite side**: 40 credits (significant expense)
- **Daily necessities**: ~20 credits (mall and back)
- **Full circuit**: 70 credits (very expensive)

### Time Investment
- **Adjacent district**: 30 minutes
- **Opposite side**: 2 hours
- **With activities**: 3-4 hours typical
- **Rush hour**: +50-80% time

### Economic Pressure
- **Starting credits**: 100 (10 adjacent trips)
- **Daily survival**: 20-30 credits minimum
- **Investigation travel**: 50-100 credits/day
- **Emergency fund**: 40 credits (escape money)

## Testing Considerations

1. **Route Calculation**
   - All districts reachable
   - Shortest path always chosen
   - Costs calculate correctly
   - Time estimates accurate

2. **Payment System**
   - Insufficient funds handled
   - Passes work correctly
   - Discounts apply properly
   - Coalition benefits function

3. **Integration Testing**
   - Time advances properly
   - Assimilation spreads during travel
   - Events trigger correctly
   - Location updates work

4. **Edge Cases**
   - No money scenarios
   - Disrupted routes
   - In-transit saves
   - Multiple passes

This system creates meaningful travel decisions where every trip must be carefully considered against time and money constraints, reinforcing the game's economic pressure and time management themes.