extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

# Toggle this in the Inspector for Level 2 later!
@export var inverted_controls = false

func _physics_process(delta):
	# 1. Add Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Move (with Troll support)
	var direction = Input.get_axis("ui_left", "ui_right")
	
	if inverted_controls:
		direction = -direction # Flip controls if troll is on

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# 4. The Win Function
# MAKE SURE your Door signal is connected to this specific name!
func _on_door_reached(body):
	if body.name == "player" or body.name == "Player":
 		print("YOU WIN! LOADING NEXT LEVEL...")
		get_tree().paused = truedwdd
