extends CharacterBody2D

@onready var anim = $AnimatedSprite2D

# ---------------------
# Movement parameters
# ---------------------
@export var speed: float = 150.0
@export var jump_velocity: float = -400.0
@export var acceleration: float = 1500.0

# ---------------------
# Advanced jump mechanics
# ---------------------
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

# ---------------------
# Internal state
# ---------------------
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false
var dead := false

func _ready():
	anim.play("idle")

func _physics_process(delta):
	if dead:
		return  # Stop movement if dead

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
		was_on_floor = true
	else:
		coyote_timer -= delta
		if was_on_floor and velocity.y > 0:
			was_on_floor = false

	# Jump buffering
	if Input.is_key_pressed(KEY_W) or Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Execute jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0
		coyote_timer = 0

	# Horizontal movement (Level Devil style: instant stop when no input)
	var direction := 0.0
	if Input.is_key_pressed(KEY_A):
		direction = -1.0
	elif Input.is_key_pressed(KEY_D):
		direction = 1.0

	if direction != 0:
		velocity.x = direction * speed
	else:
		velocity.x = 0  # stop instantly when no input

	move_and_slide()

	# ---------------------
	# Animations
	# ---------------------
	if dead:
		pass  # don't change animations if dead
	elif abs(velocity.x) > 0:
		if anim.animation != "run":
			anim.play("run")
	else:
		if anim.animation != "idle":
			anim.play("idle")

# ---------------------
# Door / Win Condition
# ---------------------
func _on_door_reached(body):
	if body.name == "Player":
		if has_node("../Label"):
			get_node("../Label").visible = true
		print("YOU WIN!")
		get_tree().paused = true

# ---------------------
# Death Function
# ---------------------
func die():
	if dead:
		return
	dead = true

	anim.play("die")  # play death animation

	# Wait for animation to finish before reloading
	var frames_resource = anim.sprite_frames
	var anim_length = frames_resource.get_frame_count("die") / frames_resource.get_animation_speed("die")
	await get_tree().create_timer(anim_length).timeout

	get_tree().reload_current_scene()
