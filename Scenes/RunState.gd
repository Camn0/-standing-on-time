extends State
class_name RunState

@export var player: Player

func physics_update(delta: float) -> void:
	# 1. APPLY GRAVITY ALWAYS. move_and_slide() will automatically zero it out on the floor.
	player.velocity += player.get_gravity() * delta

	# 2. Input Polling
	var direction := Input.get_axis("left", "right")

	if direction != 0:
		player.velocity.x = direction * player.SPEED
		player.last_horizontal_direction = direction
	else:
		transitioned.emit(self, "idle")
		return

	# 3. Execute movement
	player.move_and_slide()

	# 4. Evaluate Transition Matrix
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
		return

	if Input.is_action_just_pressed("shift") and player.dash_cooldown <= 0:
		transitioned.emit(self, "dash")
