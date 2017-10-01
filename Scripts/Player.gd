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

var speed = 4
var moving_left = 0
var jump_state = FALLING;
var velocity = Vector2(0,0);
var acceleration = Vector2(0,0);
var jump = false;
var alive = true;
var time_since_grounded = 1000;

var anim;
var raycast;
var sprite;

var prev_jump_button_state = false;
var jump_button_state = false;

var is_pushed_down = false;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	velocity.x = RUN_SPEED;
	
	raycast = find_node("RayCast2D");
	sprite = find_node("Sprite");
	anim = find_node("AnimationPlayer");
	set_fixed_process(true);
	pass

func switch_to_anim(name, redo=false):
	if anim.get_current_animation() != name or (redo and anim.get_current_animation_pos() > anim.get_current_animation_length() * 0.9):
		anim.play(name);

func kill_player():
	set_collision_mask_bit(1, false);
	switch_to_anim("death");
	alive = false;

func _fixed_process(delta):
	
	prev_jump_button_state = jump_button_state;
	jump_button_state = Input.is_action_pressed("player_jump");
	var jump = jump_button_state;# and not prev_jump_button_state;
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
		if col.get_name() == "spikeTiles":
			# die
			# disable layer 2
			kill_player();
		elif abs(n.x) - 0.1 > abs(n.y):
			# steep slope
			velocity.x = -velocity.x;
			time_since_grounded = 0;
			is_pushed_down = false;
		else:
			# shallow slope 
			jump_state = LANDED;
			velocity = n.slide(velocity).normalized() * RUN_SPEED;
			# acceleration = n.slide(acceleration);
		if n.y > 0.01:
			jump_state = FALLING;
			velocity = n.slide(velocity) + 1.2 * delta * n;
			is_pushed_down = true;
			# velocity.y = 1;
		else:
			is_pushed_down = false;
	elif raycast.is_colliding():
		is_pushed_down = false;
		jump_state = LANDED;
		n = raycast.get_collision_normal();
		if not jump:
			var p = raycast.get_collision_point();
			move(p-get_global_pos());
	elif not jump_button_state:
		jump_state = FALLING;
		is_pushed_down = false;

	if jump and (jump_state == LANDED or time_since_grounded < 0.25):
		velocity.y = JUMP_SPEED;
		velocity.x *= 1.2;
		jump_state = JUMPING;
		time_since_grounded = 1000;
		switch_to_anim("jump", true);
	if (not jump_button_state or velocity.y > 0) and jump_state == JUMPING:
		jump_state = FALLING;
	if jump_state == FALLING:
		if velocity.y < 0: 
			velocity.y *= pow(0.06, delta);
	
	# print(JUMP_STATES[jump_state]);

	if jump_state == LANDED:
		acceleration.y = 0;
		time_since_grounded = 0;
		velocity = velocity.normalized() * RUN_SPEED;
		if alive:
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
			if jump_state == FALLING:
				switch_to_anim("fall");

	if alive:
		if velocity.x < 0:
			sprite.set_scale(Vector2(-1,1));
		else:
			sprite.set_scale(Vector2(1,1));

	velocity.y += acceleration.y * delta;
	if not alive: velocity.x = 0;
	move(velocity * delta);
	pass