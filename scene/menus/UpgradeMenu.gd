extends Node2D

var cost_bd = 500
var cost_dd = 1000

func _ready():
	Global.current_bgm = 2
	$NextStage.text = "To "+Global.enemystats[Global.stage+1].STAGE_NAME

func _process(_delta):
	cost_bd = 500+250*Global.upgrade_count_str
	match Global.playerstats.ATK_CLASS_TYPE:
		"SWORD":
			cost_dd = 1000 + 1000*Global.upgrade_count_spd
		"SPEAR":
			cost_dd = 2000 + 1500*Global.upgrade_count_spd
		"BOW":
			cost_dd = 750 + 750*Global.upgrade_count_spd
	$BaseDamage.disabled = !(Global.xp >= cost_bd)
	$DamageDice.disabled = !(Global.xp >= cost_dd)
	$BaseDamage.text = "Increase Base Damage ("+String(cost_bd)+" XP)"
	$DamageDice.text = "Increase Damage Dice ("+String(cost_dd)+" XP)"
	$DamageDiceDisplay.text = String(Global.playerstats.ATK_DICE_COUNT)+"d"+String(Global.playerstats.ATK_DICE_TYPE)+"+"+String(Global.playerstats.ATK_DMG_MOD)
	$LEVEL.text = "Level "+String(Global.level)
	$XP.text = "XP: "+String(Global.xp)

func _on_Base_Damage_pressed():
	Global.playerstats.ATK_DMG_MOD += 1
	Global.xp -= cost_bd
	Global.upgrade_count_str += 1
	Global.level += 1
func _on_Damage_Dice_pressed():
	Global.playerstats.ATK_DICE_COUNT += 1
	Global.xp -= cost_dd
	Global.upgrade_count_spd += 1
	Global.level += 1

func _on_Next_Stage_pressed():
	Global.playerstats.HP = 30+(6*(Global.level-1))
	Global.stage += 1
	Global.to_scene = "res://scene/maingame/Game.tscn"
	Global.current_bgm = -1
