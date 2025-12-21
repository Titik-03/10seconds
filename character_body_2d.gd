extends CharacterBody2D

var movespeed = 500
var bullet_speed = 2000
var bullet = preload("res://bullet.tscn")
var is_dead = false

func _ready():
	if has_node("Area2D"):
		if not $Area2D.body_entered.is_connected(_on_Area2D_body_entered):
			$Area2D.body_entered.connect(_on_Area2D_body_entered)

func _physics_process(_delta):
	if is_dead:
		return
		
	var motion = Vector2.ZERO
	
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("right"):
		motion.x += 1 
	if Input.is_action_pressed("left"):
		motion.x -= 1 
	motion = motion.normalized()
	
	velocity = motion * movespeed
	move_and_slide()
	
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("LMB"):
		fire()

func fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
func kill():
	if is_dead:
		return
		
	is_dead = true
	set_physics_process(false)
	
	# Call game lost
	var game_ui = get_tree().get_first_node_in_group("GameUI")
	if game_ui and game_ui.has_method("game_lost"):
		game_ui.game_lost()
	else:
		# Fallback if game_ui not found
		await get_tree().create_timer(0.3).timeout
		get_tree().reload_current_scene()
	
func _on_Area2D_body_entered(body: Node2D) -> void:
	if is_dead:
		return
		
	if body is CharacterBody2D and body != self:
		kill()
