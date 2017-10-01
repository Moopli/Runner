extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var area = get_node("Area2D");
	area.connect("body_enter", self, "enable_checkpoint");

func enable_checkpoint(body):
	var parent = get_parent();
	parent.set_checkpoint(self);
	var disabled_sprite = get_node("DisabledSprite");
	var enabled_sprite = get_node("EnabledSprite");
	disabled_sprite.hide();
	enabled_sprite.show();

func disable_checkpoint():
	var disabled_sprite = get_node("DisabledSprite");
	var enabled_sprite = get_node("EnabledSprite");
	disabled_sprite.show();
	enabled_sprite.hide();

