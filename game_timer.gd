extends CanvasLayer

@export var countdown_time = 60
var time_left = 0
var score = 0
var game_over = false
var score_multiplier = 1.0

# Combo system
var combo = 0
var combo_timer = 0.0
var combo_timeout = 2.0  # Time before combo resets
var max_combo = 0

# Kill counter
var total_kills = 0

@onready var timer_label = $Label
@onready var score_label = $"../CanvasLayer2/Label"

func _ready():
	add_to_group("GameUI")
	
	# Apply difficulty settings
	countdown_time = GameSettings.get_setting("countdown_time")
	score_multiplier = GameSettings.get_setting("score_multiplier")
	
	time_left = countdown_time
	update_score_display()
	
	# Create UI elements
	create_health_label()
	create_combo_label()
	create_difficulty_indicator()

func create_health_label():
	var health_label = Label.new()
	health_label.name = "HealthLabel"
	health_label.text = "❤️❤️❤️"
	health_label.add_theme_font_size_override("font_size", 24)
	health_label.position = Vector2(20, 60)
	add_child(health_label)

func create_combo_label():
	var combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.text = ""
	combo_label.add_theme_font_size_override("font_size", 20)
	combo_label.add_theme_color_override("font_color", Color.YELLOW)
	combo_label.position = Vector2(20, 100)
	add_child(combo_label)

func create_difficulty_indicator():
	var diff_label = Label.new()
	diff_label.name = "DifficultyLabel"
	diff_label.text = GameSettings.get_difficulty_name().to_upper()
	diff_label.add_theme_font_size_override("font_size", 16)
	diff_label.add_theme_color_override("font_color", GameSettings.get_difficulty_color())
	diff_label.position = Vector2(20, 140)
	add_child(diff_label)

func _process(delta):
	if game_over:
		return
	
	time_left -= delta
	
	# Update combo timer
	if combo > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo = 0
			update_combo_display()
	
	if time_left <= 0:
		time_left = 0
		game_won()
	
	timer_label.text = str(int(time_left))
	
	if time_left <= 5:
		timer_label.modulate = Color.RED
	elif time_left <= 20:
		timer_label.modulate = Color.YELLOW
	else:
		timer_label.modulate = Color.WHITE

func add_score(points = 1):
	# Combo system - increase combo and apply multiplier
	combo += 1
	combo_timer = combo_timeout
	if combo > max_combo:
		max_combo = combo
	
	# Apply combo multiplier AND difficulty multiplier
	var combo_multiplier = 1 + (combo * 0.1)  # 10% bonus per combo
	var final_points = int(points * combo_multiplier * score_multiplier)
	
	score += final_points
	total_kills += 1
	update_score_display()
	update_combo_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score) + "  |  Kills: " + str(total_kills)

func update_combo_display():
	var combo_label = get_node_or_null("ComboLabel")
	if combo_label:
		if combo >= 2:
			combo_label.text = "🔥 COMBO x" + str(combo) + "!"
			combo_label.modulate = Color(1, 1 - (combo * 0.1), 0)  # Gets more red with higher combo
		else:
			combo_label.text = ""

func update_health(current: int, max_hp: int):
	var health_label = get_node_or_null("HealthLabel")
	if health_label:
		var hearts = ""
		for i in current:
			hearts += "❤️"
		for i in (max_hp - current):
			hearts += "🖤"
		health_label.text = hearts

func game_won():
	if game_over:
		return
	
	game_over = true
	print("YOU WIN! Final Score: ", score)
	timer_label.text = "YOU WIN!"
	timer_label.modulate = Color.GREEN
	
	# Show the YouWinMenu with stats
	var you_win_menu = get_tree().get_first_node_in_group("YouWinMenu")
	if you_win_menu and you_win_menu.has_method("show_you_win"):
		you_win_menu.show_you_win(score, total_kills, max_combo)
	else:
		# Fallback if menu not found
		get_tree().paused = true
		await get_tree().create_timer(2.0, true, false, true).timeout
		get_tree().paused = false
		get_tree().change_scene_to_file("res://main_menu.tscn")

func game_lost():
	if game_over:
		return
	
	game_over = true
	print("GAME OVER! Final Score: ", score)
	timer_label.text = "GAME OVER"
	timer_label.modulate = Color.RED
	
	# Show the GameOverMenu with stats
	var game_over_menu = get_tree().get_first_node_in_group("GameOverMenu")
	if game_over_menu and game_over_menu.has_method("show_game_over"):
		game_over_menu.show_game_over(score, total_kills, max_combo)
	else:
		# Fallback if menu not found
		get_tree().paused = true
		await get_tree().create_timer(2.0, true, false, true).timeout
		get_tree().paused = false
		get_tree().reload_current_scene()
