extends Node2D

func _on_Menu_pressed():
	Global.to_scene = "res://scene/menus/TitleScreen.tscn"

func _on_Discord_pressed():
	OS.shell_open("https://discord.gg/pPVncFZW8v")

func _on_Website_pressed():
	OS.shell_open("https://www.pibolib.xyz/")
