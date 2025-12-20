extends CharacterBody2D

var movespeed = 500
var bullet_speed = 2000
var bullet = preload("res://bullet.tscn")

func _ready():
	pass

func _physics_process(_delta):
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
	# FIX 1: Use 'instantiate()' instead of 'instance()' in Godot 4
	var bullet_instance = bullet.instantiate()
	
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	
	# FIX 2: In Godot 4, apply_impulse arguments are swapped!
	# Old (Godot 3): apply_impulse(offset, force)
	# New (Godot 4): apply_impulse(force, offset)
	# BEST FIX: Use 'apply_central_impulse' to avoid confusion
	bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
func kill():
	get_tree().reload_current_scene()
	
func _on_Area2D_body_entered(body: Node2D) -> void:
	if "Enemy" in body.name:
		kill() # Replace with function body.
