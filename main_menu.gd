extends Control

@onready var play_button := $Menubuttons/Button
@onready var quit_button := $Menubuttons/Button2

var selected_difficulty = 1
var difficulty_label: Label
var difficulty_buttons_array: Array = []

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Create difficulty selection UI
	create_difficulty_selector()
	
	# Select Easy by default
	select_difficulty(1)

func create_difficulty_selector():
	# Create container for difficulty selection - positioned below the menu buttons
	var container = VBoxContainer.new()
	container.name = "DifficultyContainer"
	container.set_anchors_preset(Control.PRESET_CENTER)
	container.position = Vector2(450, 500)
	container.add_theme_constant_override("separation", 10)
	add_child(container)
	
	# Title label
	var title = Label.new()
	title.text = "SELECT DIFFICULTY"
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color.WHITE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(title)
	
	# Buttons container
	var buttons_hbox = HBoxContainer.new()
	buttons_hbox.add_theme_constant_override("separation", 15)
	buttons_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	container.add_child(buttons_hbox)
	
	# Create difficulty buttons
	var difficulties = [
		{"level": 1, "name": "EASY", "color": Color.GREEN},
		{"level": 2, "name": "NORMAL", "color": Color.YELLOW},
		{"level": 3, "name": "EXTREME", "color": Color.RED}
	]
	
	for diff in difficulties:
		var btn = Button.new()
		btn.text = diff["name"]
		btn.custom_minimum_size = Vector2(100, 40)
		btn.add_theme_font_size_override("font_size", 16)
		btn.add_theme_color_override("font_color", diff["color"])
		btn.pressed.connect(select_difficulty.bind(diff["level"]))
		buttons_hbox.add_child(btn)
		difficulty_buttons_array.append(btn)
	
	# Description label
	difficulty_label = Label.new()
	difficulty_label.text = ""
	difficulty_label.add_theme_font_size_override("font_size", 14)
	difficulty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(difficulty_label)

func select_difficulty(level: int):
	selected_difficulty = level
	print("Difficulty selected: ", level)
	
	var descriptions = {
		1: {"text": "5 Lives | Slow enemies | 1x Score", "color": Color.GREEN},
		2: {"text": "3 Lives | Fast enemies | 1.5x Score", "color": Color.YELLOW},
		3: {"text": "1 Life | Brutal speed | 3x Score", "color": Color.RED}
	}
	
	# Update description label
	if difficulty_label:
		difficulty_label.text = descriptions[level]["text"]
		difficulty_label.add_theme_color_override("font_color", descriptions[level]["color"])
	
	# Update button visuals - highlight selected
	for i in difficulty_buttons_array.size():
		var btn = difficulty_buttons_array[i]
		if i + 1 == selected_difficulty:
			# Selected button - bright and bordered
			btn.modulate = Color.WHITE
			var style = StyleBoxFlat.new()
			style.bg_color = Color(0.1, 0.1, 0.3, 0.9)
			style.border_width_bottom = 2
			style.border_width_top = 2
			style.border_width_left = 2
			style.border_width_right = 2
			style.border_color = Color.WHITE
			style.corner_radius_top_left = 4
			style.corner_radius_top_right = 4
			style.corner_radius_bottom_left = 4
			style.corner_radius_bottom_right = 4
			btn.add_theme_stylebox_override("normal", style)
			btn.add_theme_stylebox_override("hover", style)
		else:
			# Unselected button - dimmed
			btn.modulate = Color(0.5, 0.5, 0.5)
			btn.remove_theme_stylebox_override("normal")
			btn.remove_theme_stylebox_override("hover")

func _on_play_pressed():
	print("PLAY PRESSED - Difficulty: ", selected_difficulty)
	GameSettings.set_difficulty(selected_difficulty)
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_pressed():
	print("QUIT PRESSED")
	get_tree().quit()
