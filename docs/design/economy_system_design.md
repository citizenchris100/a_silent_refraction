# Economy System Design

## Overview

The Economy System implements Design Pillar #6: "Everything costs money." It creates economic pressure that drives player decisions, forcing trade-offs between earning money for necessities and pursuing main objectives. The system integrates deeply with time management, assimilation mechanics, and the station's living world.

## Core Concepts

### Economic Philosophy
- **Scarcity drives choices**: Limited money forces meaningful decisions
- **Time is money**: Working costs time but provides income
- **Everything has a price**: From basic needs to critical information
- **Economic warfare**: Assimilation conspiracy uses economics as a weapon

### Currency
- **Credits**: Standard station currency
- **Digital only**: No physical money (fits space station setting)
- **Account-based**: Player has a credit account, not a wallet
- **Traceable**: Purchases can be tracked (adds suspicion risk)

## System Architecture

### Core Components

#### 1. Economy Manager (Singleton)
```gdscript
# src/core/systems/economy_manager.gd
extends Node

signal credits_changed(new_amount)
signal purchase_made(item_id, amount, shop_id)
signal payment_received(amount, source)
signal price_changed(item_id, old_price, new_price)

var player_credits: int = 100  # Starting credits
var transaction_history: Array = []
var price_modifiers: Dictionary = {}  # Global price adjustments

func add_credits(amount: int, source: String = "unknown"):
    player_credits += amount
    _log_transaction(amount, source, "income")
    emit_signal("credits_changed", player_credits)
    emit_signal("payment_received", amount, source)

func spend_credits(amount: int, purpose: String = "purchase") -> bool:
    if player_credits >= amount:
        player_credits -= amount
        _log_transaction(-amount, purpose, "expense")
        emit_signal("credits_changed", player_credits)
        return true
    return false

func can_afford(amount: int) -> bool:
    return player_credits >= amount

func get_modified_price(base_price: int, item_type: String = "") -> int:
    var modifier = 1.0
    
    # Global economic factors
    modifier *= (1.0 + AssimilationManager.get_economic_corruption_factor())
    
    # Item-specific modifiers
    if item_type in price_modifiers:
        modifier *= price_modifiers[item_type]
    
    return int(base_price * modifier)
```

#### 2. Shop System
```gdscript
# src/core/systems/shop_system.gd
extends Node

class_name ShopSystem

export var shop_id: String = ""
export var shop_name: String = "Shop"
export var inventory: Array = []  # Array of ShopItem resources

func purchase_item(item_id: String, quantity: int = 1) -> bool:
    var item = get_item(item_id)
    if not item:
        return false
    
    var total_cost = EconomyManager.get_modified_price(
        item.base_price * quantity, 
        item.category
    )
    
    if not EconomyManager.can_afford(total_cost):
        return false
    
    if item.stock != -1 and item.stock < quantity:
        return false
    
    # Process purchase
    if EconomyManager.spend_credits(total_cost, "purchase_%s" % item_id):
        # Give item to player
        InventoryManager.add_item(item_id, quantity)
        
        # Update stock
        if item.stock != -1:
            item.stock -= quantity
        
        # Log purchase for suspicion system
        _log_purchase(item_id, quantity, total_cost)
        
        EconomyManager.emit_signal("purchase_made", item_id, quantity, shop_id)
        return true
    
    return false
```

#### 3. Job System
```gdscript
# src/core/systems/job_system.gd
extends Node

class_name JobSystem

signal job_started(job_id)
signal job_completed(job_id, payment)
signal job_failed(job_id)

var active_job: JobData = null
var completed_jobs: Array = []

func start_job(job_id: String) -> bool:
    if active_job != null:
        return false
    
    var job_data = JobRegistry.get_job(job_id)
    if not job_data:
        return false
    
    # Check requirements
    if not _check_job_requirements(job_data):
        return false
    
    active_job = job_data
    active_job.start_time = TimeManager.current_time
    
    # Schedule completion
    TimeManager.schedule_event(
        TimeManager.current_time + job_data.duration,
        self,
        "_on_job_timer_complete"
    )
    
    emit_signal("job_started", job_id)
    return true

func _on_job_timer_complete():
    if not active_job:
        return
    
    var payment = _calculate_payment(active_job)
    EconomyManager.add_credits(payment, "job_%s" % active_job.id)
    
    completed_jobs.append(active_job.id)
    emit_signal("job_completed", active_job.id, payment)
    
    active_job = null
```

### Data Structures

#### Shop Item Resource
```gdscript
# src/resources/shop_item.gd
extends Resource

class_name ShopItem

export var id: String = ""
export var name: String = ""
export var description: String = ""
export var base_price: int = 10
export var category: String = "general"  # food, clothing, tools, info
export var stock: int = -1  # -1 = unlimited
export var required_trust: int = 0  # Some items need NPC trust
export var illegal: bool = false  # Black market items
```

#### Job Data Resource
```gdscript
# src/resources/job_data.gd
extends Resource

class_name JobData

export var id: String = ""
export var name: String = ""
export var description: String = ""
export var location: String = ""  # District/room requirement
export var duration: int = 4  # Hours
export var base_pay: int = 50
export var performance_bonus: int = 20  # Extra for good performance
export var requirements: Dictionary = {}  # Skills, items, etc.
export var suspicion_risk: float = 0.0  # Some jobs are suspicious
```

## MVP Implementation

### Basic Features
1. **Credit System**
   - Player wallet with credit balance
   - Simple add/spend operations
   - UI display of current credits

2. **Essential Shops**
   - Convenience Store (food, water)
   - Clothing Shop (basic disguise)
   - Information Broker (hints, access codes)

3. **Two Basic Jobs**
   - Mall Security (4 hours, 50 credits)
   - Janitor (3 hours, 35 credits)

4. **Fixed Prices**
   - No dynamic pricing in MVP
   - Items have set costs

5. **Simple Purchases**
   - Click item → check credits → complete purchase
   - Basic inventory integration

### MVP Data Examples

```gdscript
# Mall Security Job
{
    "id": "mall_security",
    "name": "Mall Security Patrol",
    "duration": 4,
    "base_pay": 50,
    "location": "mall_district"
}

# Food Item
{
    "id": "food_ration",
    "name": "Food Ration",
    "base_price": 10,
    "category": "food",
    "stock": 20
}

# Basic Disguise
{
    "id": "civilian_clothes",
    "name": "Civilian Clothes",
    "base_price": 75,
    "category": "clothing",
    "stock": 5
}
```

## Full Implementation

### Advanced Features

#### 1. Dynamic Pricing System
```gdscript
# Price factors based on station corruption
func get_economic_corruption_factor() -> float:
    var corruption = AssimilationManager.get_station_corruption_level()
    
    # Prices increase as station destabilizes
    # 0% corruption = 0% increase
    # 50% corruption = 25% increase  
    # 100% corruption = 100% increase
    return corruption * corruption

# Supply and demand
func adjust_item_price(item_id: String, demand_factor: float):
    var modifier = clamp(demand_factor, 0.5, 2.0)
    price_modifiers[item_id] = modifier
```

#### 2. Complex Job System
- **Performance Metrics**: Complete optional objectives for bonuses
- **Job Chains**: Unlock better jobs through performance
- **Shift Scheduling**: Some jobs only available at certain times
- **Skill Requirements**: Need specific items or abilities
- **Criminal Jobs**: High pay but increase suspicion

#### 3. Banking System
```gdscript
# src/core/systems/banking_system.gd
extends Node

var savings_account: int = 0
var loan_amount: int = 0
var loan_interest_rate: float = 0.15
var credit_rating: int = 100  # Affects loan availability

func deposit(amount: int) -> bool:
    if EconomyManager.spend_credits(amount, "bank_deposit"):
        savings_account += amount
        return true
    return false

func take_loan(amount: int) -> bool:
    if credit_rating < 50:
        return false  # Bad credit
    
    if loan_amount > 0:
        return false  # Existing loan
    
    loan_amount = amount
    EconomyManager.add_credits(amount, "bank_loan")
    
    # Schedule interest payments
    TimeManager.schedule_recurring_event(
        24,  # Daily
        self,
        "_process_loan_interest"
    )
    
    return true
```

#### 4. Black Market
- **Hidden Shops**: Need to discover through NPCs
- **Illegal Items**: Weapons, hacking tools, forged documents
- **Reputation System**: Build trust with criminal elements
- **Risk/Reward**: High suspicion but powerful items

#### 5. Economic Missions
- **Sabotage**: Disrupt assimilated business operations
- **Smuggling**: Move goods between districts for profit
- **Information Trading**: Buy low, sell high on secrets
- **Protection Racket**: Defend shops from drone attacks

### Full System Integration

#### Time Management Integration
```gdscript
# Jobs consume time chunks
func start_job(job_id: String):
    TimeManager.advance_time(job_data.duration)
    PlayerController.set_busy(true)
    
# Shopping takes time
func enter_shop():
    TimeManager.advance_time(0.5)  # 30 minutes to browse
```

#### Assimilation Integration
```gdscript
# Leaders manipulate prices
func on_npc_assimilated(npc_id: String, role: String):
    if role == "leader":
        var npc_data = NPCRegistry.get_npc(npc_id)
        if npc_data.job == "shop_owner":
            # This shop now has inflated prices
            price_modifiers[npc_data.shop_id] = 1.5
```

#### Coalition Integration
```gdscript
# Coalition members offer discounts
func get_shop_discount(shop_id: String) -> float:
    var owner = ShopRegistry.get_owner(shop_id)
    if CoalitionManager.is_member(owner):
        return 0.8  # 20% discount
    return 1.0
```

## Serialization

Following the modular serialization architecture:

```gdscript
# src/core/serializers/economy_serializer.gd
extends BaseSerializer

class_name EconomySerializer

func _ready():
    # Self-register with medium priority
    SaveManager.register_serializer("economy", self, 30)

func get_version() -> int:
    return 1

func serialize() -> Dictionary:
    return {
        "credits": EconomyManager.player_credits,
        "transactions": _compress_transactions(),
        "active_job": _serialize_active_job(),
        "completed_jobs": JobSystem.completed_jobs,
        "shop_stocks": _serialize_shop_stocks(),
        "price_modifiers": EconomyManager.price_modifiers,
        "banking": _serialize_banking_state()
    }

func deserialize(data: Dictionary) -> void:
    EconomyManager.player_credits = data.get("credits", 100)
    _decompress_transactions(data.get("transactions", []))
    _deserialize_active_job(data.get("active_job", {}))
    JobSystem.completed_jobs = data.get("completed_jobs", [])
    _deserialize_shop_stocks(data.get("shop_stocks", {}))
    EconomyManager.price_modifiers = data.get("price_modifiers", {})
    _deserialize_banking_state(data.get("banking", {}))

func _compress_transactions() -> Array:
    # Only save last 50 transactions
    var recent = EconomyManager.transaction_history.slice(
        max(0, EconomyManager.transaction_history.size() - 50),
        EconomyManager.transaction_history.size()
    )
    
    var compressed = []
    for trans in recent:
        compressed.append({
            "a": trans.amount,  # amount
            "s": trans.source,  # source
            "t": trans.timestamp - TimeManager.game_start_time  # relative time
        })
    
    return compressed
```

## UI Components

### Credit Display
```gdscript
# src/ui/economy/credit_display.gd
extends Label

func _ready():
    EconomyManager.connect("credits_changed", self, "_on_credits_changed")
    _update_display()

func _on_credits_changed(new_amount: int):
    _update_display()

func _update_display():
    text = "%d Cr" % EconomyManager.player_credits
    
    # Flash on change
    modulate = Color.yellow
    yield(get_tree().create_timer(0.2), "timeout")
    modulate = Color.white
```

### Shop Interface
```gdscript
# src/ui/economy/shop_ui.gd
extends Control

onready var item_list = $ItemList
onready var buy_button = $BuyButton
onready var total_label = $TotalLabel

var current_shop: ShopSystem
var selected_item: ShopItem

func open_shop(shop: ShopSystem):
    current_shop = shop
    _populate_items()
    show()

func _populate_items():
    item_list.clear()
    
    for item in current_shop.inventory:
        var price = EconomyManager.get_modified_price(item.base_price, item.category)
        var text = "%s - %d Cr" % [item.name, price]
        
        if item.stock != -1:
            text += " (Stock: %d)" % item.stock
        
        item_list.add_item(text)
```

## Balance Considerations

### Economy Balance
- **Starting Credits**: 100 (enough for 10 days of food)
- **Daily Needs**: 10-15 credits (food + water)
- **Basic Job Pay**: 35-50 credits per shift
- **Disguise Cost**: 75 credits (1.5 days of work)
- **Information Cost**: 25-100 credits depending on value

### Time vs Money Trade-offs
- Working 4 hours earns 50 credits
- Same 4 hours could progress main quest
- Player must balance immediate needs vs long-term goals

### Corruption Impact
- 0% corruption: Normal prices
- 25% corruption: 6% price increase
- 50% corruption: 25% price increase
- 75% corruption: 56% price increase
- 100% corruption: 100% price increase (prices doubled)

## Testing Considerations

1. **Economy Balance Testing**
   - Ensure player can survive but feels pressure
   - Test full playthrough economic viability
   - Verify no soft-locks from lack of money

2. **Integration Testing**
   - Job system time consumption
   - Shop inventory depletion
   - Price modifier stacking
   - Serialization/deserialization

3. **Edge Cases**
   - Negative credits prevention
   - Integer overflow protection
   - Concurrent transaction handling
   - Shop stock validation

## Future Expansion Hooks

1. **Cryptocurrency**: Hidden digital currency for black market
2. **Investment System**: Buy station shares, affected by corruption
3. **Auction House**: Bid on rare items with other NPCs
4. **Insurance**: Protect against losses from assimilation events
5. **Crafting Economy**: Combine items to create valuable goods

This system provides the economic pressure that drives player choices while integrating seamlessly with the game's other systems and narrative themes.