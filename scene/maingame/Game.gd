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
var playerattack = [3,2,1] 
var ehp = 20
var emhp = 20
var enemyattack = [2,2,2,0]
var enemyattacktimer = 0 #out of 100
var enemyspeed = 6
var attackglobaldelay = 0
var playerdamage = 0
var enemydamage = 0

var score = 0

func _ready():
	update_shadows()

func _process(delta):
	nextpos = bound_to_playfield(field.world_to_map(field.get_local_mouse_position()))
	update_next()
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
	update_ui()
	if attackpower >= 100 and attackglobaldelay <= 0:
		attackpower -= 100
		var attackdice = roll_individual_dice(playerattack[0],playerattack[1])
		for dice in attackdice.size():
			var roll = diceroll.instance()
			#176, 8
			roll.position = Vector2(8+16*dice,176)
			roll.init(attackdice[dice],playerattack[1],0.2*dice)
			add_child(roll)
			playerdamage += attackdice[dice]
		playerdamage += playerattack[2]
		attackglobaldelay += 1 + 0.2*attackdice.size()
	if enemyattacktimer >= 100 and attackglobaldelay <= 0:
		enemyattacktimer -= 100
		var attackdice = roll_individual_dice(enemyattack[1],enemyattack[2])
		for dice in attackdice.size():
			var roll = diceroll.instance()
			#176, 8
			roll.position = Vector2(220-16*dice,36)
			roll.init(attackdice[dice],enemyattack[1],0.2*dice)
			add_child(roll)
			enemydamage += attackdice[dice]
		enemydamage += enemyattack[3]
		attackglobaldelay += 1 + 0.2*attackdice.size()
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
		if playerdamage >= 0:
			ehp -= playerdamage
			playerdamage = 0
		if enemydamage >= 0:
			hp -= enemydamage
			enemydamage = 0
			
		
	
func _input(event):
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
	$PlayerStats.text = "HP: "+String(hp)+"/"+String(mhp)+"\nPOW: "+String(int(attackpower))+"%\nATK: "+String(playerattack[0])+"d"+String(playerattack[1])+"+"+String(playerattack[2])
	$EnemyStats.text = "HP: "+String(ehp)+"/"+String(emhp)+"\nPOW: "+String(int(enemyattacktimer))+"%\nATK: "+String(enemyattack[0])+"dX+"+String(enemyattack[1])+"d"+String(enemyattack[2])+"+"+String(enemyattack[3])


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
			attackpower -= 3
		if field.get_cell(position.x+offset.x,position.y+offset.y) != -1:
			attackpower -= 3
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
				var totalscore = 0
				var j = 0
				for tile in pos_set:
					j += 1
					field.set_cell(tile.x,tile.y,-1)
					totalscore += 10+floor(pos_set.size()/5)
					score += 10+floor(pos_set.size()/5)
					attackpower += 2+(pos_set.size()/3)
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
				control_timer = 0.5+j * 0.05
				hp += ceil(mhp/20)
				hp = clamp(hp,0,mhp)
				print(totalscore)
				update_shadows()

func roll_individual_dice(count, type):
	var array = []
	for i in count:
		array.append(randi()%type+1)
	return array
