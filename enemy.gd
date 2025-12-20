extends CharacterBody2D

var motion = Vector2()
func _ready():
	pass
func _physics_process(delta):
	var Player = get_parent().get_node("Player")
	
	position += (Player.position - position)/50
	look_at(Player.position)
	
	move_and_collide(motion)


func _on_area_2d_body_entered(body):
	# Check if the body belongs to the "projectile" group
	if body.is_in_group("projectile"):
		body.queue_free() # Delete the bullet
		queue_free()      # Delete the enemy
