extends Node2D

var placeanim = preload("res://scene/fx/PlaceAnim.tscn")
var clearanim = preload("res://scene/fx/ClearAnim.tscn")
var diceroll = preload("res://scene/fx/DiceRoll.tscn")
var attackanim = preload("res://scene/fx/BallTargetPoint.tscn")
var popup = preload("res://scene/fx/Popup.tscn")
var enemyattackanim = preload("res://scene/fx/EnemyAttack.tscn")

onready var field = $Playfield/Field
var nextpiece = [0,0]
var nextpieces = []
var nextpos = Vector2(0,3)
var nextrotate = 0
var mousepos = Vector2(0,0)
var control_timer = 0
var attackpower = 0
var attackpowerdisplay = 0
var hp = 30
var mhp = 30
var playerattack = [2,6,0] 
var playerspecial = 0
var enemyspecial = 0
var weapontype = "SWORD"
var ehp = 20
var emhp = 20
var enemygarbagepos = []
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
var randomcolor = 0
var randomstatus = 1
var overwritelinkmod = 0
var overwritelinkchain = 0
var playerdamagetick = 0

var score = 0
var gameactive = false
var gameover = false
var win = false
var time = 0
var timetilltrans = 0
var statusactive = false
var rewarded = false
var pshake = 0
var eshake = 0
var excourse = false
var extra_stage_phase = 0
onready var extra_stage_timer = Timer.new()

func _ready():
	add_child(extra_stage_timer)
	if Global.stage == 9 or Global.stage == 10:
		$BG.position.x -= 252
	if Global.stage == 10:
		$BG.tile_set = load("res://asset/gfx/BG2.tres")
		$BG/Node2D/Node2D/ColorRect.color = Color("#249fde")
		$BG/CPUParticles2D2.visible = false
		$ExtraStageTimeLabel.visible = true
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
	if Global.stage == 10:
		$EnemySprite.texture = load("res://asset/gfx/spiritsword.png")
	$EnemyName.text = Global.enemystats[Global.stage].NAME
	enemyspeed = Global.enemystats[Global.stage].POWER_SPEED
	update_ui()
	update_shadows()
	for i in 10:
		generate_garbage_pos(10)

func _process(delta):
	if pshake > 0:
		pshake -= delta*10
	if pshake <= 0:
		pshake = 0
	if eshake > 0:
		eshake -= delta*10
	if eshake <= 0:
		eshake = 0
	attackpowerdisplay = lerp(attackpowerdisplay,attackpower,2*delta)
	attackpowerdisplay = lerp(attackpowerdisplay,attackpower,2*delta)
	time += delta
	if time >= 2 and !jingleplayed:
		update_status("Get ready...")
		$GetReady.play()
		jingleplayed = true
	if time >= 5 and hp > 0 and ehp > 0:
		if !statusactive:
			update_status("Game Start!")
			if Global.stage == 10:
				start_extra_stage_timer()
			match Global.stage:
				10:
					Global.current_bgm = 9
				9:
					Global.current_bgm = 7
				4,5,6,7,8:
					Global.current_bgm = 8
				0,1,2,3:
					Global.current_bgm = 6
			statusactive = true
		gameactive = true
	else:
		if gameactive:
			if Global.stage != 10 or extra_stage_phase == 2:
				Global.current_bgm = -1
				gameactive = false
			if hp <= 0:
				Global.current_bgm = -1
				gameactive = false
		if hp <= 0:
			if !gameover:
				update_status("You are down!")
				if Global.stage == 10:
					Global.stage = 1000
			player_anim_set(10)
			gameover = true
			timetilltrans += delta
			if timetilltrans >= 2:
				Global.to_scene = "res://scene/menus/GameOver.tscn"
		if ehp <= 0:
			if timetilltrans < 2:
				if !extra_stage_timer.is_stopped():
					extra_stage_timer.stop()
				timetilltrans += delta
			else:
				if Global.stage == 10:
					match extra_stage_phase:
						0:
							start_extra_stage_timer()
							ehp = 95
							$EnemySprite.texture = load("res://asset/gfx/spiritspear.png")
							timetilltrans = 0
							enemy_anim_set(0)
							win = false
						1:
							start_extra_stage_timer()
							ehp = 90
							$EnemySprite.texture = load("res://asset/gfx/spiritbow.png")
							timetilltrans = 0
							enemy_anim_set(0)
							win = false
						2:
							Global.stage = 1001
							Global.to_scene = "res://scene/menus/GameOver.tscn"
					extra_stage_phase += 1
				elif Global.stage == 9:
					if Global.continue_count > 0:
						Global.stage = 999
						Global.to_scene = "res://scene/menus/GameOver.tscn"
					else:
						Global.to_scene = "res://scene/menus/UpgradeMenu.tscn"
				elif Global.stage < 12:
					Global.to_scene = "res://scene/menus/UpgradeMenu.tscn"
			if !win:
				if Global.stage == 10 and extra_stage_phase < 3:
					update_status("Phase Clear!")
				else:
					update_status("Enemy Defeated!")
					Global.xp += score
					Global.totalxp += score
					enemy_anim_set(4)
				win = true
	update_ui()
	update_next()
	update_shadows()
	if gameactive:
		if attackpower <= -25:
			playerdamagetick += delta
		if playerdamagetick >= 1:
			playerdamagetick -= 1
			if attackpower == -50:
				hp -= max(2,ceil(mhp/50))
			elif attackpower <= -25:
				hp -= max(1,ceil(mhp/100))
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
			var next = []
			if randomstatus == 0:
				next = [randomcolor,randomcolor]
			else:
				var rand = randi()%4
				next = [randomcolor,(rand+int(rand==randomcolor))%4]
			randomstatus += 1
			if randomstatus == 4:
				randomcolor = (randomcolor + 9)%4
				randomstatus = 0
			nextpieces.append(next)
		if attackpower >= 100 and attackglobaldelay <= 0:
			var totalpower = 0
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
				roll.position = Vector2(8+16*dice,176)
				roll.init(attackdice[dice],playerattack[1],0.25*dice)
				add_child(roll)
				playerdamage += attackdice[dice]
				totalpower += attackdice[dice]
			totalpower += playerattack[2]
			for i in totalpower/2:
				var myattackanim = attackanim.instance()
				myattackanim.position = Vector2(28,160)
				myattackanim.target = Vector2(220,32)
				add_child(myattackanim)
			playerdamage += playerattack[2]
			attackglobaldelay += 1 + 0.25*attackdice.size()
		if enemyattacktimer >= 100 and attackglobaldelay <= 0:
			var totalpower = 0
			enemy_anim_set(2)
			enemyattacktimer -= 100
			var attackdice = roll_individual_dice(enemyattack[1],enemyattack[2])
			for dice in attackdice.size():
				var roll = diceroll.instance()
				roll.position = Vector2(220-16*dice,41)
				roll.init(attackdice[dice],enemyattack[2],0.4*dice)
				roll.enemy = true
				add_child(roll)
				enemydamage += attackdice[dice]
				totalpower += attackdice[dice]
			enemydamage += enemyattack[3]
			totalpower += enemyattack[3]
			for i in totalpower/2:
				var myattackanim = attackanim.instance()
				myattackanim.position = Vector2(220,32)
				myattackanim.target = Vector2(28,160)
				add_child(myattackanim)
			attackglobaldelay += 1 + 0.4*attackdice.size()
			create_garbage()
		if attackglobaldelay <= 0:
			if playerdamage > 0:
				eshake += 6
				if overwritelinkmod > 0:
					update_status("Dealt "+String(playerdamage)+"+"+String(overwritelinkmod)+" damage!")
				elif overwritelinkmod < 0:
					update_status("Dealt "+String(playerdamage)+String(overwritelinkmod)+" damage!")
				else:
					update_status("Dealt "+String(playerdamage)+" damage!")
				player_anim_set(0)
				$EnemyHurt.pitch_scale = rand_range(0.7,1.1)
				$EnemyHurt.playing = true
				enemy_anim_set(3)
				ehp -= playerdamage + overwritelinkmod
				playerdamage = 0
				overwritelinkmod = 0
			if enemydamage > 0:
				pshake += 6
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
			update_next()
			$Rotate.play()
		elif event.is_action_pressed("action_rotate_ccw_1shot") or event.is_action_pressed("action_rotate_ccw"):
			nextrotate -= 1
			if nextrotate < 0:
				nextrotate = 5
			update_next()
			$Rotate.play()
		elif event.is_action_pressed("action_place_piece") and control_timer <= 0:
			place_piece(nextpos)
		elif event.is_action_pressed("action_debug_die"):
			enemydamage = 999

func update_shadows():
	$Playfield/FieldShadows.clear()
	for tile in field.get_used_cells():
		$Playfield/FieldShadows.set_cell(tile.x,tile.y,0)
	for tile in $Playfield/NextDisplay.get_used_cells():
		$Playfield/FieldShadows.set_cell(tile.x,tile.y,0)

func update_next():
	$Playfield/Next.clear()
	$Playfield/Next.set_cell(nextpos.x,nextpos.y,nextpiece[0])
	var offset = calculate_offset(nextrotate,nextpos) 
	if (Vector2(nextpos.x+offset.x,nextpos.y+offset.y) == bound_to_playfield(Vector2(nextpos.x+offset.x,nextpos.y+offset.y))) and $Playfield/Field.get_cell(nextpos.x+offset.x,nextpos.y+offset.y) != 4:
		$Playfield/Next.set_cell(nextpos.x+offset.x,nextpos.y+offset.y,nextpiece[1])
	else:
		$Playfield/Next.set_cell(nextpos.x+offset.x,nextpos.y+offset.y,4)

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
	$PlayerHPBar.region_rect.size.x = int(clamp(46*float(float(hp)/float(mhp)),0,46))
	$PlayerPOWBar.region_rect.size.x = int(35*float(float(attackpower)/100.0))
	$EnemyStats.text = String(ehp)+"/"+String(emhp)
	$EnemyStats2.text = String(enemyattack[0])+"dX+"+String(enemyattack[1])+"d"+String(enemyattack[2])+"+"+String(enemyattack[3])
	$EnemyHPBar.region_rect.size.x = int(clamp(46*float(float(ehp)/float(emhp)),0,46))
	$EnemyPOWBar.region_rect.size.x = int(35*float(enemyattacktimer/100))
	$PlayerSprite.offset.x = rand_range(-pshake,pshake)
	$EnemySprite.offset.x = rand_range(-eshake,eshake)
	$PlayerPowerTag.text = String(round(attackpowerdisplay))+"%"
	$EnemyPowerTag.text = String(int(enemyattacktimer))+"%"
	$PerfectChain.visible = !(overwritelinkchain<=1)
	$PerfectChain.text = String(overwritelinkchain)
	$Warning.visible = (attackpower<=-25 or hp <= 0.2*mhp)
	$Warning.text = ""
	$ExtraStageTimeLabel.text = "%2.1f" % extra_stage_timer.time_left
	if attackpower == -50:
		$Warning.text += "WARNING: POWER TOO LOW!!!\n"
	elif attackpower <= -25:
		$Warning.text += "WARNING: POWER LOW!\n"
	if hp <= 0.2*mhp:
		$Warning.text += "WARNING: HP LOW!\n"
	if attackpower >= 0:
		if round(attackpowerdisplay) < round(attackpower):
			$PlayerPowerTag.modulate = Color(0.8,1,0.8)
		elif round(attackpowerdisplay) > round(attackpower):
			$PlayerPowerTag.modulate = Color(1,0.8,0.8)
		else:
			$PlayerPowerTag.modulate = Color(1,1,1)
	elif attackpower == -50:
		$PlayerPowerTag.modulate = Color(0.9,0,0)
	elif attackpower <= -25:
		$PlayerPowerTag.modulate = Color(0.9,0.2,0.2)
	elif attackpower < 0:
		$PlayerPowerTag.modulate = Color(0.9,0.6,0.6)


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
	var lostpower = 0
	if position + calculate_offset(nextrotate,nextpos) == bound_to_playfield(position+calculate_offset(nextrotate,nextpos)) and field.get_cell(position.x,position.y) != 4 and field.get_cell(position.x+offset.x,position.y+offset.y) != 4:
		if field.get_cell(position.x,position.y) != -1:
			attackpower -= 3 + Global.upgrade_count_spd/2
			lostpower += 3 + Global.upgrade_count_spd/2
			var clearanimdestroy = clearanim.instance()
			clearanimdestroy.position = field.map_to_world(position)+Vector2(8,8)
			clearanimdestroy.destroy = true
			clearanimdestroy.cleartime = 0
			field.add_child(clearanimdestroy)
			overwritelinkchain = 0
		if field.get_cell(position.x+offset.x,position.y+offset.y) != -1:
			lostpower += 3 + Global.upgrade_count_spd/2
			attackpower -= 3 + Global.upgrade_count_spd/2
			var clearanimdestroy = clearanim.instance()
			clearanimdestroy.position = field.map_to_world(position+offset)+Vector2(8,8)
			clearanimdestroy.destroy = true
			clearanimdestroy.cleartime = 0
			field.add_child(clearanimdestroy)
			overwritelinkchain = 0
		if lostpower > 0:
			var newpopup = popup.instance()
			newpopup.position = Vector2(56,184)
			newpopup.text = "-"+String(int(lostpower))+"%"
			newpopup.speed = 4
			newpopup.dir = Vector2(0,1)
			newpopup.color = Color(0.8,0,0)
			add_child(newpopup)
		attackpower = clamp(attackpower,-50,999)
		playfield_add_piece(position,nextpiece[0])
		playfield_add_piece(position+offset,nextpiece[1])
		test_clear_link()
		update_shadows()
		$Place.pitch_scale = rand_range(0.95,1.05)
		$Place.play()
		nextpiece = nextpieces[0]
		nextpieces.remove(0)

func playfield_add_piece(position = Vector2(0,0), type = 0):
	var placeanim1 = placeanim.instance()
	placeanim1.position = field.map_to_world(position)+Vector2(8,10)
	field.add_child(placeanim1)
	field.set_cell(position.x,position.y,type)

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
# warning-ignore:unused_variable
				var totalscore = 0
				var j = 0
				var totalpower = 0
				for tile in pos_set:
					j += 1
					#if $Playfield/FieldBG.get_cell(tile.x,tile.y) == color+4:
						#attackpower += 2
						#totalpower += 2
						#score += 5
					field.set_cell(tile.x,tile.y,-1)
					#$Playfield/FieldBG.set_cell(tile.x,tile.y,color+4)
					totalscore += 12+floor(pos_set.size()/4) + 6*(Global.stage-1)
					score += 12+floor(pos_set.size()/4) + 6*(Global.stage-1)
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
									totalscore += 12+floor(pos_set.size()/4) + 6*(Global.stage-1)
									score += 12+floor(pos_set.size()/4) + 6*(Global.stage-1)
									attackpower += 2+(pos_set.size()/3)*1.25
									totalpower += 2+(pos_set.size()/3)*1.25
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
									totalscore += 12+floor(pos_set.size()/4) + 6*(Global.stage-1)
									score += 12+floor(pos_set.size()/4) + 6*(Global.stage-1)
									attackpower += 2+(pos_set.size()/3)*1.25
									totalpower += 2+(pos_set.size()/3)*1.25
				update_status(String(j)+" LINK! +"+String(int(totalpower))+" POWER")
				var newpopup = popup.instance()
				newpopup.position = Vector2(56,184)
				newpopup.text = "+"+String(int(totalpower))+"%"
				newpopup.speed = 8
				add_child(newpopup)
				control_timer = 0.5+j * 0.05
				hp += ceil(mhp/100)
				hp = clamp(hp,0,mhp)
				update_shadows()

func roll_individual_dice(count := 1, type := 6):
	var array = []
	for i in count:
		array.append(randi()%type+1)
	return array

func player_anim_set(state := 0):
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

func enemy_anim_set(state := 0):
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

func update_status(text := ""):
	if $AnimationPlayer.is_playing():
		$Status.text += "\n"+text
	else:
		$Status.text = text
	$AnimationPlayer.stop()
	$AnimationPlayer.play("StatusUpdate")

func create_garbage(): # take out enemy garbage bit from main loop, put into its own function
	for dice in enemyattack[0]:
		var pos = enemygarbagepos[0]
		playfield_add_piece(pos,4)
		enemygarbagepos.remove(0)
		generate_garbage_pos()
	update_shadows()
	
func generate_garbage_pos(attempts := 3):
	var pos = bound_to_playfield(Vector2(randi()%5+1,randi()%7-2))
	while field.get_cell(pos.x,pos.y) == 4 and attempts > 0:
		attempts -= 1
		pos = bound_to_playfield(Vector2(randi()%5+1,randi()%7-2))
	enemygarbagepos.append(pos)

func _on_EnemyGarbageAnim_timeout():
	for i in enemyattack[0]:
		if enemyattacktimer >= 66:
			var pos = enemygarbagepos[i]
			var enemyanim1 = enemyattackanim.instance()
			enemyanim1.position = field.map_to_world(pos)+Vector2(8,10)
			field.add_child(enemyanim1)
	$EnemyGarbageAnim.start(1)

func start_extra_stage_timer():
	extra_stage_timer.start(90-5*extra_stage_phase)
	yield(extra_stage_timer, "timeout")
	enemydamage = 999
	enemyattacktimer = 0
	extra_stage_timer.stop()
