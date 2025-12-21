extends CanvasLayer

@onready var pause_panel = $PausePanel
var resume_button
var restart_button
var quit_button

var is_paused = false

func _ready():
	# Set process mode to always so this works when paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	pause_panel.visible = false
	
	# Safely get buttons
	resume_button = pause_panel.find_child("ResumeButton", true, false)
	restart_button = pause_panel.find_child("RestartButton", true, false)
	quit_button = pause_panel.find_child("QuitButton", true, false)
	
	# Connect only if buttons exist
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
		print("Resume button connected")
	else:
		print("ERROR: Resume button not found!")
		
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		print("Restart button connected")
	else:
		print("ERROR: Restart button not found!")
		
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		print("Quit button connected")
	else:
		print("ERROR: Quit button not found!")

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause()

func toggle_pause():
	is_paused = !is_paused
	pause_panel.visible = is_paused
	get_tree().paused = is_paused
	print("Game paused: ", is_paused)

func _on_resume_pressed():
	print("Resume pressed!")
	toggle_pause()

func _on_restart_pressed():
	print("Restart button clicked!")
	get_tree().paused = false
	await get_tree().process_frame  # Wait one frame
	get_tree().reload_current_scene()

func _on_quit_pressed():
	print("Quit pressed!")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
