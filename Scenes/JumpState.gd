extends State
class_name JumpState

@export var player: Player

# A micro-timer to fix the Same-Frame Double Jump Bug
var air_timer: float = 0.0

func enter() -> void:
	# Apply upward explosion exactly once
	player.velocity.y = player.JUMP_VELOCITY
	air_timer = 0.0

func physics_update(delta: float) -> void:
	air_timer += delta
	
	# 1. Apply gravity to pull us back down
	player.velocity += player.get_gravity() * delta

	# 2. Allow steering in the air
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		player.velocity.x = direction * player.SPEED
		player.last_horizontal_direction = direction
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)

	# 3. Variable Jump Height: If spacebar is let go early, kill momentum
	if Input.is_action_just_released("space") and player.velocity.y < 0:
		player.velocity.y *= player.decelerate_on_jump_release

	player.move_and_slide()

	# 4. TRANSITION MATRIX
	if player.velocity.y >= 0: # Apex reached
		transitioned.emit(self, "fall")
		
	if Input.is_action_just_pressed("shift") and player.dash_cooldown <= 0:
		transitioned.emit(self, "dash")

	# 5. DOUBLE JUMP GATE
	# Must press space, must not have jumped twice, and must wait 3 frames
	if Input.is_action_just_pressed("space") and not player.has_double_jumped and air_timer > 0.05:
		player.velocity.y = player.JUMP_VELOCITY
		player.has_double_jumped = true
