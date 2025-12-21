extends RigidBody2D

# Auto-destroy bullet after timeout or leaving screen
var lifetime = 5.0

func _ready():
	# Set up auto-destruction timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	add_child(timer)
	timer.start()

func _on_timeout():
	queue_free()

func _physics_process(_delta):
	# Destroy if too far from origin (optimization)
	if global_position.length() > 3000:
		queue_free()
