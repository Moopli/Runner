extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const JUMPING = 1;
const FALLING = 2;
const LANDED = 3;
const JUMP_SPEED = -600;
const GRAVITY = 1200;
const RUN_SPEED = 300;

var speed = 4
var moving_left = 0
var jump_state = FALLING;
var velocity = Vector2(0,0);
var acceleration = Vector2(0,0);
var jump = false;
var alive = true;
var running = false;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	velocity.x = RUN_SPEED;
	set_fixed_process(true);
	pass


func _fixed_process(delta):
	
	var jump = Input.is_action_pressed("player_jump");
	if not alive: jump = false;
	
	var anim = find_node("AnimationPlayer");
	# collision
	if is_colliding():
		var col = get_collider();
		if col.get_name() == "spikeTiles":
			# die
			anim.play("death");
			alive = false;
		var n = get_collision_normal();
		if abs(n.x) - 0.1 > abs(n.y):
			# steep slope
			velocity.x = -velocity.x;
		else:
			# shallow slope 
			jump_state = LANDED;
			velocity = n.slide(velocity);
			velocity = velocity.normalized() * RUN_SPEED;
			# acceleration = n.slide(acceleration);
	else:
		# print("nocollide");
		running = false;
		if not jump:
			jump_state = FALLING;

	if jump and jump_state == LANDED:
		velocity.y = JUMP_SPEED;
		jump_state = JUMPING;
	if (not jump or velocity.y > 0) and jump_state == JUMPING:
		jump_state = FALLING;
		if velocity.y < 0: 
			velocity.y = 0; 
	
	if jump_state == LANDED:
		acceleration.y = 0;
		if alive and not running: 
			# anim.play("run");
			running = true;
	else:
		acceleration.y = GRAVITY;
		if alive:
			if jump_state == JUMPING:
				pass; #anim.play("jump");
			if jump_state == FALLING:
				pass; #anim.play("fall");

	if alive:
		if velocity.x < 0:
			find_node("Sprite").set_scale(Vector2(-1,1));
		else:
			find_node("Sprite").set_scale(Vector2(1,1));

	velocity.y += acceleration.y * delta;
	if not alive: velocity.x = 0;
	move(velocity * delta);
	pass