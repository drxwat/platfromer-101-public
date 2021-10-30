extends Control

onready var animation_player := $AnimationPlayer

func _ready():
	Global.connect("on_pause_state_change", self, "toggle_visibility")
	var animation = animation_player.get_animation("fade")
	animation_player.play("fade")
	animation_player.seek(animation.length)
	
	
func toggle_visibility(is_visible: bool):
	if is_visible:
		animation_player.play_backwards("fade")
	else:
		animation_player.play("fade", -1, 3.0)
