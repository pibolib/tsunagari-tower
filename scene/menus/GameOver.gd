extends Node2D

func _ready():
	Global.current_bgm = 3
	$XP.text = "Total XP: "+String(Global.totalxp) 
	$Stage.text = "Stage: "+String(Global.stage)
	$Ending.text = "Ending: ???"
	match Global.stage:
		999:
			$Stage.text = "Stage: FINAL"
			$Ending.text = "Ending: Neutral"
		1000:
			$Stage.text = "Stage: EX"
			$Ending.text = "Ending: Neutral"
		1001:
			$Stage.text = "Stage: EX"
			$Ending.text = "Ending: Good"
	if Global.stage >= 999:
		$Victory.text = "Congratulations!"
		$CPUParticles2D2.emitting = true
		$TileMap.modulate = Color(0,0,0)
		Global.current_bgm=4
	if Global.stage >= 999:
		$Continue.visible = false
	if Global.stage == 10:
		$Ending2.visible = true

func _on_Menu_pressed():
	Global.to_scene = "res://scene/menus/TitleScreen.tscn"
	Global.stage = 0
	Global.level = 1
	Global.xp = 0
	Global.totalxp = 0
	Global.upgrade_count_spd = 0
	Global.upgrade_count_str = 0
	Global.continue_count = 0
	Global.playerstats = {
	"HP": 30,
	"ATK_CLASS_TYPE": "BOW",
	"ATK_DICE_COUNT": 3,
	"ATK_DICE_TYPE": 2,
	"ATK_DMG_MOD": 1,
	}

func _on_Continue_pressed():
	$Continue.disabled = true
	Global.to_scene = "res://scene/maingame/Game.tscn"
	Global.continue_count += 1
	Global.current_bgm = -1


func _on_Discord_pressed():
	OS.shell_open("https://discord.gg/pPVncFZW8v")


func _on_Website_pressed():
	OS.shell_open("https://www.pibolib.xyz")
