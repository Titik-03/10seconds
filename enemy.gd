extends CharacterBody2D

@export var speed = 300.0
var motion = Vector2()

func _ready():
	# Add slight random variation to enemy speed
	speed = speed * randf_range(0.9, 1.1)

func _physics_process(delta):
	var Player = get_parent().get_node_or_null("Player")
	if not Player:
		return
	
	# Calculate direction and move at constant speed
	var direction = (Player.position - position).normalized()
	position += direction * speed * delta
	
	look_at(Player.position)
	
	move_and_collide(motion)

func _on_area_2d_body_entered(body):
	# Check if the body belongs to the "projectile" group
	if body.is_in_group("projectile"):
		body.queue_free() # Delete the bullet
		
		# Add score when enemy dies
		var game_ui = get_tree().get_first_node_in_group("GameUI")
		if game_ui and game_ui.has_method("add_score"):
			game_ui.add_score(1)
		
		# Spawn death effect
		spawn_death_effect()
		
		queue_free() # Delete the enemy

func spawn_death_effect():
	# Create explosion particles
	var particles = CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.amount = 12
	particles.lifetime = 0.4
	particles.speed_scale = 2.0
	particles.direction = Vector2.ZERO
	particles.spread = 180.0
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.gravity = Vector2.ZERO
	particles.scale_amount_min = 3.0
	particles.scale_amount_max = 6.0
	particles.color = Color(1.0, 0.5, 0.1)  # Orange
	
	# Color gradient from orange to transparent
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1.0, 0.6, 0.1, 1.0))
	gradient.set_color(1, Color(1.0, 0.2, 0.0, 0.0))
	particles.color_ramp = gradient
	
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	
	# Auto-remove after particles finish
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(func(): particles.queue_free())
