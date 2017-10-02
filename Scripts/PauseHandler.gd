extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var pause_pressed = false;
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true);

func _process(delta):
	var pause = Input.is_action_pressed("pause_game");
	if pause and not pause_pressed:
		get_tree().set_pause(not get_tree().is_paused());
	pause_pressed = pause;
