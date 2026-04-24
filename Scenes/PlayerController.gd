extends CharacterBody2D
class_name Player

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export_range(0,1) var decelerate_on_jump_release = 0.5
@export var dash_range = 7.5

@export var dash_cooldown = 0.0
@export var double_jump_cooldown = 0.0

# Attack variables
@export var attack_state = 0
var attack_timer = 0.0 
var next_attack_queued = false # <-- NEW: Remembers if you pressed 'a' during attack1

@onready var animated_sprite = $AnimatedSprite2D

var last_horizontal_direction = 1
var jump_state = 0

func _physics_process(delta: float) -> void:
	# 1. GRAVITY & JUMP STATE
	if not is_on_floor():
		jump_state = 1
		velocity += get_gravity() * delta
	else:
		jump_state = 0
	
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("space") and velocity.y < 0:
		velocity.y *= decelerate_on_jump_release
	
	if Input.is_action_just_pressed("space") and double_jump_cooldown <= 0 and jump_state == 1:
		velocity.y = JUMP_VELOCITY
		double_jump_cooldown = 1.0
		
	if double_jump_cooldown > 0:
		double_jump_cooldown -= delta

	# 2. MOVEMENT
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
		last_horizontal_direction = direction
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Flip sprite based on movement direction
	animated_sprite.flip_h = last_horizontal_direction < 0

	# 3. DASH
	if Input.is_action_just_pressed("shift") and dash_cooldown <= 0:
		velocity.x = last_horizontal_direction * dash_range * SPEED
		dash_cooldown = 1.0
	
	if dash_cooldown > 0:
		dash_cooldown -= delta

	# 4. ATTACK LOGIC & COMBOS
	if attack_state > 0:
		attack_timer -= delta
		
		# If they press attack while attack1 is already playing, queue it up!
		if Input.is_action_just_pressed("a") and attack_state == 1:
			next_attack_queued = true
			
		# When the current attack animation finishes (timer hits 0)
		if attack_timer <= 0:
			if attack_state == 1 and next_attack_queued:
				# Trigger attack2 smoothly right as attack1 ends
				attack_state = 2
				attack_timer = 0.5 # <-- Change to exact duration of attack2
				animated_sprite.play("attack2")
				next_attack_queued = false # Reset the queue
			else:
				# No combo queued, return to normal
				attack_state = 0
				next_attack_queued = false
				
	# Start the attack combo from idle/running
	elif Input.is_action_just_pressed("a"):
		attack_state = 1
		attack_timer = 0.5 # <-- Change to exact duration of attack1
		animated_sprite.play("attack1")
		next_attack_queued = false

	# 5. BASE ANIMATIONS
	if attack_state == 0:
		if not is_on_floor():
			if velocity.y < 0:
				animated_sprite.play("jump")
			else:
				animated_sprite.play("fall")
		else:
			if direction != 0:
				animated_sprite.play("run")
			else:
				animated_sprite.play("idle")

	move_and_slide()
