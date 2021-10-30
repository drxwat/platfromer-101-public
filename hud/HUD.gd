extends Control

var hp_texture := preload("res://assets/hud/Heart.png")

onready var hp_container := $MarginContainer/VBoxContainer/HBoxContainer/HPContainer
onready var points_counter := $MarginContainer/VBoxContainer/HBoxContainer/PointsCounter


func update_hp(hp: int):
	var current_hp := hp_container.get_child_count()
	if hp > current_hp:
		for i in range(hp - current_hp):
			var texture_rect = TextureRect.new()
			texture_rect.texture = hp_texture
			hp_container.add_child(texture_rect)
	elif hp < current_hp:
		for i in range(current_hp - hp):
			hp_container.remove_child(hp_container.get_child(0))


func update_points(points: int):
	points_counter.update_points(points)
