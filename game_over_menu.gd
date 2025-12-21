extends CanvasLayer

var retry_button
var quit_button

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("GameOverMenu")
	
	# Hide everything at start
	visible = false
	
	print("GameOverMenu ready!")

func show_game_over(final_score: int):
	print("=== GAME OVER MENU SHOWN ===")
	visible = true
	get_tree().paused = true
	
	# Find and connect buttons now
	retry_button = find_child("RetryButton", true, false)
	quit_button = find_child("QuitButton", true, false)
	
	if retry_button and not retry_button.pressed.is_connected(_on_retry_pressed):
		retry_button.pressed.connect(_on_retry_pressed)
		print("Retry button connected")
	
	if quit_button and not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)
		print("Quit button connected")

func _on_retry_pressed():
	print("RETRY CLICKED!")
	visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	print("QUIT CLICKED!")
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
