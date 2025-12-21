extends CharacterBody2D

var movespeed = 500
var bullet_speed = 2000
var bullet = preload("res://bullet.tscn")
var is_dead = false

# Health system
var max_health = 3
var current_health = 3
var is_invincible = false
var invincibility_time = 1.5

# Visual effects
var flash_duration = 0.1
var sprite_node: Sprite2D

func _ready():
	# Load health from difficulty settings
	max_health = GameSettings.get_setting("player_health")
	current_health = max_health
	sprite_node = $Sprite2D if has_node("Sprite2D") else null
	
	if has_node("Area2D"):
		if not $Area2D.body_entered.is_connected(_on_Area2D_body_entered):
			$Area2D.body_entered.connect(_on_Area2D_body_entered)
	
	# Update health display
	update_health_display()
	
	# Create thruster effect
	create_thruster()

func create_thruster():
	thruster = CPUParticles2D.new()
	thruster.emitting = false
	thruster.amount = 20
	thruster.lifetime = 0.3
	thruster.local_coords = false
	thruster.direction = Vector2(-1, 0)
	thruster.spread = 15.0
	thruster.initial_velocity_min = 100.0
	thruster.initial_velocity_max = 150.0
	thruster.gravity = Vector2.ZERO
	thruster.scale_amount_min = 2.0
	thruster.scale_amount_max = 4.0
	
	# Blue flame gradient
	var gradient = Gradient.new()
	gradient.set_color(0, Color(0.3, 0.6, 1.0, 1.0))
	gradient.set_color(1, Color(0.1, 0.3, 0.8, 0.0))
	thruster.color_ramp = gradient
	
	thruster.position = Vector2(-25, 0)  # Behind the ship
	add_child(thruster)

func update_thruster(is_moving: bool):
	if thruster:
		thruster.emitting = is_moving

# Thruster particles
var thruster: CPUParticles2D

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
	
	# Update thruster based on movement
	update_thruster(motion != Vector2.ZERO)
	
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("LMB"):
		fire()

func fire():
	var bullet_instance = bullet.instantiate()
	bullet_instance.position = get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_central_impulse(Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	
	# Muzzle flash effect
	spawn_muzzle_flash()

func spawn_muzzle_flash():
	var flash = CPUParticles2D.new()
	flash.emitting = true
	flash.one_shot = true
	flash.explosiveness = 1.0
	flash.amount = 6
	flash.lifetime = 0.15
	flash.direction = Vector2(1, 0).rotated(rotation)
	flash.spread = 25.0
	flash.initial_velocity_min = 150.0
	flash.initial_velocity_max = 250.0
	flash.gravity = Vector2.ZERO
	flash.scale_amount_min = 2.0
	flash.scale_amount_max = 4.0
	flash.color = Color(1.0, 0.9, 0.3)  # Yellow flash
	
	flash.global_position = global_position + Vector2(20, 0).rotated(rotation)
	get_tree().current_scene.add_child(flash)
	
	# Auto cleanup
	get_tree().create_timer(0.5).timeout.connect(func(): 
		if is_instance_valid(flash): flash.queue_free()
	)

func kill():
	if is_dead:
		return
		
	is_dead = true
	set_physics_process(false)
	
	# Call game lost on the game timer
	var game_ui = get_tree().get_first_node_in_group("GameUI")
	if game_ui and game_ui.has_method("game_lost"):
		game_ui.game_lost()
	else:
		# Fallback: try to show game over menu directly
		var game_over_menu = get_tree().get_first_node_in_group("GameOverMenu")
		if game_over_menu and game_over_menu.has_method("show_game_over"):
			game_over_menu.show_game_over(0)
		else:
			# Last resort fallback
			await get_tree().create_timer(0.3).timeout
			get_tree().reload_current_scene()

func take_damage():
	if is_dead or is_invincible:
		return
	
	current_health -= 1
	update_health_display()
	
	# Screen shake effect
	trigger_screen_shake()
	
	# Flash effect
	flash_damage()
	
	if current_health <= 0:
		kill()
	else:
		# Start invincibility
		start_invincibility()

func start_invincibility():
	is_invincible = true
	
	# Blink effect during invincibility
	var blink_count = int(invincibility_time / 0.15)
	for i in blink_count:
		if sprite_node:
			sprite_node.modulate.a = 0.3
		await get_tree().create_timer(0.075).timeout
		if sprite_node:
			sprite_node.modulate.a = 1.0
		await get_tree().create_timer(0.075).timeout
	
	is_invincible = false

func flash_damage():
	if sprite_node:
		sprite_node.modulate = Color.RED
		await get_tree().create_timer(flash_duration).timeout
		sprite_node.modulate = Color.WHITE

func trigger_screen_shake():
	var camera = get_viewport().get_camera_2d()
	if camera:
		var original_offset = camera.offset
		for i in 5:
			camera.offset = original_offset + Vector2(randf_range(-8, 8), randf_range(-8, 8))
			await get_tree().create_timer(0.05).timeout
		camera.offset = original_offset

func update_health_display():
	var game_ui = get_tree().get_first_node_in_group("GameUI")
	if game_ui and game_ui.has_method("update_health"):
		game_ui.update_health(current_health, max_health)

func _on_Area2D_body_entered(body: Node2D) -> void:
	if is_dead:
		return
		
	if body is CharacterBody2D and body != self:
		take_damage()  # Take damage instead of instant kill
		body.queue_free()  # Destroy the enemy that hit us
