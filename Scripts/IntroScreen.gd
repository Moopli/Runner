extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var title_card_scene = preload("res://Scenes/TitleCard.tscn");
var title_cards_fast_moving = [];
var title_cards_slow_move_blinking = [];
var title_card_static = null;
var time = 0;
var add_fast_timer = 0;
const ADD_FAST_DT = 0.37;
const FAST_CARD_MIN_SPEED = -21437;
const FAST_CARD_MAX_SPEED = -214370;
var fast_card_speed = FAST_CARD_MIN_SPEED;

const END_TIME = 1.6;
const SHOW_TITLE_TIME = 0.8;

var title_shown = false;
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	

	set_fixed_process(true);


func _fixed_process(delta):
	if time > END_TIME:
		get_parent().end_intro();
		return;
	if add_fast_timer > ADD_FAST_DT and time < SHOW_TITLE_TIME:
		add_fast_timer = 0;
		var title_card = title_card_scene.instance();
		title_card.set_pos(Vector2(0, 800));
		title_card.set_opacity(0.8);
		title_cards_fast_moving.append(title_card);
		add_child(title_card);
	
	for card in title_cards_fast_moving:
		var y = card.get_pos().y;
		card.set_pos(Vector2(0, fmod(y + fast_card_speed * delta, 2129) + 200));
	
	if time > SHOW_TITLE_TIME and title_card_static == null:
		title_card_static = title_card_scene.instance();
		add_child(title_card_static);
	if time > SHOW_TITLE_TIME + 0.1 and time < SHOW_TITLE_TIME + 0.3:
		if title_card_static.is_hidden():
			title_card_static.show();
		else:
			title_card_static.hide();
	
	
	if time >= SHOW_TITLE_TIME + 0.3 and not title_shown:
		title_card_static.show();
		for card in title_cards_fast_moving:
			remove_child(card);
			card.hide();
		title_shown = true;
	
	add_fast_timer += delta;
	time += delta;
