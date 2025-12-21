extends Control

@onready var play_button := $Menubuttons/Button
@onready var quit_button := $Menubuttons/Button2

func _ready():
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed():
	print("PLAY PRESSED")
	get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_pressed():
	print("QUIT PRESSED")
	get_tree().quit()
