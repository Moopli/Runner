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

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	velocity.x = RUN_SPEED;
	
	raycast = find_node("RayCast2D");
	sprite = find_node("Sprite");
	anim = find_node("AnimationPlayer");
	set_fixed_process(true);
	pass

func switch_to_anim(name):
	if anim.get_current_animation() != name:
		anim.play(name);

func _fixed_process(delta):
	
	var jump = Input.is_action_pressed("player_jump");
	if not alive: jump = false;
	
	var n = null;
	
	# collision
	if is_colliding():
		var col = get_collider();
		n = get_collision_normal();
		if col.get_name() == "spikeTiles":
			# die
			# disable layer 2
			set_collision_mask_bit(1, false);
			switch_to_anim("death");
			alive = false;
		elif abs(n.x) - 0.1 > abs(n.y):
			# steep slope
			velocity.x = -velocity.x;
			time_since_grounded = 0;
		else:
			# shallow slope 
			jump_state = LANDED;
			velocity = n.slide(velocity).normalized() * RUN_SPEED;
			# acceleration = n.slide(acceleration);
		if n.y > 0.01:
			jump_state = FALLING;
			velocity = n.slide(velocity) + 0.2 * delta * n;
			velocity.y = -1;
	elif raycast.is_colliding():
		jump_state = LANDED;
		n = raycast.get_collision_normal();
		if not jump:
			var p = raycast.get_collision_point();
			move(p-get_global_pos());
	elif not jump:
		jump_state = FALLING;

	if jump and (jump_state == LANDED or time_since_grounded < 0.12):
		velocity.y = JUMP_SPEED;
		velocity.x *= 1.2;
		jump_state = JUMPING;
		time_since_grounded = 1000;
	if (not jump or velocity.y > 0) and jump_state == JUMPING:
		jump_state = FALLING;
		if velocity.y < 0: 
			velocity.y = 0; 
	
	# print(JUMP_STATES[jump_state]);

	if jump_state == LANDED:
		acceleration.y = 0;
		time_since_grounded = 0;
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