extends CanvasLayer

@export var countdown_time = 10
var time_left = 0
var score = 0
var game_over = false

@onready var timer_label = $Label
@onready var score_label = $"../CanvasLayer2/Label"

func _ready():
	add_to_group("GameUI")
	time_left = countdown_time
	update_score_display()

func _process(delta):
	if game_over:
		return
	
	time_left -= delta
	
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
	score += points
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score)

func game_won():
	if game_over:
		return
	
	game_over = true
	print("YOU WIN! Final Score: ", score)
	timer_label.text = "YOU WIN!"
	timer_label.modulate = Color.GREEN
	
	# Show the YouWinMenu
	var you_win_menu = get_tree().get_first_node_in_group("YouWinMenu")
	if you_win_menu and you_win_menu.has_method("show_you_win"):
		you_win_menu.show_you_win(score)
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
	
	# Show the GameOverMenu
	var game_over_menu = get_tree().get_first_node_in_group("GameOverMenu")
	if game_over_menu and game_over_menu.has_method("show_game_over"):
		game_over_menu.show_game_over(score)
	else:
		# Fallback if menu not found
		get_tree().paused = true
		await get_tree().create_timer(2.0, true, false, true).timeout
		get_tree().paused = false
		get_tree().reload_current_scene()
