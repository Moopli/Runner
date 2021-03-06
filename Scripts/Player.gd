extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const JUMP_STATES = ["Jumping", "Falling", "Landed"];
const JUMPING = 0;
const FALLING = 1;
const LANDED = 2;

const JUMP_SPEED = -900;
const GRAVITY = 1500;
const RUN_SPEED = 300;
const SPEED_CAP = 100000;

var speed = 4;
var moving_left = 0;
var jump_state = FALLING;
var velocity = Vector2(0,0);
var acceleration = Vector2(0,0);
var jump = false;
var alive = true;
var time_since_grounded = 1000;

var anim;
var raycast;
var sprite;

var jump_released = false; # flag: set to false after jumping, set to true when jump button is released
# used to prevent spacebar-holding

var is_pushed_down = false;
var ceiling_downjump = false;

var smash_anim = false;
var intro_scene = false;

const FAST_LANDING_SPEED = 2500;

const NOT_RECOVERING = 0;
const RECOVERING = 1;

var fast_landing_anim_state = NOT_RECOVERING;
var fast_landing_timer = 0;

var prev_velocity = null;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	velocity.x = RUN_SPEED;
	
	raycast = get_node("RayCast2D");
	sprite = get_node("Sprite");
	anim = get_node("AnimationPlayer");
	set_fixed_process(true);

func begin_intro_scene():
	intro_scene = true;

func end_intro_scene():
	intro_scene = false;
	get_node("Camera2D").make_current();
	velocity = Vector2(0.1, 9000);

func switch_to_anim(name, redo=false):
	if anim.get_current_animation() != name or (redo and anim.get_current_animation_pos() > anim.get_current_animation_length() * 0.9):
		anim.play(name);

func kill_player():
	# disable spike collision
	set_collision_mask_bit(1, false);
	switch_to_anim("death");
	alive = false;

func _fixed_process(delta):
	if intro_scene:
		switch_to_anim("fall");
#		if Input.is_action_pressed("player_jump"):
#			get_parent().end_intro();
		return;

	var jump = Input.is_action_pressed("player_jump");
	if not jump: jump_released = true; # for ensuring you can't just hold down spacebar
	
	if not alive:
		var parent = get_parent();
		if parent == null:
			print("Parent of Player is null");
		else:
			parent.player_died();
		jump = false;
	
	var n = null;
	
	# collision
	if is_colliding():
		var col = get_collider();
		n = get_collision_normal();
		if n.y < -0.01 and is_pushed_down:
			velocity.x = -velocity.x;
			is_pushed_down = false;
			ceiling_downjump = false;
		if col.get_name() == "spikeTiles":
			kill_player();
		elif abs(n.x) - 0.1 > abs(n.y):
			# steep slope
			velocity.x = -velocity.x;
			time_since_grounded = 0;
			is_pushed_down = false;
			ceiling_downjump = false;
		else:
			# shallow slope 
			jump_state = LANDED;
			# we should do a quick landing animation - smash then reverse smash
#			if prev_velocity.y > FAST_LANDING_SPEED:
#				fast_landing_anim_state = RECOVERING;
#				fast_landing_timer = 0;
			velocity = n.slide(velocity).normalized() * RUN_SPEED;
#			if fast_landing_anim_state == RECOVERING:
#				velocity = velocity.normalized() * 0.01;
			# acceleration = n.slide(acceleration);
		if n.y > 0.01:
			jump_state = FALLING;
			velocity = n.slide(velocity) + 1.2 * delta * n;
			# velocity.y = 1;
			is_pushed_down = true;
			ceiling_downjump = true;
			time_since_grounded = 0;
		else:
			is_pushed_down = false;
			ceiling_downjump = false;
	elif raycast.is_colliding():
		is_pushed_down = false;
		ceiling_downjump = false;
		jump_state = LANDED;
		n = raycast.get_collision_normal();
		if not jump:
			var p = raycast.get_collision_point();
			move(p-get_global_pos());
	elif not jump:
		jump_state = FALLING;
		is_pushed_down = false;
	elif not jump_released and jump_state == LANDED:
		jump_state = FALLING;
		is_pushed_down = false;

	if jump and (jump_state == LANDED or time_since_grounded < 0.18) and jump_released:
		jump_released = false;
		time_since_grounded = 1000;
		fast_landing_timer = 1000;
#		if fast_landing_anim_state == RECOVERING:
#			fast_landing_anim_state = NOT_RECOVERING;
#			velocity = velocity.normalized() * RUN_SPEED;
		if ceiling_downjump:
			velocity = Vector2(sign(velocity.x) * 0.1, -JUMP_SPEED * 2);
			switch_to_anim("smash");
			smash_anim = true;
		else:
			velocity.y = JUMP_SPEED;
			velocity.x *= 1.2;
			jump_state = JUMPING;
			switch_to_anim("jump", true);
		ceiling_downjump = false;
	if (not jump or velocity.y > 0) and jump_state == JUMPING:
		jump_state = FALLING;
	if jump_state == FALLING:
		if velocity.y < 0: 
			velocity.y *= pow(0.06, delta);
#	
#	if fast_landing_anim_state == RECOVERING:
#		if fast_landing_timer > 0.12:
#			fast_landing_timer = 1000;
#			fast_landing_anim_state = NOT_RECOVERING;
#			velocity = velocity.normalized() * RUN_SPEED;
#		fast_landing_timer += delta;
	
	# print(JUMP_STATES[jump_state]);

	if jump_state == LANDED:
		smash_anim = false;
		acceleration.y = 0;
		time_since_grounded = 0;
		velocity = velocity.normalized() * RUN_SPEED;
		if alive:
#			if fast_landing_anim_state == RECOVERING:
#				print("recover");
#				switch_to_anim("recover");
			if n == null or abs(n.x) < 0.01:
				switch_to_anim("run");
			elif (n.x < 0) == (velocity.x < 0): # down slope
				switch_to_anim("descend");
			else:
				switch_to_anim("ascend");
	else:
		acceleration.y = GRAVITY;
		time_since_grounded += delta;
		if alive:
			if jump_state == JUMPING:
				switch_to_anim("jump");
				smash_anim = false;
			if jump_state == FALLING:
				if smash_anim:
					switch_to_anim("smash");
				else:
					switch_to_anim("fall");


	if alive:
		if velocity.x < 0:
			sprite.set_scale(Vector2(-1,1));
		else:
			sprite.set_scale(Vector2(1,1));
	else:
		switch_to_anim("death");
		velocity.x = 0;

	prev_velocity = velocity;
	velocity.y += acceleration.y * delta;
	if not alive: velocity.x = 0;
	velocity = velocity.clamped(SPEED_CAP);
	move(velocity * delta);
	pass