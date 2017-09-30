extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

const JUMPING = 1;
const FALLING = 2;
const LANDED = 3;
const JUMP_SPEED = -600;
const GRAVITY = 1200;

var speed = 4
var moving_left = 0
var jump_state = LANDED;
var velocity = Vector2(0,0);
var acceleration = Vector2(0,0);
var jump = false;

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	velocity.x = 300;
	set_fixed_process(true);
	pass


func _fixed_process(delta):
	
	var jump = Input.is_action_pressed("player_jump");
	
	if jump and jump_state == LANDED:
		velocity.y = JUMP_SPEED;
		acceleration.y = GRAVITY;
	
	
	# collision
	if is_colliding():
		var n = get_collision_normal();
		if n.x < 0:
			# left
			if abs(n.x) + 0.01 > abs(n.y):
				# steep slope
				print("wall");
				velocity.x = -velocity.x;
				pass
	
	velocity += acceleration * delta;
	move(velocity * delta);
	pass