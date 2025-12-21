extends Node

# Global game settings - autoloaded singleton

enum Difficulty { EASY = 1, NORMAL = 2, EXTREME = 3 }

var current_difficulty: Difficulty = Difficulty.EASY

# Difficulty parameters
var difficulty_settings = {
	Difficulty.EASY: {
		"name": "Easy",
		"color": Color.GREEN,
		"countdown_time": 60,
		"spawn_interval": 3.0,
		"min_spawn_interval": 1.5,
		"max_enemies": 5,
		"enemy_speed_multiplier": 1.0,
		"player_health": 5,
		"score_multiplier": 1.0,
		"difficulty_increase_rate": 0.02
	},
	Difficulty.NORMAL: {
		"name": "Normal",
		"color": Color.YELLOW,
		"countdown_time": 45,
		"spawn_interval": 2.0,
		"min_spawn_interval": 0.8,
		"max_enemies": 8,
		"enemy_speed_multiplier": 1.3,
		"player_health": 3,
		"score_multiplier": 1.5,
		"difficulty_increase_rate": 0.05
	},
	Difficulty.EXTREME: {
		"name": "Extreme",
		"color": Color.RED,
		"countdown_time": 30,
		"spawn_interval": 1.0,
		"min_spawn_interval": 0.3,
		"max_enemies": 15,
		"enemy_speed_multiplier": 1.8,
		"player_health": 1,
		"score_multiplier": 3.0,
		"difficulty_increase_rate": 0.1
	}
}

func get_setting(key: String):
	return difficulty_settings[current_difficulty].get(key)

func get_difficulty_name() -> String:
	return difficulty_settings[current_difficulty]["name"]

func get_difficulty_color() -> Color:
	return difficulty_settings[current_difficulty]["color"]

func set_difficulty(level: int):
	match level:
		1: current_difficulty = Difficulty.EASY
		2: current_difficulty = Difficulty.NORMAL
		3: current_difficulty = Difficulty.EXTREME
		_: current_difficulty = Difficulty.EASY
	print("Difficulty set to: ", get_difficulty_name())
