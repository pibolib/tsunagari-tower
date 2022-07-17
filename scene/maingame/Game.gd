extends Node2D

var placeanim = preload("res://scene/fx/PlaceAnim.tscn")
var clearanim = preload("res://scene/fx/ClearAnim.tscn")
var diceroll = preload("res://scene/fx/DiceRoll.tscn")

onready var field = $Playfield/Field
var nextpiece = [0,0]
var nextpieces = []
var nextpos = Vector2(0,3)
var nextrotate = 0
var mousepos = Vector2(0,0)
var control_timer = 0
var attackpower = 0
var hp = 30
var mhp = 30
var playerattack = [2,6,0] 
var weapontype = "SWORD"
var ehp = 20
var emhp = 20
var enemyattack = [2,2,2,0]
var enemyattacktimer = 0 #out of 100
var enemyspeed = 6
var attackglobaldelay = 0
var playerdamage = 0
var enemydamage = 0
var playeranimtime = 0.5
var enemyanimtime = 0.5
var playeranimstate = 0
var specialanimtimer = 0
var enemyanimstate = 0
var jingleplayed = false
#enemystates: 0. idle a, 2. idle b, 3. attack, 4. hurt, 5. die

var score = 0
var gameactive = false
var gameover = false
var win = false
var time = 0
var timetilltrans = 0
var statusactive = false
var rewarded = false

func _ready():
	if Global.stage == 9:
		$BG.position.x -= 252
	mhp = Global.playerstats.HP
	hp = mhp
	playerattack = [
		Global.playerstats.ATK_DICE_COUNT,
		Global.playerstats.ATK_DICE_TYPE,
		Global.playerstats.ATK_DMG_MOD
	]
	weapontype = Global.playerstats.ATK_CLASS_TYPE
	emhp = Global.enemystats[Global.stage].HP
	ehp = emhp
	enemyattack = [
		Global.enemystats[Global.stage].ATK_DICE_FIELD,
		Global.enemystats[Global.stage].ATK_DICE_COUNT,
		Global.enemystats[Global.stage].ATK_DICE_TYPE,
		Global.enemystats[Global.stage].ATK_DMG_MOD
	]
	$EnemySprite.texture = Global.enemystats[Global.stage].SPRITE_SHEET
	enemyspeed = Global.enemystats[Global.stage].POWER_SPEED
	update_ui()
	update_shadows()

func _process(delta):
	time += delta
	if time >= 2 and !jingleplayed:
		update_status("Get ready...")
		$GetReady.play()
		jingleplayed = true
	if time >= 5 and hp > 0 and ehp > 0:
		if !statusactive:
			update_status("Game Start!")
			if Global.stage != 9:
				Global.current_bgm = 0
			else:
				Global.current_bgm = 1
			statusactive = true
		gameactive = true
	else:
		if gameactive:
			Global.current_bgm = -1
			gameactive = false
		if hp <= 0:
			if !gameover:
				update_status("You are down!")
			player_anim_set(10)
			gameover = true
			timetilltrans += delta
			if timetilltrans >= 2:
				Global.to_scene = "res://scene/menus/GameOver.tscn"
		if ehp <= 0:
			if timetilltrans < 2:
				timetilltrans += delta
			else:
				if Global.stage == 9 or Global.stage == 999:
					Global.stage = 999
					Global.to_scene = "res://scene/menus/GameOver.tscn"
				else:
					Global.to_scene = "res://scene/menus/UpgradeMenu.tscn"
			if !win:
				update_status("Enemy Defeated!")
				Global.xp += score
				Global.totalxp += score
				win = true
			enemy_anim_set(4)
	update_ui()
	update_next()
	if gameactive:
		if playeranimtime > 0:
			playeranimtime -= delta
		if playeranimtime <= 0:
			player_anim_update()
		if enemyanimtime >= 0:
			enemyanimtime -= delta
		if enemyanimtime <= 0:
			enemy_anim_update()
		nextpos = bound_to_playfield(field.world_to_map(field.get_local_mouse_position()))
		if control_timer > 0:
			control_timer -= delta
		if attackglobaldelay > 0:
			attackglobaldelay -= delta
		else:
			if ehp > 0:
				enemyattacktimer += enemyspeed*delta
		if nextpieces.size() <= 1:
			var next = [randi()%4,randi()%4]
			nextpieces.append(next)
		if attackpower >= 100 and attackglobaldelay <= 0:
			match Global.playerstats.ATK_CLASS_TYPE:
				"SWORD":
					player_anim_set(4)
				"BOW":
					player_anim_set(6)
				"SPEAR":
					player_anim_set(8)
			attackpower -= 100
			var attackdice = roll_individual_dice(playerattack[0],playerattack[1])
			for dice in attackdice.size():
				var roll = diceroll.instance()
				#176, 8
				roll.position = Vector2(8+16*dice,176)
				roll.init(attackdice[dice],playerattack[1],0.25*dice)
				add_child(roll)
				playerdamage += attackdice[dice]
			playerdamage += playerattack[2]
			attackglobaldelay += 1 + 0.25*attackdice.size()
		if enemyattacktimer >= 100 and attackglobaldelay <= 0:
			enemy_anim_set(2)
			enemyattacktimer -= 100
			var attackdice = roll_individual_dice(enemyattack[1],enemyattack[2])
			for dice in attackdice.size():
				var roll = diceroll.instance()
				#176, 8
				roll.position = Vector2(220-16*dice,36)
				roll.init(attackdice[dice],enemyattack[2],0.4*dice)
				roll.enemy = true
				add_child(roll)
				enemydamage += attackdice[dice]
			enemydamage += enemyattack[3]
			attackglobaldelay += 1 + 0.4*attackdice.size()
			for dice in enemyattack[0]:
				var pos = bound_to_playfield(Vector2(randi()%5+1,randi()%7-2))
				var attempts = 3
				while field.get_cell(pos.x,pos.y) == 4 and attempts > 0:
					attempts -= 1
					pos = bound_to_playfield(Vector2(randi()%5+1,randi()%7-2))
				var placeanim1 = placeanim.instance()
				placeanim1.position = field.map_to_world(pos)+Vector2(8,10)
				field.add_child(placeanim1)
				field.set_cell(pos.x,pos.y,4)
		if attackglobaldelay <= 0:
			if playerdamage > 0:
				update_status("Dealt "+String(playerdamage)+" damage!")
				player_anim_set(0)
				$EnemyHurt.pitch_scale = rand_range(0.7,1.1)
				$EnemyHurt.playing = true
				enemy_anim_set(3)
				ehp -= playerdamage
				playerdamage = 0
			if enemydamage > 0:
				$AnimationPlayer2.play("Hurt")
				update_status("Took "+String(enemydamage)+" damage!")
				enemy_anim_set(2)
				$PlayerHurt.pitch_scale = rand_range(0.8,1.0)
				$PlayerHurt.playing = true
				hp -= enemydamage
				if enemydamage > mhp/2:
					player_anim_set(3)
				else:
					player_anim_set(2)
				enemydamage = 0
func _input(event):
	if gameactive:
		if event.is_action_pressed("action_rotate_cw_1shot") or event.is_action_pressed("action_rotate_cw"):
			nextrotate += 1
			nextrotate = nextrotate % 6
		elif event.is_action_pressed("action_rotate_ccw_1shot") or event.is_action_pressed("action_rotate_ccw"):
			nextrotate -= 1
			if nextrotate < 0:
				nextrotate = 5
		elif event.is_action_pressed("action_place_piece") and control_timer <= 0:
			place_piece(nextpos)

func update_shadows():
	$Playfield/FieldShadows.clear()
	for tile in field.get_used_cells():
		$Playfield/FieldShadows.set_cell(tile.x,tile.y,0)

func update_next():
	$Playfield/Next.clear()
	$Playfield/Next.set_cell(nextpos.x,nextpos.y,5)
	var offset = calculate_offset(nextrotate,nextpos)
	$Playfield/Next.set_cell(nextpos.x+offset.x,nextpos.y+offset.y,5)

func update_ui():
	$XP.text = "XP: "+String(score)
	$Playfield/NextDisplay.clear()
	var offset = calculate_offset(nextrotate,Vector2(3,-4))
	$Playfield/NextDisplay.set_cell(3,-5,nextpiece[0])
	$Playfield/NextDisplay.set_cell(3+offset.x,-5+offset.y,nextpiece[1])
	for i in nextpieces.size():
		$Playfield/NextDisplay.set_cell(8,-1+3*i,nextpieces[i][0])
		$Playfield/NextDisplay.set_cell(9,-1+3*i,nextpieces[i][1])
	match Global.playerstats.ATK_CLASS_TYPE:
		"SWORD":
			$PlayerWeaponType.region_rect.position = Vector2(0,48)
		"SPEAR":
			$PlayerWeaponType.region_rect.position = Vector2(8,48)
		"BOW":
			$PlayerWeaponType.region_rect.position = Vector2(0,56)
	$PlayerStats.text = String(hp)+"/"+String(mhp)
	$PlayerPower.text = String(playerattack[0])+"d"+String(playerattack[1])+"+"+String(playerattack[2])
	$PlayerHPBar.region_rect.size.x = int(46*float(float(hp)/float(mhp)))
	$PlayerPOWBar.region_rect.size.x = int(35*float(float(attackpower)/100.0))
	$EnemyStats.text = String(ehp)+"/"+String(emhp)
	$EnemyStats2.text = String(enemyattack[0])+"dX+"+String(enemyattack[1])+"d"+String(enemyattack[2])+"+"+String(enemyattack[3])
	$EnemyHPBar.region_rect.size.x = int(46*float(float(ehp)/float(emhp)))
	$EnemyPOWBar.region_rect.size.x = int(35*float(enemyattacktimer/100))


func calculate_offset(rotate_state, mainpos):
	if rotate_state == 0: #offset on 0 rotate is always (0,-1)
		return Vector2(0,-1)
	elif rotate_state == 3: #offset on 3 rotate is always (0,1)
		return Vector2(0,1)
	else:
		match int(mainpos.x) % 2: #other offsets depend on positioning
			0:
				match rotate_state:
					1:
						return Vector2(1,-1)
					2:
						return Vector2(1,0)
					4:
						return Vector2(-1,0)
					5:
						return Vector2(-1,-1)
			1:
				match rotate_state:
					1:
						return Vector2(1,0)
					2:
						return Vector2(1,1)
					4:
						return Vector2(-1,1)
					5:
						return Vector2(-1,0)

func bound_to_playfield(position):
	position.x = floor(clamp(position.x,0,6))
	if position.x == 0 or position.x == 6:
		position.y = clamp(position.y,0,3)
	elif position.x == 1 or position.x == 5:
		position.y = clamp(position.y,-1,3)
	elif position.x == 2 or position.x == 4:
		position.y = clamp(position.y,-1,4)
	elif position.x == 3:
		position.y = clamp(position.y,-2,4)
	return position

func place_piece(position):
	#big check to make sure second piece is in playfield
	var offset = calculate_offset(nextrotate,nextpos)
	if position + calculate_offset(nextrotate,nextpos) == bound_to_playfield(position+calculate_offset(nextrotate,nextpos)) and field.get_cell(position.x,position.y) != 4 and field.get_cell(position.x+offset.x,position.y+offset.y) != 4:
		if field.get_cell(position.x,position.y) != -1:
			attackpower -= 3 + Global.upgrade_count_spd/2
			var clearanimdestroy = clearanim.instance()
			clearanimdestroy.position = field.map_to_world(position)+Vector2(8,8)
			clearanimdestroy.destroy = true
			clearanimdestroy.cleartime = 0
			field.add_child(clearanimdestroy)
		if field.get_cell(position.x+offset.x,position.y+offset.y) != -1:
			attackpower -= 3 + Global.upgrade_count_spd/2
			var clearanimdestroy = clearanim.instance()
			clearanimdestroy.position = field.map_to_world(position+offset)+Vector2(8,8)
			clearanimdestroy.destroy = true
			clearanimdestroy.cleartime = 0
			field.add_child(clearanimdestroy)
		attackpower = clamp(attackpower,0,999)
		field.set_cell(position.x,position.y,nextpiece[0])
		var placeanim1 = placeanim.instance()
		placeanim1.position = field.map_to_world(position)+Vector2(8,10)
		field.add_child(placeanim1)
		field.set_cell(position.x+offset.x,position.y+offset.y,nextpiece[1])
		var placeanim2 = placeanim.instance()
		placeanim2.position = field.map_to_world(position+offset)+Vector2(8,10)
		field.add_child(placeanim2)
		test_clear_link()
		update_shadows()
		$Place.pitch_scale = rand_range(0.95,1.05)
		$Place.play()
		nextpiece = nextpieces[0]
		nextpieces.remove(0)
	else:
		#do nothing
		pass

func test_clear_link():
	var color = 0
	var branches = []
	var pos_set = []
	var can_clear = false
	for i in 4:
		can_clear = false
		pos_set.clear()
		branches.clear()
		pos_set.append(Vector2(0,i))
		branches.append(Vector2(0,i))
		color = field.get_cell(branches[0].x,branches[0].y)
		if color != -1 and color != 4:
			while branches.size() > 0:
				match int(branches[0].x)%2:
					0:
						var test_tile = Vector2(branches[0].x+1,branches[0].y-1)
						if field.get_cell(test_tile.x,test_tile.y) == color and !pos_set.has(test_tile):
							branches.append(test_tile)
							pos_set.append(test_tile)
						test_tile = Vector2(branches[0].x+1,branches[0].y)
						if field.get_cell(test_tile.x,test_tile.y) == color and !pos_set.has(test_tile):
							branches.append(test_tile)
							pos_set.append(test_tile)
					1:
						var test_tile = Vector2(branches[0].x+1,branches[0].y)
						if field.get_cell(test_tile.x,test_tile.y) == color and !pos_set.has(test_tile):
							branches.append(test_tile)
							pos_set.append(test_tile)
						test_tile = Vector2(branches[0].x+1,branches[0].y+1)
						if field.get_cell(test_tile.x,test_tile.y) == color and !pos_set.has(test_tile):
							branches.append(test_tile)
							pos_set.append(test_tile)
				var test_tile = Vector2(branches[0].x,branches[0].y-1)
				if field.get_cell(test_tile.x,test_tile.y) == color and !pos_set.has(test_tile):
					branches.append(test_tile)
					pos_set.append(test_tile)
				test_tile = Vector2(branches[0].x,branches[0].y+1)
				if field.get_cell(test_tile.x,test_tile.y) == color and !pos_set.has(test_tile):
					branches.append(test_tile)
					pos_set.append(test_tile)
				branches.remove(0)
			for tile in pos_set:
				if tile.x == 6:
					can_clear = true
					break
			if can_clear:
				$LinkCreate.play()
				var totalscore = 0
				var j = 0
				var totalpower = 0
				for tile in pos_set:
					j += 1
					field.set_cell(tile.x,tile.y,-1)
					totalscore += 10+floor(pos_set.size()/5) + 5*(Global.stage-1)
					score += 10+floor(pos_set.size()/5) + 5*(Global.stage-1)
					attackpower += 2+(pos_set.size()/3)
					totalpower += 2+(pos_set.size()/3)
					var clearanim1 = clearanim.instance()
					clearanim1.position = field.map_to_world(tile)+Vector2(8,8)
					clearanim1.cleartime = 0.5+0.05*j
					field.add_child(clearanim1)
					match int(tile.x)%2:
						0:
							var offsets = [Vector2(0,-1),Vector2(1,-1),Vector2(1,0),Vector2(0,1),Vector2(-1,0),Vector2(-1,-1)]
							for offset1 in offsets:
								if field.get_cell(tile.x+offset1.x,tile.y+offset1.y) == 4:
									j += 1
									var clearanim2 = clearanim.instance()
									clearanim2.position = field.map_to_world(Vector2(tile.x+offset1.x,tile.y+offset1.y))+Vector2(8,8)
									clearanim2.cleartime = 0.5+0.05*j
									field.add_child(clearanim2)
									field.set_cell(tile.x+offset1.x,tile.y+offset1.y,-1)
									score += 50
									totalscore += 50
									attackpower += 5
									totalpower += 5
						1:
							var offsets = [Vector2(0,-1),Vector2(1,0),Vector2(1,1),Vector2(0,1),Vector2(-1,1),Vector2(-1,0)]
							for offset1 in offsets:
								if field.get_cell(tile.x+offset1.x,tile.y+offset1.y) == 4:
									j += 1
									var clearanim2 = clearanim.instance()
									clearanim2.position = field.map_to_world(Vector2(tile.x+offset1.x,tile.y+offset1.y))+Vector2(8,8)
									clearanim2.cleartime = 0.5+0.05*j
									field.add_child(clearanim2)
									field.set_cell(tile.x+offset1.x,tile.y+offset1.y,-1)
									score += 50
									totalscore += 50
									attackpower += 5
									totalpower += 5
				update_status(String(j)+" LINK! +"+String(int(totalpower))+" POWER")
				control_timer = 0.5+j * 0.05
				hp += ceil(mhp/100)
				hp = clamp(hp,0,mhp)
				print(totalscore)
				update_shadows()

func roll_individual_dice(count, type):
	var array = []
	for i in count:
		array.append(randi()%type+1)
	return array

func player_anim_set(state):
	match state:
		0:
			$PlayerSprite.region_rect.position = Vector2(0,0)
			playeranimtime = 0.5
		2:
			$PlayerSprite.region_rect.position = Vector2(32,0)
			playeranimtime = 0.5
		3:
			$PlayerSprite.region_rect.position = Vector2(48,0)
			playeranimtime = 1
		4:
			$PlayerSprite.region_rect.position = Vector2(0,16)
			playeranimtime = 0.25
			specialanimtimer = 2
		6:
			$PlayerSprite.region_rect.position = Vector2(0,32)
			playeranimtime = 0.25
			specialanimtimer = 2
		8:
			$PlayerSprite.region_rect.position = Vector2(0,48)
			playeranimtime = 0.25
			specialanimtimer = 2
		10:
			$PlayerSprite.region_rect.position = Vector2(48,16)
			playeranimtime = 100
	playeranimstate = state

func player_anim_update():
	#playerstates: 0. idle a, 1. idle b, 2. hit weak, 3. hit strong
	# 4. sword attack a, 5. sword attack b. 6. ranged attack a, 7. ranged attack b.
	# 8. spear attack a, 9. spear attack b, 10. die
	match playeranimstate:
		0:
			$PlayerSprite.region_rect.position = Vector2(16,0)
			playeranimstate = 1
			playeranimtime = 0.5
		1:
			$PlayerSprite.region_rect.position = Vector2(0,0)
			playeranimstate = 0
			playeranimtime = 0.5
		2:
			$PlayerSprite.region_rect.position = Vector2(0,0)
			playeranimstate = 0
			playeranimtime = 0.5
		3:
			$PlayerSprite.region_rect.position = Vector2(0,0)
			playeranimstate = 0
			playeranimtime = 0.5
		4:
			$PlayerSprite.region_rect.position = Vector2(16,16)
			playeranimstate = 5
			playeranimtime = 0.25
		5:
			$PlayerSprite.region_rect.position = Vector2(0,16)
			playeranimstate = 4
			playeranimtime = 0.25
		6:
			$PlayerSprite.region_rect.position = Vector2(16,32)
			playeranimstate = 7
			playeranimtime = 0.25
		7:
			$PlayerSprite.region_rect.position = Vector2(0,32)
			playeranimstate = 6
			playeranimtime = 0.25
		8:
			$PlayerSprite.region_rect.position = Vector2(16,48)
			playeranimstate = 9
			playeranimtime = 0.25
		9:
			$PlayerSprite.region_rect.position = Vector2(0,48)
			playeranimstate = 8
			playeranimtime = 0.25
		10:
			$PlayerSprite.region_rect.position = Vector2(48,16)
			playeranimstate = 10
			playeranimtime = 100

func enemy_anim_set(state):
	match state:
		0:
			$EnemySprite.region_rect.position = Vector2(0,0)
			enemyanimtime = 0.4
		2:
			$EnemySprite.region_rect.position = Vector2(0,16)
			enemyanimtime = 1
		3:
			$EnemySprite.region_rect.position = Vector2(16,16)
			enemyanimtime = 1
		4:
			$EnemySprite.region_rect.position = Vector2(0,32)
			enemyanimtime = 100
	enemyanimstate = state

func enemy_anim_update():
	match enemyanimstate:
		0:
			$EnemySprite.region_rect.position = Vector2(16,0)
			enemyanimstate = 1
			enemyanimtime = 0.4
		1:
			$EnemySprite.region_rect.position = Vector2(0,0)
			enemyanimstate = 0
			enemyanimtime = 0.4
		2:
			$EnemySprite.region_rect.position = Vector2(16,0)
			enemyanimstate = 1
			enemyanimtime = 0.4
		3:
			$EnemySprite.region_rect.position = Vector2(0,0)
			enemyanimstate = 1
			enemyanimtime = 0.4
		4:
			$EnemySprite.region_rect.position = Vector2(0,32)
			enemyanimstate = 4
			enemyanimtime = 100

func update_status(text):
	if $AnimationPlayer.is_playing():
		$Status.text += "\n"+text
	else:
		$Status.text = text
	$AnimationPlayer.stop()
	$AnimationPlayer.play("StatusUpdate")
