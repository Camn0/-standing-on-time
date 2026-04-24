# Tugas Bidang Divisi Code

## Overview
This repository contains the Training and Introduction prototype for the Divisi Code. 

The ultimate goal of this build is a "Chimera Prototype"—an ambitious integration of the four mandated mechanical options into a unified 2D side-scrolling system. It aims to combine precise custom kinematics (Hollow Knight) with data-driven narrative systems (Monkey Island), spatial proximity interactions (King's Quest), and environmental state toggling (Space for the Unbound).

## Current Progress (v0.1 - Kinematics Foundation)
The current build focuses on **Option 4 (Precision Movement & Combat)**. 
Engine defaults have been bypassed to implement raw variable calculations for movement logic.

### Mechanics Implemented:
* **Custom Kinematic Movement:** 2D platforming physics independent of default engine gravity mapping.
* **Variable Jump Height:** Jump arc dynamically recalculates based on input release timing (`decelerate_on_jump_release`).
* **Double Jump Logic:** Integrated cooldown and state tracking for mid-air jumps.
* **I-Frame Dash:** Fixed-distance horizontal translation ignoring gravity.
* **Attack Queuing (Combo System):** An input buffer that remembers subsequent attack commands during active animation frames to trigger smooth combo transitions.

## Controls
| Action | Key Binding |
| :--- | :--- |
| **Move Left/Right** | `Left Arrow` / `Right Arrow` (or `A` / `D`) |
| **Jump / Double Jump** | `Spacebar` |
| **Dash** | `Shift` |
| **Melee Attack / Combo** | `A` key |

## Development Roadmap (Path to May 4)
- [x] **Phase 1:** Core Kinematics & Input Polling (Current).
- [ ] **Phase 2:** Refactoring monolithic logic into a strict Finite State Machine (FSM) Node hierarchy.
- [ ] **Phase 3:** Implementing `Area2D` proximity triggers (Option 2).
- [ ] **Phase 4:** Integrating JSON/Dictionary data structures for branching dialogue UI (Option 1).
- [ ] **Phase 5:** Global Singletons and dual-TileMap visibility toggling (Option 3).

## Setup & Execution
1. Clone this repository.
2. Open Godot Engine (v4.x).
3. Import the `project.godot` file.
4. Run the main `Level` scene. 
*(Note: An HTML5 Web Build will be provided in the releases tab upon final deployment).*
