extends Node

var stage = 0
var level = 1
var xp = 0
var totalxp = 0
var upgrade_count_str = 0
var upgrade_count_spd = 0
var ex_score = 0
var to_scene = ""
var current_scene = ""
var current_bgm = -1 #no bgm
var bgm_list = [
	preload("res://asset/bgm/battle1.ogg"),
	preload("res://asset/bgm/battle2.ogg"),
	preload("res://asset/bgm/victory.ogg"),
	preload("res://asset/bgm/title.ogg"),
	preload("res://asset/bgm/victory_credits.ogg"),
	preload("res://asset/bgm/battle3.ogg"),
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
		"SPRITE_SHEET": preload("res://asset/gfx/slime.png") 
	}, #slime
	{
		"NAME": "Goblin",
		"HP": 20,
		"ATK_DICE_FIELD": 1,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 0,
		"POWER_SPEED": 3,
		"SPRITE_SHEET": preload("res://asset/gfx/goblin.png") 
	}, #goblin
	{
		"NAME": "Bat",
		"HP": 30,
		"ATK_DICE_FIELD": 1,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 2,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/bat.png") 
	}, #bat (no sprite implemented yet)
	{
		"NAME": "Blue Slime",
		"HP": 45,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 2,
		"ATK_DICE_TYPE": 2,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/slime_2.png") 
	}, #blue slime
	{
		"NAME": "Snake",
		"HP": 50,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 1,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/snake.png") 
	}, #snake (no sprite)
	{
		"NAME": "Rat",
		"HP": 65,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 1,
		"ATK_DICE_TYPE": 6,
		"ATK_DMG_MOD": 2,
		"POWER_SPEED": 8.5,
		"SPRITE_SHEET": preload("res://asset/gfx/rat.png") 
	}, #rat (no sprite)
	{
		"NAME": "Wall Devil",
		"HP": 90,
		"ATK_DICE_FIELD": 5,
		"ATK_DICE_COUNT": 20,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 2,
		"POWER_SPEED": 1.25,
		"SPRITE_SHEET": preload("res://asset/gfx/walldevil.png") 
	}, #wall devil (no sprite)
	{
		"NAME": "Great Slime",
		"HP": 110,
		"ATK_DICE_FIELD": 3,
		"ATK_DICE_COUNT": 4,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 2,
		"POWER_SPEED": 5,
		"SPRITE_SHEET": preload("res://asset/gfx/slime_3.png") 
	}, #great slime
	{
		"NAME": "Iron Demon",
		"HP": 150,
		"ATK_DICE_FIELD": 2,
		"ATK_DICE_COUNT": 6,
		"ATK_DICE_TYPE": 4,
		"ATK_DMG_MOD": 3,
		"POWER_SPEED": 2.5,
		"SPRITE_SHEET": preload("res://asset/gfx/irondemon.png") 
	}, #iron demon (no sprite)
	{
		"NAME": "Dragon",
		"HP": 160,
		"ATK_DICE_FIELD": 4,
		"ATK_DICE_COUNT": 3,
		"ATK_DICE_TYPE": 8,
		"ATK_DMG_MOD": 3,
		"POWER_SPEED": 4,
		"SPRITE_SHEET": preload("res://asset/gfx/dragon.png") 
	}, #dragon
	{
		"NAME": "Weapon Spirit",
		"HP": 150,
		"ATK_DICE_FIELD": 5,
		"ATK_DICE_COUNT": 0,
		"ATK_DICE_TYPE": 0,
		"ATK_DMG_MOD": 0,
		"POWER_SPEED": 6,
		"SPRITE_SHEET": preload("res://asset/gfx/slime.png")
	}, #weapon spirit (base)
]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
	if !$BGM.playing and current_bgm != -1:
		$BGM.play()

func change():
	var _scenechange = get_tree().change_scene_to(load(to_scene))
