extends Node2D


var tick = 0.1
var value = 4
var max_value = 6
var time = 0
var max_time = 1
var animout = false
var offset = 0
func _process(delta):
	time += delta
	if time <= 1 + offset:
		tick -= delta
		if tick <= 0:
			tick = 0.1
			$Label.text = String(randi()%max_value+1)
	elif time > 1 + offset and time < 2:
		$Label.text = String(value)
	elif time >= 2:
		if !animout:
			$AnimationPlayer.play("Default")
			animout = true

func init(val,max_val,off):
	value = val
	max_value = max_val
	offset = off
