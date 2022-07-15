extends Node2D

onready var field = $Playfield/Field
var nextpiece = [0,0]
var nextpieces = []
var nextpos = Vector2(0,3)
var nextrotate = 0
var mousepos = Vector2(0,0)
var control_timer = 0
var attackpower = 0

var score = 0

func _ready():
	update_shadows()

func _process(delta):
	nextpos = bound_to_playfield(field.world_to_map(field.get_local_mouse_position()))
	update_next()
	if control_timer > 0:
		control_timer -= delta
	if nextpieces.size() <= 1:
		var next = [randi()%4,randi()%4]
		nextpieces.append(next)
	update_ui()
	
func _input(event):
		if event.is_action_pressed("action_rotate_cw_1shot") or event.is_action_pressed("action_rotate_cw"):
			nextrotate += 1
			nextrotate = nextrotate % 6
		elif event.is_action_pressed("action_rotate_ccw_1shot") or event.is_action_pressed("action_rotate_ccw"):
			nextrotate -= 1
			if nextrotate < 0:
				nextrotate = 5
		elif event.is_action_pressed("action_place_piece"):
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
	$XP.text = "XP: "+String(score)+"\nPower: "+String(attackpower)
	$Playfield/NextDisplay.clear()
	var offset = calculate_offset(nextrotate,Vector2(3,-4))
	$Playfield/NextDisplay.set_cell(3,-5,nextpiece[0])
	$Playfield/NextDisplay.set_cell(3+offset.x,-5+offset.y,nextpiece[1])
	for i in nextpieces.size():
		$Playfield/NextDisplay.set_cell(8,-1+3*i,nextpieces[i][0])
		$Playfield/NextDisplay.set_cell(9,-1+3*i,nextpieces[i][1])


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
	if position + calculate_offset(nextrotate,nextpos) == bound_to_playfield(position+calculate_offset(nextrotate,nextpos)):
		field.set_cell(position.x,position.y,nextpiece[0])
		field.set_cell(position.x+offset.x,position.y+offset.y,nextpiece[1])
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
						if field.get_cell(test_tile.x,test_tile.y) == color:
							branches.append(test_tile)
							pos_set.append(test_tile)
						test_tile = Vector2(branches[0].x+1,branches[0].y)
						if field.get_cell(test_tile.x,test_tile.y) == color:
							branches.append(test_tile)
							pos_set.append(test_tile)
					1:
						var test_tile = Vector2(branches[0].x+1,branches[0].y)
						if field.get_cell(test_tile.x,test_tile.y) == color:
							branches.append(test_tile)
							pos_set.append(test_tile)
						test_tile = Vector2(branches[0].x+1,branches[0].y+1)
						if field.get_cell(test_tile.x,test_tile.y) == color:
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
				for tile in pos_set:
					field.set_cell(tile.x,tile.y,-1)
					totalscore += 10+floor(pos_set.size()/5)
					score += 10+floor(pos_set.size()/5)
					attackpower += 1+(pos_set.size()/10)
				print(totalscore)
				update_shadows()
