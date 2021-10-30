extends KinematicBody2D

export var damage := 1
export var speed := 30

onready var animated_sprite := $AnimatedSprite
onready var collision_shape := $CollisionShape2D
onready var patrol_path : Curve2D

var path_length: float
var current_position: float
var is_patroling_back := false


var gravity := Vector2.DOWN * 1.5
var is_dead := false

func _ready() -> void:
	if has_node("Node/Path2D"):
		var path = get_node("Node/Path2D")
		patrol_path = path.curve
		path_length = patrol_path.get_baked_length()
	_play_animation("idle")


func _process(delta):
	if is_dead:
		return
	var move_direction = gravity
	move_and_slide(move_direction * speed, Vector2.UP)
	_patrol(delta)
	_play_animation("move")


func _patrol(delta: float):
	if not patrol_path:
		return
	
	var offset := 0.0
	if not is_patroling_back:
		offset = current_position + (speed * delta)
		if current_position >= path_length:
			is_patroling_back = true
	else:
		offset = current_position - (speed * delta)
		if current_position <= 0:
			is_patroling_back = false
		
	current_position = offset
	var point = patrol_path.interpolate_baked(offset)
	global_position.x = point.x


func _play_animation(animation: String):
	if animated_sprite.animation !=  animation:
		animated_sprite.play(animation)


func die():
	_play_animation("death")
	collision_shape.set_deferred("disabled", true)
	$AttackArea/CollisionPolygon2D.set_deferred("disabled", true)
	is_dead = true


func attack(player: KinematicBody2D):
	player.take_damage(damage, global_position.direction_to(player.global_position))
