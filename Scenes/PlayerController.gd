extends CharacterBody2D
class_name Player

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5
@export var dash_range = 5.0
@export var dash_cooldown = 0.0

var has_double_jumped: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
const COYOTE_MAX: float = 0.1
const BUFFER_MAX: float = 0.1
var last_horizontal_direction = 1

# --- COMBAT MEMORY ---
@export var attack_state = 0
var attack_timer = 0.0 
var next_attack_queued = false
var attack_cooldown: float = 0.0 

# --- STUN & I-FRAMES ---
var stun_timer: float = 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var state_machine = $StateMachine
@onready var sword_hitbox = $SwordHitbox

func _physics_process(delta: float) -> void:
	if dash_cooldown > 0: dash_cooldown -= delta
	if attack_cooldown > 0: attack_cooldown -= delta 

	if stun_timer > 0:
		stun_timer -= delta
		if not is_on_floor(): velocity += get_gravity() * delta
		move_and_slide()
		return 
		
	if is_on_floor():
		coyote_timer = COYOTE_MAX
		has_double_jumped = false
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed("space"): jump_buffer_timer = BUFFER_MAX
	else: jump_buffer_timer -= delta

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		execute_jump()

	process_attacks(delta)
	update_animations()

	move_and_slide()

func execute_jump() -> void:
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	state_machine.on_child_transition(state_machine.current_state, "jump")

func process_attacks(delta: float) -> void:
	if attack_state > 0:
		attack_timer -= delta
		if Input.is_action_just_pressed("a") and attack_state == 1:
			next_attack_queued = true
			
		if attack_timer <= 0:
			if attack_state == 1 and next_attack_queued:
				attack_state = 2 
				attack_timer = 0.5 
				animated_sprite.play("attack2")
				next_attack_queued = false 
				
				# FIX: Wait for attack2 impact frame
				await get_tree().create_timer(0.15).timeout
				if attack_state == 2: deal_damage()
			else:
				attack_state = 0
				next_attack_queued = false
				attack_cooldown = 0.3 
				
	elif Input.is_action_just_pressed("a") and attack_cooldown <= 0:
		attack_state = 1
		attack_timer = 0.5 
		animated_sprite.play("attack1")
		next_attack_queued = false
		
		# FIX: Wait for attack1 impact frame before dealing damage
		await get_tree().create_timer(0.15).timeout
		if attack_state == 1: deal_damage()

func deal_damage() -> void:
	if not sword_hitbox: return
	var bodies = sword_hitbox.get_overlapping_bodies()
	for body in bodies:
		if body is BasicEnemy:
			var knockback_dir = sign(body.global_position.x - global_position.x)
			if knockback_dir == 0: knockback_dir = last_horizontal_direction
			body.take_hit(1, knockback_dir * 300.0)

func update_animations() -> void:
	if stun_timer > 0: return

	var move_dir = Input.get_axis("left", "right")
	if move_dir != 0:
		last_horizontal_direction = sign(move_dir)
		animated_sprite.flip_h = last_horizontal_direction < 0
		if sword_hitbox:
			sword_hitbox.scale.x = last_horizontal_direction

	if attack_state > 0: return
	if state_machine.current_state and state_machine.current_state.name == "DashState":
		animated_sprite.play("run") 
		return

	if not is_on_floor():
		if velocity.y < 0: animated_sprite.play("jump")
		else: animated_sprite.play("fall")
	else:
		if move_dir != 0: animated_sprite.play("run")
		else: animated_sprite.play("idle")

func take_hit(damage: int, knockback_force: float) -> void:
	attack_state = 0
	attack_timer = 0.0
	next_attack_queued = false
	
	# Give the player 1 second of God-mode and 0.4 seconds of physical stun
	stun_timer = 0.4 
	
	velocity.x = knockback_force 
	velocity.y = -100.0 # Tiny pop up to clear floor friction
	animated_sprite.play("take_hit")
