extends Node2D

func _ready():
	$XP.text = "Total XP: "+String(Global.totalxp) 
	if Global.stage == 999:
		$Victory.text = "Congratulations!"
		$CPUParticles2D2.emitting = true
		$TileMap.modulate = Color(0,0,0)
		Global.current_bgm=4

func _on_Menu_pressed():
	Global.to_scene = "res://scene/menus/TitleScreen.tscn"
	Global.stage = 0
	Global.level = 1
	Global.xp = 0
	Global.totalxp = 0
	Global.upgrade_count_spd = 0
	Global.upgrade_count_str = 0
	Global.playerstats = {
	"HP": 30,
	"ATK_CLASS_TYPE": "BOW",
	"ATK_DICE_COUNT": 3,
	"ATK_DICE_TYPE": 2,
	"ATK_DMG_MOD": 1,
	}


func _on_Discord_pressed():
	OS.shell_open("https://discord.gg/fvfHqEQEF7")

func _on_Website_pressed():
	OS.shell_open("https://www.pibolib.xyz/")

func _on_Twitter_pressed():
	OS.shell_open("https://twitter.com/pibolib")
