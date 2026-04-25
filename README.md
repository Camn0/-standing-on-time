# TUBID Divisi Code
![Status](https://img.shields.io/badge/Status-Phase_1_&_2_Complete-green)
![Engine](https://img.shields.io/badge/Godot-4.6-blue)
![Architecture](https://img.shields.io/badge/Pattern-State_Machine-red)

https://github.com/user-attachments/assets/38a6c886-c8a9-42e9-ab54-2f966a53c889

## Overview
This repository contains the finalized technical calibration prototype for the **DIOSPA Divisi Code**. The system has evolved from a monolithic controller into a decoupled, event-driven architecture. It successfully integrates deterministic kinematics, a modular Finite State Machine (FSM), and a "Hunter-Patrol" AI paradigm.

The project adheres to the "Barebones Only" directive, prioritizing raw geometric logic and signal-based communication over visual fluff.

---

## Project Scene Hierarchy (The Tree)

The following structure represents the optimized node organization to ensure "Local-to-Global" coordinate synchronization.

### Player Scene (`Player.tscn`)
```text
Player (CharacterBody2D) -> Script: Player.gd
├── AnimatedSprite2D (Animations: idle, run, jump, fall, attack1, attack2, take_hit)
├── CollisionShape2D (Capsule/Box)
├── StateMachine (Node) -> Script: StateMachine.gd
│   ├── Idle (Node) -> Script: IdleState.gd
│   ├── Run (Node) -> Script: RunState.gd
│   ├── Jump (Node) -> Script: JumpState.gd
│   ├── Fall (Node) -> Script: FallState.gd
│   └── Dash (Node) -> Script: DashState.gd
└── SwordHitbox (Area2D)
    └── CollisionShape2D (Rectangle - Facing Right)
```

### Enemy Scene (`Enemy.tscn`)
```text
Enemy (CharacterBody2D) -> Script: Enemy.gd
├── AnimatedSprite2D (Animations: idle, run, attack1, attack2, take_hit, death)
├── CollisionShape2D (Box)
├── RayCast2D (LedgeDetector - Aimed at X:15, Y:20)
├── AttackRange (Area2D) -> "The Proximity Alarm"
│   └── CollisionShape2D (Rectangle)
└── ChaseRange (Area2D) -> "The Vision Cone"
    └── CollisionShape2D (Rectangle - 3x wider than Attack)
```

---

## Technical Implementation Details

### 1. Modular Finite State Machine (FSM)
To satisfy the **Hollow Knight Paradigm (Option 4)**, the movement logic is decoupled into "Logic Chips" (State Nodes).
* **The Motherboard (`Player.gd`):** Acts as the hardware interface, holding variables (Speed, Timers) and processing visuals.
* **The Router (`StateMachine.gd`):** Manages transitions. It includes a **Stun-Lock Killswitch** that powers off the FSM when the player takes damage, allowing pure physics to handle knockback.
* **State Chips:** Independent scripts handle specific logic (e.g., `JumpState` handles the initial impulse, while `FallState` monitors the floor for landing).

### 2. "Hunter-Patrol" Enemy AI
The enemy utilizes an internal Enum-based state machine and deterministic vector math:
* **RNG Exploration:** Uses `randf_range` timers to switch between `IDLE` and `PATROL` states, preventing predictable movement patterns.
* **Ledge/Wall Detection:** Uses a `RayCast2D` to "see" cliffs. When the ray stops colliding, the enemy executes a `flip_direction()` logic.
* **The Tracking Paradox:** Tracking is calculated via `(Target.x - Self.x)`. This provides a directional sign (+1 or -1) that dictates movement.

### 3. Combat & Kinematics
Combat is handled through **Signal-Based Hitboxes** rather than frame-by-frame distance checks.
* **Hit-Stun & I-Frames:** Upon taking damage, the player enters a `stun_timer` (0.4s) which disables input and an `invincibility_timer` (1.0s) which triggers a visual blink using `Engine.get_frames_drawn()`.
* **Horizontal Impulse:** To prevent Godot’s "Floor Friction" from eating knockback, victims are given a micro-vertical "bump" (-50 to -100px) the moment they are hit, ensuring smooth sliding.
* **Spam Protection:** Both Player and Enemy have hardcoded cooldowns on the `animation_finished` signal.

---

## The Hybrid Paradigm Mapping

| Paradigm | Component | Status |
| :--- | :--- | :--- |
| **Hollow Knight** | FSM, Variable Jump, Dash, Stun-lock | **COMPLETE** |
| **King's Quest** | Proximity Interaction, Area2D Signals | **STABLE** |
| **Space for the Unbound** | Dimension Toggling via Bitmasks | **PENDING** |
| **Monkey Island** | JSON-driven Narrative Graphs | **PENDING** |

---

## Script Architecture Summary

### `Player.gd`
Manages the hardware-level data. Contains the `take_hit` function which clears attack queues and initiates the blinking invincibility frames.

### `Enemy.gd`
Handles the AI "Brain." Includes logic for `CHASE` (locked-on tracking) and `PATROL` (exploratory movement). It uses an automated signal wiring system in `_ready()` to connect its own sensors to the script.

### `StateMachine.gd`
The central hub for state transitions. It has been patched to include a safety check that prevents movement updates if the player is in a stunned state.

---

## Next Steps: Phase 3
The next implementation cycle will focus on the **Space for the Unbound Paradigm**, introducing:
1.  **Dual TileMap Systems:** A "Real World" and "Mental World" layer.
2.  **Reality Toggle:** A global input to swap visibility and collision layers (Bitmask 1 vs Bitmask 2).
3.  **Persistence Singleton:** A `Global.gd` script to track which enemies have been defeated across dimension shifts.

---

## Execution & Compilation
*(Build instructions and executable links will be generated here upon final HTML5/WebAssembly compilation prior to the deadline.)*
