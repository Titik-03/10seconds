extends PathFollow2D

@export var speed := 200.0
@export var move_amount := 100.0  # how far it moves once

var moving := false
var moved := false
var start_progress := 0.0

func _physics_process(delta):
	if not moving:
		return

	progress += speed * delta

	if progress >= start_progress + move_amount:
		moving = false
		moved = true

func _on_trap_body_entered(body: Node2D) -> void:
	if body.name != "Player":
		return
	if moved:
		return   # already triggered once

	start_progress = progress
	moving = true
