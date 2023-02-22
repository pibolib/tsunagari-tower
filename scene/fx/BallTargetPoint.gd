extends Sprite


var velocity = Vector2(0,0)
var angle = 0
var target = Vector2(100,100)
var time = 0
var origin = Vector2(0,0)
var rate = 40
# Called when the node enters the scene tree for the first time.
func _ready():
	queue_free()
	origin = position
	angle = rand_range(-180,180)
	velocity.x = cos(deg2rad(angle))*5
	velocity.y = sin(deg2rad(angle))*5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity
	time += delta
	if time < 1.5:
		velocity *= delta*10
	else:
		velocity = Vector2(0,0)
		position = position.move_toward(target, rate*delta)
		rate += delta
	if position.distance_to(target) < 10 or position.distance_to(origin) > 400:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("die")
