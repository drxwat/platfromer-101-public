extends Node

signal on_pause_state_change

var current_scene_ref: WeakRef
var level := 0
#var title_screen: Control

var show_pause_sceen = false
var is_game_started = false

var levels = [
	 "res://levels/level_1/Level1.tscn",
	"res://levels/level_2/Level2.tscn"
]

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	var root = get_tree().get_root()
	var scene = root.get_child(root.get_child_count() - 1)
	current_scene_ref = weakref(scene)

func _process(delta):
	if is_game_started and Input.is_action_just_pressed("ui_cancel"):
		toggle_pause()
		

func go_to_next_level():
	level += 1
	goto_scene(levels[level])

func goto_scene(scene_path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	var scene = load(scene_path)
	call_deferred("_deferred_goto_scene", scene)

func toggle_pause():
	show_pause_sceen = !show_pause_sceen
#	if title_screen:
#		if show_pause_sceen:
#			title_screen.show()
#		else:
#			title_screen.hide()
	get_tree().paused = show_pause_sceen
	emit_signal("on_pause_state_change", show_pause_sceen)

func start_new_game():
	is_game_started = true
	level = 0
	goto_scene(levels[level])


func exit_game():
	get_tree().quit()

func _deferred_goto_scene(scene: PackedScene):
	# It is now safe to remove the current scene
	var current_scene = current_scene_ref.get_ref()
	if current_scene:
		current_scene.free()

	# Instance the new scene.
	var new_scene = scene.instance()
	current_scene_ref = weakref(new_scene)

	# Add it to the active scene, as child of root.
	get_tree().get_root().add_child(new_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(new_scene)
