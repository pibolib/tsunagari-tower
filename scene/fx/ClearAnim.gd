extends Node2D

var cleartime = 0
var opposite = 0.3
var onetime = true
var destroy = false
func _ready():
	
	$AudioStreamPlayer.pitch_scale = 1+cleartime/20
	if destroy: 
		$CPUParticles2D.modulate = Color(0.6,0.6,0.6)
		$AudioStreamPlayer.pitch_scale = 0.6
		$AudioStreamPlayer.volume_db -= 5

func _process(delta):
	opposite += delta
	if cleartime >= 0:
		$Sprite.position.x = rand_range(-opposite*2,opposite*2)
		$Sprite.position.y = rand_range(-opposite*2,opposite*2)
		cleartime -= delta
	if cleartime <= 0 and onetime:
		$AudioStreamPlayer.play()
		$AnimationPlayer.play("Default")
		onetime = false
