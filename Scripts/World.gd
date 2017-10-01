extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var player_scene = preload("res://Scenes/Player.tscn");
var timer;
var tween;
var camera;
const RESPAWN_DELAY = 0.8;
var timer_running = false;
var tween_running = false;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	timer = get_node("RespawnTimer");
	timer.connect("timeout", self, "respawn_player");
	tween = get_node("RespawnTween");
	camera = get_node("RespawnCamera");
	set_fixed_process(true);
	spawn_player();
	pass

func spawn_player():
	var player = player_scene.instance();
	player.set_pos(get_node("SpawnLocation").get_pos());
	player.get_node("Camera2D").make_current();
	player.show();
	add_child(player);

func replace_player(obj=null, key=null):
	print("replacing");
	tween_running = false;
	remove_child(get_node("Player"));
	spawn_player();
	print("respawned");

func tween_log(o, k, e, v):
	print("tween step");

func respawn_player():
	timer_running = false;
	timer.stop();
	
	replace_player();
#	if tween_running:
#		return;
#	print("tweening");
#	timer.set_one_shot(false);
#	var player = get_node("Player");
#	player.hide();
#	camera.set_pos(player.get_node("Camera2D").get_global_pos());
#	camera.make_current();
#	tween.connect("tween_complete", self, "replace_player");
#	tween.connect("tween_step", self, "tween_log");
#	tween.interpolate_property(camera, "transform/pos", camera.get_pos(), get_node("SpawnLocation").get_pos() + Vector2(0, -64), 0.2, Tween.TRANS_EXPO, Tween.EASE_OUT);
#	tween.start();
#	print("foo");
#	print(tween.is_active());
#	tween_running = true;
#	

func player_died():
	if not timer_running and not tween_running:
		timer_running = true;
		print("died");
		timer.set_wait_time(RESPAWN_DELAY);
	#	timer.set_one_shot(true);
		timer.start();

func _process(delta):
	
	pass
