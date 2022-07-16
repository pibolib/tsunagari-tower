extends Node2D

var cleartime = 0
var onetime = true
func _process(delta):
	if cleartime >= 0:
		cleartime -= delta
	if cleartime <= 0 and onetime:
		$AnimationPlayer.play("Default")
		onetime = false
