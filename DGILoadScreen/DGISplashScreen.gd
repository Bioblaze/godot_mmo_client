extends Node


onready var FadeIn = $Transition/FadeIn
onready var FadeOut = $Transition/FadeOut

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	FadeIn.play_backwards("Fade")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ChangeSceneTimer_timeout():
	FadeOut.play("Fade")


func _on_FadeIn_animation_finished(_anim_name):
	$ChangeSceneTimer.start()


func _on_FadeOut_animation_finished(_anim_name):
	if get_tree().change_scene_to(preload("res://Menus/MainMenu.tscn")) != OK:
		print("Failed to Load MainMenu.")
