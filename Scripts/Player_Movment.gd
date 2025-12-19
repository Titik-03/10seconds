extends CharacterBody2D

@export var speed: float = 300.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1500.0
@export var friction: float = 1200.0

# Advanced jump mechanics
@export var coyote_time: float = 0.1  # Grace period after leaving ground
@export var jump_buffer_time: float = 0.1  # Early jump input window

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Coyote time (can jump shortly after leaving platform)
	if is_on_floor():
		coyote_timer = coyote_time
		was_on_floor = true
	else:
		coyote_timer -= delta
		if was_on_floor and velocity.y > 0:
			was_on_floor = false
	
	# Jump buffering (remember jump press before landing)
	if Input.is_key_pressed(KEY_W) or Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta
	
	# Execute jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0
		coyote_timer = 0
	
	# Horizontal movement
	var direction = 0.0
	if Input.is_key_pressed(KEY_A):
		direction = -1.0
	if Input.is_key_pressed(KEY_D):
		direction = 1.0
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	move_and_slide()
# This handles the Door win condition
func _on_door_reached(body):
	if body.name == "Player":
		# Change "Label" to the actual name of your Win text node
		if has_node("../Label"):
			get_node("../Label").visible = true
		
		print("YOU WIN!")
		get_tree().paused = true
