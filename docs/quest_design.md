# A Silent Refraction: Quest Design Document

This document outlines the quest system architecture and specific quest designs for A Silent Refraction. It serves as a reference for implementing the quest system in Iteration 7.

## Quest System Architecture

### Quest Data Structure

Each quest will be defined with the following properties:

```gdscript
{
    "id": "intro_quest",
    "title": "The Delivery",
    "description": "Deliver the mysterious package to Science Lead 01 on the Science Deck",
    "type": "main_story", # main_story, district, side, detection
    "state": "active", # inactive, active, complete, failed
    "stages": [
        {
            "id": "stage_1",
            "description": "Find the Science Deck in Engineering",
            "complete": false,
            "optional": false
        },
        {
            "id": "stage_2",
            "description": "Deliver the package to Science Lead 01",
            "complete": false,
            "optional": false
        },
        {
            "id": "stage_3",
            "description": "Return to your room in the Barracks",
            "complete": false,
            "optional": false
        }
    ],
    "related_npcs": ["stewardess", "science_lead_01"],
    "district": "engineering",
    "rewards": {
        "inventory_items": [],
        "story_flags": ["intro_complete"],
        "time_advance": 4 # hours
    },
    "prerequisites": []
}
```

### Quest Types

1. **Main Story Quests**: Required for game progression
2. **District Quests**: Major quests unique to each district
3. **Side Quests**: Optional quests that provide insights or rewards
4. **Detection Quests**: Specifically for identifying assimilated NPCs

### Quest States

1. **Inactive**: Not yet available to the player
2. **Active**: Currently available/in progress
3. **Complete**: Successfully finished
4. **Failed**: Failed to complete (may lead to game over)

### Quest Triggers

Quests can be triggered by:
- Dialog with NPCs
- Examining items/objects
- Entering specific locations
- Time of day/day progression
- Completing other quests (prerequisites)

## Main Story Quests

### Intro Quest: The Delivery

**Goal**: Deliver the mysterious package to Science Lead 01 on the Science Deck

**Stages**:
1. Find the Science Deck in Engineering
2. Deliver the package to Science Lead 01
3. Return to your room in the Barracks

**Key NPCs**: Stewardess, Science Lead 01

**Dialog Hooks**:
- Stewardess reminds you of your delivery
- Science Lead 01 accepts package with unusual interest

**Puzzle Elements**: None (introductory quest)

**Rewards**: Unlocks First Quest

### First Quest: Joining the Resistance

**Goal**: Discover and join the resistance group aboard the station

**Stages**:
1. Hear about the station lockdown on TV
2. Accept delivery task from Concierge
3. Deliver package to Bank Teller
4. Receive return package for Concierge
5. Encounter Security Officer (dialog puzzle)
6. Escape from Brig (puzzle sequence)
7. Make way to Mall for patrol duty
8. Solve one of the Mall crimes (puzzle choice)
9. Change into civilian clothes
10. Return to Barracks and meet the resistance

**Key NPCs**: Concierge, Bank Teller, Security Officer

**Dialog Puzzles**:
- Security Officer interrogation (wrong choices lead to game over)

**Puzzle Elements**:
- Brig escape sequence (requires item discovery and usage)
- Mall crime resolution (multiple solutions)

**Rewards**:
- Joining the resistance
- Basic understanding of the assimilation plot
- Unlocks all district quests

### Main Investigation Quest (Multi-Part)

A three-part investigation quest spanning all districts that reveals the full backstory.

#### Part 1: Finding the Missing Operative

**Goal**: Find the missing resistance operative from Engineering

**Stages**:
1. Interview colleagues in Engineering
2. Find evidence of operative's last location
3. Discover coded message in Science Deck terminal
4. Decode the message to reveal hidden storage location
5. Retrieve operative's evidence cache

**Key NPCs**: Engineering Lead 02, Scientist 02

**Puzzle Elements**:
- Terminal password hacking mini-game
- Decoding puzzle

**Rewards**:
- Evidence about initial Mars contamination
- Unlocks Part 2

#### Part 2: Corporate Conspiracy

**Goal**: Investigate Aether Corp's involvement

**Stages**:
1. Find corporate documents in Trading Floor
2. Break into Bank Manager's office
3. Access bank records for suspicious transactions
4. Track shipments through Shipping District records
5. Identify compromised Aether Corp officials

**Key NPCs**: Bank Manager, Dock Manager

**Puzzle Elements**:
- Safe cracking mini-game
- Document reconstruction puzzle

**Rewards**:
- Evidence about synthesized goo project
- Unlocks Part 3

#### Part 3: The Source

**Goal**: Find the source of assimilation and develop countermeasure

**Stages**:
1. Break into Medical Laboratory
2. Analyze goo sample
3. Find original delivery records in Shipping
4. Identify original Mars colonist
5. Develop neutralization method with Medical staff

**Key NPCs**: Lab Tech 02, Doctor 03

**Puzzle Elements**:
- Chemical mixture puzzle
- Security bypass sequence

**Rewards**:
- Ability to neutralize the goo
- Knowledge to identify Patient Zero
- Critical info for ending choices

## District Quests

Each district has one major quest line that, when completed, secures that district and saves NPCs from assimilation.

### Shipping District: Cargo Conspiracy

**Goal**: Uncover and stop the smuggling of additional goo samples

**Stages**:
1. Notice unusual security around USCM NT-4191 ship
2. Gain access to shipping manifests
3. Identify suspicious cargo container
4. Break into secured cargo area
5. Neutralize goo samples

**Key NPCs**: Dock Foreman, Dock Worker 2

**Puzzle Elements**:
- Manifest forgery puzzle
- Timed security bypass

### Security District: Internal Affairs

**Goal**: Identify and neutralize assimilated security leadership

**Stages**:
1. Find irregularities in security patrol schedules
2. Gain access to personnel files
3. Identify suspicious behavior patterns
4. Gather evidence of assimilation
5. Confront and neutralize compromised leadership

**Key NPCs**: Detective Officer 01, Security Administrator 02

**Puzzle Elements**:
- Schedule analysis puzzle
- Surveillance camera puzzle

### Barracks District: Room 508 Mystery

**Goal**: Investigate disappearances from Room 508

**Stages**:
1. Notice unusual activity around Room 508
2. Interview neighboring residents
3. Find hidden passage in Room 508
4. Discover makeshift assimilation lab
5. Destroy lab equipment

**Key NPCs**: Resident 02, Resident 05

**Puzzle Elements**:
- Hidden passage puzzle
- Chemical neutralization puzzle

### Trading Floor District: Market Manipulation

**Goal**: Stop financial manipulation funding the assimilation project

**Stages**:
1. Notice unusual trading patterns
2. Infiltrate regulatory office
3. Find evidence of market manipulation
4. Trace funds to assimilation project
5. Freeze suspicious accounts

**Key NPCs**: Broker 03, Office Manager

**Puzzle Elements**:
- Financial puzzle (following money trail)
- Computer hacking sequence

### Mall District: Public Perception

**Goal**: Counter public misinformation campaign

**Stages**:
1. Notice propaganda in store displays
2. Find source of misinformation
3. Create counter-information campaign
4. Distribute truth through mall vendors
5. Host public demonstration

**Key NPCs**: Electronics Store Cashier, Bar Tender

**Puzzle Elements**:
- Message encoding puzzle
- Social engineering puzzle

### Engineering District: Life Support Sabotage

**Goal**: Prevent sabotage of station life support systems

**Stages**:
1. Notice unusual modifications to life support
2. Identify sabotage points
3. Find engineering schematics
4. Repair critical systems
5. Secure systems against further tampering

**Key NPCs**: Engineer 06, Engineering Lead 03

**Puzzle Elements**:
- Systems diagnostic puzzle
- Rewiring mini-game

## Side Quests and Detection Mechanics

### Assimilation Detection Quests

Shorter quests specifically designed to help identify assimilated NPCs:

1. **Speech Pattern Analysis**: Observe NPC conversations to identify unusual patterns
2. **Medical Examination**: Find ways to test NPCs for assimilation signs
3. **Personal History Verification**: Cross-reference NPC backstories for inconsistencies
4. **Off-Hours Surveillance**: Follow suspicious NPCs during their off hours

### Resistance Recruitment

Once NPCs are confirmed as non-assimilated, special dialog options allow recruitment:

1. **Evidence Presentation**: Show evidence of the assimilation
2. **Personal Appeal**: Use personal connection/backstory
3. **Logic Appeal**: Present logical argument for resistance
4. **Mutual Protection**: Offer safety in numbers

Failed recruitment attempts have consequences:
- Increased suspicion from the NPC
- Potential reporting to assimilated authorities
- Lockdown of quest areas

## Quest UI and Interaction

### Quest Log UI

The quest log will include:
- Active quests list with current stages
- Completed quest history
- Failed quest record
- Quest sorting by type and district

### In-Game Quest Indicators

- NPCs with available quests will have subtle indicators
- Locations relevant to active quests will be highlighted on maps
- Quest-related inventory items will be specially marked

### Time Management

Quest activities advance time:
- Travel between districts: 30 minutes
- Conversations: 15-30 minutes
- Complex puzzle solving: 1-2 hours
- Major quest completion: Variable (3-4 hours)

## Quest Testing Checklist

For each quest implementation, test:
1. All trigger conditions work properly
2. Quest stages advance correctly
3. Dialog options appear in context
4. Puzzles can be solved with intended solutions
5. Rewards are properly granted
6. Quest state is correctly saved/loaded
7. Time advancement is appropriate
8. Failed states are properly handled