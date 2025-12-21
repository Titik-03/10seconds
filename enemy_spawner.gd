extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_radius = 300.0

# Difficulty settings (loaded from GameSettings)
var spawn_interval = 3.0
var max_enemies = 5
var min_spawn_interval = 0.5
var difficulty_increase_rate = 0.05
var enemy_speed_multiplier = 1.0

var current_spawn_interval = 3.0
var game_time = 0.0
var base_max_enemies = 5

var spawn_timer: Timer
var current_enemy_count = 0

func _ready():
	# Load difficulty settings
	spawn_interval = GameSettings.get_setting("spawn_interval")
	max_enemies = GameSettings.get_setting("max_enemies")
	min_spawn_interval = GameSettings.get_setting("min_spawn_interval")
	difficulty_increase_rate = GameSettings.get_setting("difficulty_increase_rate")
	enemy_speed_multiplier = GameSettings.get_setting("enemy_speed_multiplier")
	base_max_enemies = max_enemies
	
	current_spawn_interval = spawn_interval
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func _process(delta):
	game_time += delta
	
	# Increase difficulty over time
	current_spawn_interval = max(min_spawn_interval, spawn_interval - (game_time * difficulty_increase_rate))
	spawn_timer.wait_time = current_spawn_interval
	
	# Also increase max enemies over time
	max_enemies = base_max_enemies + int(game_time / 10)  # +1 max enemy every 10 seconds

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
	
	# Scale enemy speed with difficulty AND time progression
	if "speed" in enemy:
		var time_multiplier = 1.0 + (game_time * 0.01)  # 1% faster per second
		enemy.speed = enemy.speed * enemy_speed_multiplier * min(time_multiplier, 2.0)
	
	# Connect to track when enemy is removed
	enemy.tree_exiting.connect(_on_enemy_died)
	
	get_parent().add_child(enemy)
	current_enemy_count += 1

func _on_enemy_died():
	current_enemy_count -= 1
