extends Node2D


var choice = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _process(delta):
	$Begin.disabled = (choice==-1)
	match choice:
		0:
			$ChoiceLabel.text = "Your choice: Sword"
		1:
			$ChoiceLabel.text = "Your choice: Spear"
		2:
			$ChoiceLabel.text = "Your choice: Bow"


func _on_Sword_pressed():
	choice = 0
	
func _on_Spear_pressed():
	choice = 1
	
func _on_Bow_pressed():
	choice = 2


func _on_Begin_pressed():
	Global.current_bgm = -1
	match choice:
		0:
			Global.playerstats.ATK_CLASS_TYPE = "SWORD"
			Global.playerstats.ATK_DICE_COUNT = 2
			Global.playerstats.ATK_DICE_TYPE = 4
			Global.playerstats.ATK_DMG_MOD = 1
		1:
			Global.playerstats.ATK_CLASS_TYPE = "SPEAR"
			Global.playerstats.ATK_DICE_COUNT = 1
			Global.playerstats.ATK_DICE_TYPE = 8
			Global.playerstats.ATK_DMG_MOD = 0
		2:
			Global.playerstats.ATK_CLASS_TYPE = "BOW"
			Global.playerstats.ATK_DICE_COUNT = 3
			Global.playerstats.ATK_DICE_TYPE = 2
			Global.playerstats.ATK_DMG_MOD = 1
	Global.to_scene = "res://scene/maingame/Game.tscn"
