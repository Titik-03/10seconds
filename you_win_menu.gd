extends CanvasLayer

var pause_panel
var restart_button
var quit_button

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("YouWinMenu")  # Add to correct group
	
	# Hide at start
	visible = false
	
	# Find the panel
	pause_panel = find_child("PausePanel", true, false)
	
	# Find buttons
	restart_button = find_child("RestartButton", true, false)
	quit_button = find_child("QuitButton", true, false)
	
	# Connect buttons
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	
	print("YouWinMenu ready!")

func show_you_win(final_score: int):
	print("=== YOU WIN MENU SHOWN === Score: ", final_score)
	visible = true
	get_tree().paused = true

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
