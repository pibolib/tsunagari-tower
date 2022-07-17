extends Node2D

func _ready():
	Global.current_bgm = 3


func _on_Button_pressed():
	Global.to_scene = "res://scene/menus/ChooseWeapon.tscn"
