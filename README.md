# DIOSPA: Divisi Code - Training & Introduction

## Project Overview

This repository contains the barebones prototype for the DIOSPA Divisi Code phase. Following the project guidelines, this implementation focuses strictly on **Option 4 (Hollow Knight Paradigm)**, prioritizing highly responsive, deterministic 2D kinematics and a fluid combat system over visual complexity. 

The current build establishes the core movement loop and attack queuing logic within a Godot 4.x `CharacterBody2D` environment.

## Current System Architecture

The player controller currently handles the following mechanical loops:

### Kinematics & Mobility
* **Variable Jump Height:** Upward velocity is dynamically decelerated upon early release of the jump input, providing precise aerial control.
* **Double Jump Capability:** Independent cooldown timer governing secondary mid-air propulsion.
* **Linear Dash:** Horizontal high-speed translation vector bypassing standard acceleration, tied to a strict cooldown loop.
* **Directional State:** Sprite orientation matrices flip automatically based on the active horizontal movement axis.

### Combat Logic
* **Attack Queuing (Combo System):** An integer-based local state machine tracks attack cycles. Input during `attack1` is buffered in memory (`next_attack_queued = true`), seamlessly triggering `attack2` immediately after the first animation frame data concludes.

## Controls

| Action | Keybinding |
| :--- | :--- |
| **Move Left/Right** | `Left Arrow` / `Right Arrow` |
| **Jump** | `Spacebar` (Hold for max height, tap for short hop) |
| **Dash** | `Shift` |
| **Melee Attack** | `A` (Press consecutively for combos) |

## Development Roadmap (Next Steps)

To fully align with the Divisi Code architectural requirements before the deadline, the following systems are scheduled for deployment:

- [ ] **FSM Refactoring:** Abstract the current monolithic `_physics_process` logic into isolated, modular Node-based state scripts (`IdleState`, `RunState`, `JumpState`, `AttackState`).
- [ ] **First-Principles Gravity:** Overwrite the engine's default `get_gravity()` with custom mathematical derivations based on peak-height ($h_{max}$) and time-to-apex ($t_{apex}$) axioms.
- [ ] **Input Buffering:** Implement a 0.1-second Coyote Time timer and a Jump Buffer to maximize input responsiveness.
- [ ] **I-Frame Integration:** Disconnect enemy hitboxes during the 0.2-second Dash state.
- [ ] **AI Proximity:** Instantiate a basic patrol enemy with RayCast ledge-detection.

## Execution Philosophy
*"Barebones Only."* No time is allocated to advanced shaders, complex UI, or high-fidelity sprites. The core loop is the sole priority.
