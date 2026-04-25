# TUBID Divisi Code

![Status](https://img.shields.io/badge/Status-Work_In_Progress-orange)
![Engine](https://img.shields.io/badge/Godot-4.x-blue)
![Target](https://img.shields.io/badge/Deployment-April_25-success)

## Overview
This repository contains the technical calibration prototype for DIOSPA Divisi Code. It is engineered as a "chimera" system, hybridizing the mechanical requirements of four distinct design paradigms into a single, cohesive 2D engine. 

Adhering strictly to the "Barebones Only" directive, this project minimizes complex visual processing in favor of raw geometric logic, deterministic kinematics, and event-driven architecture.

## Current Progress (Phase 1)
The core player controller (`CharacterBody2D`) has been established with initial input polling, kinematics, and combo logic. 

**Implemented Core Features:**
* Custom gravity integration and state-based jump tracking.
* Variable horizontal movement logic with automated deceleration/friction.
* Double-jump capability enforced by strict cooldown timers.
* Directional dash mechanics utilizing frame-based durations and cooldown limits.
* Sequential attack combo logic (Attack 1 -> Attack 2 queueing) governed by an internal state integer.
* Automated sprite orientation and baseline animation tree triggers.

*Note: The current controller utilizes an internal monolithic state machine. The immediate next phase involves spatial refactoring into a modular Node-based Finite State Machine (FSM) to handle the incoming complexity of the hybrid mechanics.*

## Implementation Plan: The Hybrid Engine
The integration of all four required options is proceeding sequentially to maintain system stability:

### Phase 1: First Principles Kinematics (Hollow Knight Paradigm) - *In Progress*
* **Objective:** Responsive, deterministic physics without relying on default engine black-box physics materials.
* **Architecture:** Implementation of a strict Node-based Finite State Automaton (Idle, Run, Jump, Fall, Dash) to isolate logic and prevent nested conditional errors.

### Phase 2: Spatial Proximity & Memory Persistence (King's Quest Paradigm) - *Pending*
* **Objective:** Environmental interaction and state persistence across memory wipes (scene transitions).
* **Architecture:** Utilization of `Area2D` intersection signals for proximity triggers and a Global Singleton (Autoload) to store boolean quest states globally (e.g., `quest_cleared = true`).

### Phase 3: Dimension Shifting (Space for the Unbound Paradigm) - *Pending*
* **Objective:** Real-time visual toggling of reality states (Mental Dimension).
* **Architecture:** Binary boolean toggling of rendering visibility and collision bitmasks across dual `TileMap` node arrays.

### Phase 4: Data-Driven Narrative Graphs (Monkey Island Paradigm) - *Pending*
* **Objective:** Branching dialog execution cleanly decoupled from core game logic.
* **Architecture:** Parsing Directed Acyclic Graphs (DAGs) from external JSON dictionaries to populate UI components, complete with dynamic string-slice typewriter effects.

## Execution & Compilation
*(Build instructions and executable links will be generated here upon final HTML5/WebAssembly compilation prior to the deadline.)*
