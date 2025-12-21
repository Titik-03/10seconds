extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_interval = 3.0
@export var max_enemies = 5
@export var spawn_radius = 300.0

var spawn_timer: Timer
var current_enemy_count = 0

func _ready():
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if current_enemy_count < max_enemies:
		spawn_enemy()

func spawn_enemy():
	if not enemy_scene:
		print("Error: No enemy scene assigned!")
		return
	
	var enemy = enemy_scene.instantiate()
	
	# Random position
	var angle = randf() * TAU
	var distance = randf_range(150, spawn_radius)
	var spawn_pos = global_position + Vector2(cos(angle), sin(angle)) * distance
	
	enemy.global_position = spawn_pos
	
	# Connect to track when enemy is removed
	enemy.tree_exiting.connect(_on_enemy_died)
	
	get_parent().add_child(enemy)
	current_enemy_count += 1
	
	print("Spawned enemy. Count: ", current_enemy_count)

func _on_enemy_died():
	current_enemy_count -= 1
	print("Enemy died. Count: ", current_enemy_count)
