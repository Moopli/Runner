extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var player_scene = preload("res://Scenes/Player.tscn");
var timer;
var tween;
var camera;
var intro_screen;
const RESPAWN_DELAY = 0.8;
var timer_running = false;
var tween_running = false;
var current_checkpoint = null;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer = get_node("RespawnTimer");
	timer.connect("timeout", self, "respawn_player");
	tween = get_node("RespawnTween");
	camera = get_node("Camera2D");
	intro_screen = get_node("IntroScreen");
	var bgarea = get_node("BackgroundArea");
	set_process(true);
	spawn_player(true);
	camera.make_current();
	pass

func end_intro():
	remove_child(intro_screen);
	get_node("Player").end_intro_scene();

func set_checkpoint(new_checkpoint):
	if current_checkpoint != null:
		current_checkpoint.disable_checkpoint();
	current_checkpoint = new_checkpoint;

func spawn_player(intro_spawn = false):
	var player = player_scene.instance();
	if current_checkpoint == null:
		player.set_pos(get_node("SpawnLocation").get_pos());
	else:
		player.set_pos(current_checkpoint.get_pos());
	if not intro_spawn:
		player.get_node("Camera2D").make_current();
	else:
		player.begin_intro_scene();
	player.show();
	add_child(player);

func spawn_at_checkpoint(checkpoint):
	set_checkpoint(get_node(checkpoint));
	replace_player();

func replace_player():
#	print("replacing");
	var player = get_node("Player");
	if player != null: remove_child(player);
	spawn_player();
#	print("respawned");

func respawn_player():
	timer_running = false;
	timer.stop();
	replace_player();

func player_died():
	if not timer_running and not tween_running:
		timer_running = true;
#		print("died");
		timer.set_wait_time(RESPAWN_DELAY);
	#	timer.set_one_shot(true);
		timer.start();

func _process(delta):
	if Input.is_action_pressed("ui_cheat"):
		print("cheat");
		spawn_at_checkpoint("Checkpoint 11");
		pass
	pass
