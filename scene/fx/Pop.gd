extends CPUParticles2D

func _ready():
	emitting = true

func _on_Timer_timeout():
	$Timer.stop()
	queue_free()
