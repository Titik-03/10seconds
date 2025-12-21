extends CharacterBody2D

@export var speed = 300.0
var motion = Vector2()

func _ready():
	pass

func _physics_process(delta):
	var Player = get_parent().get_node("Player")
	
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
		
		queue_free() # Delete the enemy
