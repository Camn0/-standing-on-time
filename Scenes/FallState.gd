extends State
class_name FallState

@export var player: Player

func physics_update(delta: float) -> void:
	# 1. Apply gravity continuously
	player.velocity += player.get_gravity() * delta

	# 2. Air steering
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		player.velocity.x = direction * player.SPEED
		player.last_horizontal_direction = direction
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

	player.move_and_slide()

	# 3. TRANSITION MATRIX
	if player.is_on_floor():
		if Input.get_axis("left", "right") != 0:
			transitioned.emit(self, "run")
		else:
			transitioned.emit(self, "idle")
			
	if Input.is_action_just_pressed("shift") and player.dash_cooldown <= 0:
		transitioned.emit(self, "dash")

	# 4. LATE DOUBLE JUMP GATE (If falling off a ledge)
	if Input.is_action_just_pressed("space") and not player.has_double_jumped:
		transitioned.emit(self, "jump") # Sending it back to JumpState handles the physics automatically
		player.has_double_jumped = true
