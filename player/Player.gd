extends KinematicBody2D


signal hp_changed
signal points_changed

const JUMP_STRENGTH := -2.5
const INVULNERABLE_TIME := 2.0
const PUSH_DISTANCE := 35.0
const PUSH_SPEED := 250.0

var speed := 100
var gravity := Vector2.DOWN * 1.5
var jump_velocity := 0.0
var hp := 5
var invulnerable_time := 0.0
var push_point = null
var jump := 0
var points := 0

# new code
# accelerate is static and only gravity (but maybe add friction in future)
var acc_gravity := Vector2.DOWN * 9.8	#typical
var force_jump := 320.0;
var _speed_in_air := Vector2.ZERO
var _speed_on_surface := 100.0;		# speed controlled by the player
var _speed_left := Vector2.ZERO
var _speed_right := Vector2.ZERO
var _speed_total := Vector2.ZERO	# sum all vectors

onready var animated_sprite := $AnimatedSprite
onready var ray_cast_down := $RayCasDown
onready var animation_player := $AnimationPlayer

func _ready() -> void:
	call_deferred("change_hp", 0)
	call_deferred("change_points", points)
	_play_animation("idle")

func _physics_process(delta: float):	
	if push_point and global_position.distance_to(push_point) >= 5:
		if move_and_collide(global_position.direction_to(push_point) * PUSH_SPEED * delta):
			push_point = null
			return true
		_play_animation("idle")
		return
	elif push_point:
		push_point = null
#calculate speeds
	if Input.is_action_pressed("move_left"):
		_speed_left = Vector2.LEFT * _speed_on_surface;
		animated_sprite.flip_h = true
	if Input.is_action_pressed("move_right"):
		_speed_right = Vector2.RIGHT * _speed_on_surface;
		animated_sprite.flip_h = false
		
	if Input.is_action_just_released("move_left"):
		_speed_left = Vector2.ZERO
	if Input.is_action_just_released("move_right"):
		_speed_right = Vector2.ZERO
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			_speed_in_air = Vector2.UP * force_jump
		else:
			_speed_in_air = Vector2.ZERO
	elif is_on_ceiling():
		_speed_in_air.y = max(_speed_in_air.y, 0)
	
	_speed_in_air += acc_gravity
	_speed_total = _speed_left + _speed_right + _speed_in_air
	
	_play_move_animation(_speed_total)
	move_and_slide(_speed_total, Vector2.UP)
	
	if _speed_total.y > 0 and ray_cast_down.is_colliding():
		var enemy = ray_cast_down.get_collider()
		hit_enemy(enemy)
	
	
	if invulnerable_time >= 0:
		invulnerable_time -= delta
		animation_player.play("invulnerable")
	else:
		animation_player.seek(0, true)
		animation_player.stop()


func _play_move_animation(move_direction: Vector2):
	if move_direction == gravity and is_on_floor():
		_play_animation("idle")
	elif move_direction.x != 0 and is_on_floor():
		_play_animation("run")
	elif move_direction.y <= 0:
		_play_animation("jump")
	elif move_direction.y > 0:
		_play_animation("fall")


func _play_animation(animation: String):
	if animated_sprite.animation !=  animation:
		animated_sprite.play(animation)
	

func hit_enemy(enemy: Node2D):
	if enemy.has_method("die"):
		enemy.die()
	jump_velocity += JUMP_STRENGTH / 1.5


func take_damage(damage: int, attack_direction: Vector2):
	if invulnerable_time >= 0:
		return
	change_hp(-damage)
	invulnerable_time = INVULNERABLE_TIME
	push_point = global_position + ((attack_direction + Vector2(0, -1)) * PUSH_DISTANCE)


func change_hp(diff: int):
	hp += diff
	emit_signal("hp_changed", hp)
	

func change_points(diff: int):
	points += diff
	emit_signal("points_changed", points)


func pick_up_item(pickable: Pickable):
	if pickable.is_picked_up:
		return
	if pickable is Coin:
		change_points(1)
	pickable.pick_up()

