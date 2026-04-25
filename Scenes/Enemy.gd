extends CharacterBody2D
class_name BasicEnemy

enum AIState { IDLE, PATROL, CHASE, ATTACK, HIT, DEATH }
var current_state = AIState.IDLE

@export var SPEED = 100.0
@export var MAX_HEALTH = 5
@export var KNOCKBACK_RESISTANCE = 0.8 

var health = MAX_HEALTH
var direction = 1
var think_timer = 0.0 

# --- NEW: ENEMY COOLDOWN ---
var attack_cooldown = 0.0 

var target_player: Player = null
var is_in_attack_range: bool = false

@onready var sprite = $AnimatedSprite2D
@onready var ledge_detector = $LedgeDetector
@onready var attack_range = $AttackRange
@onready var chase_range = $ChaseRange 

func _ready() -> void:
	randomize() 
	if attack_range:
		attack_range.body_entered.connect(_on_attack_range_body_entered)
		attack_range.body_exited.connect(_on_attack_range_body_exited)
	if chase_range:
		chase_range.body_entered.connect(_on_chase_range_body_entered)
		chase_range.body_exited.connect(_on_chase_range_body_exited)
	if sprite:
		sprite.animation_finished.connect(_on_animated_sprite_2d_animation_finished)

	pick_random_state()

func _physics_process(delta: float) -> void:
	# 1. Tick down the enemy's attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta

	if not is_on_floor():
		velocity += get_gravity() * delta
		if current_state != AIState.HIT and current_state != AIState.DEATH:
			sprite.play("fall")
	else:
		# FIX: Return to current state animation when landing
		if sprite.animation == "fall":
			switch_state(current_state)

	match current_state:
		AIState.IDLE: process_idle(delta)
		AIState.PATROL: process_patrol(delta)
		AIState.CHASE: process_chase(delta) 
		AIState.ATTACK: velocity.x = move_toward(velocity.x, 0, SPEED)
		AIState.HIT:
			velocity.x = move_toward(velocity.x, 0, SPEED * 2 * delta)
			if velocity.x == 0 and is_on_floor(): switch_state(AIState.IDLE)
		AIState.DEATH:
			velocity.x = move_toward(velocity.x, 0, SPEED * delta)

	move_and_slide()

func process_idle(delta: float) -> void:
	# If player is standing next to us and we can attack, do it!
	if is_in_attack_range and target_player and attack_cooldown <= 0:
		switch_state(AIState.ATTACK)
		return

	velocity.x = move_toward(velocity.x, 0, SPEED)
	think_timer -= delta
	if think_timer <= 0: pick_random_state()

func process_patrol(delta: float) -> void:
	think_timer -= delta
	if is_on_wall() or not ledge_detector.is_colliding():
		flip_direction()
		switch_state(AIState.IDLE) 
		return

	velocity.x = direction * SPEED
	if think_timer <= 0: pick_random_state()

func process_chase(delta: float) -> void:
	if not target_player:
		switch_state(AIState.IDLE)
		return

	# If we catch up to the player, swing!
	if is_in_attack_range and attack_cooldown <= 0:
		switch_state(AIState.ATTACK)
		return
		
	# YOUR EXACT MATH FIX: -1 for Right, 1 for Left
	var dir_to_player = sign(target_player.global_position.x - global_position.x)
	
	if dir_to_player != 0 and dir_to_player != direction:
		flip_direction()
		
	if is_on_wall() or not ledge_detector.is_colliding():
		velocity.x = 0
		sprite.play("idle")
		return
		
	velocity.x = direction * (SPEED * 1.5)

func pick_random_state() -> void:
	if current_state in [AIState.DEATH, AIState.HIT, AIState.CHASE, AIState.ATTACK]: return
	if randf() > 0.5:
		switch_state(AIState.PATROL)
		think_timer = randf_range(1.5, 3.0) 
		if randf() > 0.5: flip_direction()
	else:
		switch_state(AIState.IDLE)
		think_timer = randf_range(1.0, 2.0)

func switch_state(new_state: AIState) -> void:
	current_state = new_state
	match current_state:
		AIState.IDLE: sprite.play("idle")
		AIState.PATROL, AIState.CHASE: sprite.play("run")
		AIState.ATTACK:
			if randf() > 0.5: sprite.play("attack1")
			else: sprite.play("attack2")
			
			# FIX: Wait for the visual "impact" frame before dealing damage
			# Change 0.2 to match when the enemy's hand/sword actually hits the player
			await get_tree().create_timer(0.2).timeout
			if current_state == AIState.ATTACK:
				deal_damage_to_player()
				
		AIState.HIT: sprite.play("take_hit")
		AIState.DEATH: sprite.play("death")

func flip_direction() -> void:
	direction *= -1 
	sprite.flip_h = direction < 0 
	ledge_detector.target_position.x *= -1
	if attack_range: attack_range.scale.x *= -1
	if chase_range: chase_range.scale.x *= -1

func _on_chase_range_body_entered(body: Node2D) -> void:
	if body is Player and current_state != AIState.DEATH:
		target_player = body
		if not is_in_attack_range: switch_state(AIState.CHASE)

func _on_chase_range_body_exited(body: Node2D) -> void:
	if body is Player:
		target_player = null
		if current_state == AIState.CHASE: switch_state(AIState.IDLE)

func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Player and current_state != AIState.DEATH:
		is_in_attack_range = true
		# Only attack if cooldown is ready
		if attack_cooldown <= 0:
			switch_state(AIState.ATTACK)

func _on_attack_range_body_exited(body: Node2D) -> void:
	if body is Player:
		is_in_attack_range = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == AIState.ATTACK:
		# 2. STOP SPAMMING: Put the enemy in timeout for 1.0 seconds
		attack_cooldown = 1.0 
		switch_state(AIState.IDLE) 
		
	elif current_state == AIState.DEATH:
		queue_free() 

# NEW FUNCTION: Handles the actual damage logic
func deal_damage_to_player() -> void:
	if is_in_attack_range and target_player:
		# YOUR EXACT MATH FIX
		var knockback_dir = sign(target_player.global_position.x - global_position.x)
		if knockback_dir == 0: knockback_dir = direction 
		target_player.take_hit(1, knockback_dir * 500.0) 

func take_hit(damage: int, knockback_force: float) -> void:
	if current_state == AIState.DEATH: return
	health -= damage
	if health <= 0: switch_state(AIState.DEATH)
	else:
		velocity.y = -100.0 
		velocity.x = knockback_force * KNOCKBACK_RESISTANCE
		switch_state(AIState.HIT)
