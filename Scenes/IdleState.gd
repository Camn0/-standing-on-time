extends State
class_name IdleState

@export var player: Player

func physics_update(delta: float) -> void:
	# 1. APPLY GRAVITY ALWAYS. move_and_slide() will automatically zero it out on the floor.
	player.velocity += player.get_gravity() * delta
	
	# 2. Apply ground friction
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	
	# 3. Execute movement
	player.move_and_slide()

	# 4. Evaluate Transition Matrix
	if not player.is_on_floor():
		transitioned.emit(self, "fall")
		return

	if Input.get_axis("left", "right") != 0:
		transitioned.emit(self, "run")

	if Input.is_action_just_pressed("shift") and player.dash_cooldown <= 0:
		transitioned.emit(self, "dash")
