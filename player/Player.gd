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

onready var animated_sprite := $AnimatedSprite
onready var ray_cast_down := $RayCasDown
onready var animation_player := $AnimationPlayer

func _ready() -> void:
	call_deferred("change_hp", 0)
	call_deferred("change_points", points)
	_play_animation("idle")

func _physics_process(delta: float):
	var move_direction = gravity
	
	if push_point and global_position.distance_to(push_point) >= 5:
		if move_and_collide(global_position.direction_to(push_point) * PUSH_SPEED * delta):
			push_point = null
			return true
		_play_animation("idle")
		return
	elif push_point:
		push_point = null
	
	if Input.is_action_pressed("move_left"):
		move_direction.x = -1
		animated_sprite.flip_h = true
	elif Input.is_action_pressed("move_right"):
		move_direction.x = 1
		animated_sprite.flip_h = false

	if Input.is_action_just_pressed("jump") and jump < 1:
		jump += 1
		jump_velocity = JUMP_STRENGTH
		
	if is_on_floor():
		jump = 0
		
	if jump_velocity < 0.0:
		jump_velocity += gravity.y * delta * 4
		move_direction.y = jump_velocity
	
	if move_direction.y > 0 and ray_cast_down.is_colliding():
		var enemy = ray_cast_down.get_collider()
		hit_enemy(enemy)
	
	_play_move_animation(move_direction)
	move_and_slide(move_direction * speed, Vector2.UP)
	
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

