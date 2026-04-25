extends State
class_name DashState

@export var player: Player
@export var dash_duration: float = 0.05

var dash_timer: float = 0.0
var dash_direction: float = 1.0

func enter() -> void:
	dash_timer = dash_duration
	# Tell the motherboard to start the cooldown clock
	player.dash_cooldown = 1.0 
	dash_direction = player.last_horizontal_direction

func physics_update(delta: float) -> void:
	dash_timer -= delta
	
	# 1. PHYSICS OVERRIDE: Destroy gravity temporarily
	player.velocity.y = 0 
	
	# 2. Lock X velocity to max speed
	player.velocity.x = dash_direction * player.dash_range * player.SPEED
	
	player.move_and_slide()
	
	# 3. TRANSITION MATRIX (End of Dash)
	if dash_timer <= 0.0:
		if not player.is_on_floor():
			transitioned.emit(self, "fall")
		elif Input.get_axis("left", "right") != 0:
			transitioned.emit(self, "run")
		else:
			transitioned.emit(self, "idle")
