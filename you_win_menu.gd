extends CanvasLayer

var game_over_panel
var retry_button
var quit_button
var score_label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("GameOverMenu")  # Add to group
	
	# Find the panel with any name
	game_over_panel = find_child("GameOverPanel", true, false)
	if not game_over_panel:
		game_over_panel = find_child("VBoxContainer", true, false)
	
	if game_over_panel:
		game_over_panel.visible = false
	else:
		print("ERROR: Could not find GameOverPanel!")
		return
	
	# Find buttons
	retry_button = game_over_panel.find_child("RetryButton", true, false)
	quit_button = game_over_panel.find_child("QuitButton", true, false)
	score_label = game_over_panel.find_child("ScoreLabel", true, false)
	
	# Connect buttons
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func show_game_over(final_score: int):
	print("show_game_over called with score: ", final_score)
	if game_over_panel:
		game_over_panel.visible = true
		print("Game over panel set to visible")
	else:
		print("ERROR: game_over_panel is null!")
	
	if score_label:
		score_label.text = "Final Score: " + str(final_score)
	get_tree().paused = true
	print("Game paused")

func _on_retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
