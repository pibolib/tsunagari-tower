extends Node

var stage = 0
var level = 1
var xp = 0
var totalxp = 0
var upgrade_count_str = 0
var upgrade_count_spd = 0
var to_scene = ""
var current_scene = ""
var current_bgm = -1 #no bgm
var continue_count = 0
var bgm_list = [
	preload("res://asset/bgm/battle1.ogg"),
	preload("res://asset/bgm/battle2.ogg"),
	preload("res://asset/bgm/victory.ogg"),
	preload("res://asset/bgm/title.ogg"),
	preload("res://asset/bgm/victory_credits.ogg"),
	preload("res://asset/bgm/battle3.ogg"),
	preload("res://asset/bgm/battle1-2.ogg"),
	preload("res://asset/bgm/battle2-2.ogg"),
	preload("res://asset/bgm/battle3-2.ogg"),
	preload("res://asset/bgm/battle4.ogg")
]
#increasing strength has no negative effects, but increasing speed will cause greater penalties
#for overwriting a piece in the playfield.

var playerstats = {
	"HP": 30,
	"ATK_CLASS_TYPE": "BOW",
	"ATK_DICE_COUNT": 3,
	"ATK_DICE_TYPE": 2,
	"ATK_DMG_MOD": 1,
}

var weapon_base_sword = {
	"ATK_CLASS_TYPE": "SWORD",
	"ATK_DICE_COUNT": 2,
	"ATK_DICE_TYPE": 4,
	"ATK_DMG_MOD": 1,
}

var weapon_base_bow = {
	"ATK_CLASS_TYPE": "BOW",
	"ATK_DICE_COUNT": 3,
	"ATK_DICE_TYPE": 2,
	"ATK_DMG_MOD": 1,
}

var weapon_base_spear = {
	"ATK_CLASS_TYPE": "SPEAR",
	"ATK_DICE_COUNT": 1,
	"ATK_DICE_TYPE": 8,
	"ATK_DMG_MOD": 0,
}

var enemystats = [
	{
		"NAME": "Slime",
		"HP": 10,
		"ATK_DICE_FIELD": 0,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 2,
		"ATK_DMG_MOD": 0,
		"POWER_SPEED": 2,
		"SPRITE_SHEET": preload("res://asset/gfx/slime.png"),
		"STAGE_NAME": "Stage 1"
	}, #slime
	{
		"NAME": "Goblin",
		"HP": 20,
		"ATK_DICE_FIELD": 1,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 0,
		"POWER_SPEED": 3,
		"SPRITE_SHEET": preload("res://asset/gfx/goblin.png"),
		"STAGE_NAME": "Stage 2"
	}, #goblin
	{
		"NAME": "Bat",
		"HP": 30,
		"ATK_DICE_FIELD": 1,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 2,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/bat.png"),
		"STAGE_NAME": "Stage 3"
	}, #bat
	{
		"NAME": "Blue Slime",
		"HP": 45,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 2,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/slime_2.png"),
		"STAGE_NAME": "Stage 4"
	}, #blue slime
	{
		"NAME": "Snake",
		"HP": 50,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/snake.png"),
		"STAGE_NAME": "Stage 5" 
	}, #snake (no sprite)
	{
		"NAME": "Rat",
		"HP": 65,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 6,
		"ATK_DMG_MOD": 2,
		"POWER_SPEED": 8.5,
		"SPRITE_SHEET": preload("res://asset/gfx/rat.png"),
		"STAGE_NAME": "Stage 6"
	}, #rat
	{
		"NAME": "Wall Devil",
		"HP": 90,
		"ATK_DICE_FIELD": 5,
		"ATK_DICE_COUNT": 20,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 2,
		"POWER_SPEED": 1.25,
		"SPRITE_SHEET": preload("res://asset/gfx/walldevil.png"),
		"STAGE_NAME": "Stage 7"
	}, #wall devil
	{
		"NAME": "Great Slime",
		"HP": 110,
		"ATK_DICE_FIELD": 3,
		"ATK_DICE_COUNT": 4,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 2,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/slime_3.png"),
		"STAGE_NAME": "Stage 8"
	}, #great slime
	{
		"NAME": "Iron Demon",
		"HP": 150,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 6,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 3,
		"POWER_SPEED": 2.5,
		"SPRITE_SHEET": preload("res://asset/gfx/irondemon.png"),
		"STAGE_NAME": "Stage 9"
	}, #iron demon
	{
		"NAME": "Dragon",
		"HP": 160,
		"ATK_DICE_FIELD": 4,
		"ATK_DICE_COUNT": 3,
		"ATK_DICE_TYPE": 8,
		"ATK_DMG_MOD": 3,
		"POWER_SPEED": 4,
		"SPRITE_SHEET": preload("res://asset/gfx/dragon.png"),
		"STAGE_NAME": "Final Stage"
	}, #dragon
	{
		"NAME": "Weapon Spirit",
		"HP": 100,
		"ATK_DICE_FIELD": 0,
		"ATK_DICE_COUNT": 0,
		"ATK_DICE_TYPE": 0,
		"ATK_DMG_MOD": 999,
		"POWER_SPEED": 0,
		"SPRITE_SHEET": preload("res://asset/gfx/slime.png"),
		"STAGE_NAME": "Extra Stage"
	}, #weapon spirit (base)
	{
		"NAME": "Ether Slime",
		"HP": 20,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 2,
		"ATK_DMG_MOD": 0,
		"POWER_SPEED": 4,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/slime4.png"),
		"STAGE_NAME": "Stage EX-1",
		"SPECIAL": "shuffle",
	}, #
	{
		"NAME": "Blue Imp",
		"HP": 30,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 6,
		"ATK_DMG_MOD": 0,
		"POWER_SPEED": 4,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/goblin2.png"),
		"STAGE_NAME": "Stage EX-2",
		"SPECIAL": "destroyblue"
	}, #
	{
		"NAME": "Fire Bat",
		"HP": 45,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 2,
		"ATK_DMG_MOD": 3,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/bat2.png"),
		"STAGE_NAME": "Stage EX-3",
		"SPECIAL": "disableconnect"
	}, #
	{
		"NAME": "Crystal Slime",
		"HP": 60,
		"ATK_DICE_FIELD": 3,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/slime5.png"),
		"STAGE_NAME": "Stage EX-4",
		"SPECIAL": "randomizecenter"
	}, #
	{
		"NAME": "Cobra",
		"HP": 75,
		"ATK_DICE_FIELD": 3,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 6,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/snake2.png"),
		"STAGE_NAME": "Stage EX-5",
		"SPECIAL": "poison"
	}, #
	{
		"NAME": "Plague Rat",
		"HP": 90,
		"ATK_DICE_FIELD": 3,
		"ATK_DICE_COUNT": 3,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 2,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/rat2.png"),
		"STAGE_NAME": "Stage EX-6",
		"SPECIAL": "disablepoison"
	}, #
	{
		"NAME": "Tower Curse",
		"HP": 250,
		"ATK_DICE_FIELD": 5,
		"ATK_DICE_COUNT": 16,
		"ATK_DICE_TYPE": 12,
		"ATK_DMG_MOD": 20,
		"POWER_SPEED": 0.5,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/walldevil2.png"),
		"STAGE_NAME": "Stage EX-7",
		"SPECIAL": "reducepower"
	}, #
	{
		"NAME": "Slime God",
		"HP": 120,
		"ATK_DICE_FIELD": 4,
		"ATK_DICE_COUNT": 3,
		"ATK_DICE_TYPE": 6,
		"ATK_DMG_MOD": 4,
		"POWER_SPEED": 6,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/slime6.png"),
		"STAGE_NAME": "Stage EX-8",
		"SPECIAL": "eraseboard"
	}, #
	{
		"NAME": "Chronomancer",
		"HP": 135,
		"ATK_DICE_FIELD": 4,
		"ATK_DICE_COUNT": 3,
		"ATK_DICE_TYPE": 10,
		"ATK_DMG_MOD": 6,
		"POWER_SPEED": 1,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/irondemon2.png"),
		"STAGE_NAME": "Stage EX-9",
		"SPECIAL": "chronomancy"
	}, #
	{
		"NAME": "Dragon's Revenge",
		"HP": 250,
		"ATK_DICE_FIELD": 4,
		"ATK_DICE_COUNT": 4,
		"ATK_DICE_TYPE": 10,
		"ATK_DMG_MOD": 10,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/excourse/dragon2.png"),
		"STAGE_NAME": "Stage EX-10",
	}, #
	{
		"NAME": "Lilium",
		"HP": 300,
		"ATK_DICE_FIELD": 4,
		"ATK_DICE_COUNT": 3,
		"ATK_DICE_TYPE": 10,
		"ATK_DMG_MOD": 6,
		"POWER_SPEED": 6,
		"SPRITE_SHEET": preload("res://asset/gfx/slime.png"),
		"STAGE_NAME": "Stage EX-EX",
	}, #
]


func _input(event):
	if event.is_action_pressed("action_debug_menu"):
		$CanvasLayer/Debug.visible = !$CanvasLayer/Debug.visible

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if current_scene != to_scene:
		$AnimationPlayer.play("Transition")
		current_scene = to_scene
	if current_bgm == -1:
		$BGM.volume_db = lerp($BGM.volume_db, -75, delta)
		if $BGM.volume_db <= -74:
			$BGM.playing = false
	elif $BGM.stream != bgm_list[current_bgm]:
		$BGM.volume_db = 0
		$BGM.stream = bgm_list[current_bgm]
		#print(current_bgm)
	if !$BGM.playing and current_bgm != -1:
		$BGM.play()

func change():
	var _scenechange = get_tree().change_scene_to(load(to_scene))
	#print(Global.stage)


func _on_SetStage_pressed():
	stage = int($CanvasLayer/Debug/SpinBox.value)


func _on_SetXP_pressed():
	xp = $CanvasLayer/Debug/SpinBox2.value
