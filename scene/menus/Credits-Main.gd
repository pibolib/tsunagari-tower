extends Node2D

func _on_Menu_pressed():
	Global.to_scene = "res://scene/menus/TitleScreen.tscn"

func _on_Discord_pressed():
	OS.shell_open("https://discord.gg/fvfHqEQEF7")

func _on_Website_pressed():
	OS.shell_open("https://www.pibolib.xyz/")

func _on_Twitter_pressed():
	OS.shell_open("https://twitter.com/pibolib")
