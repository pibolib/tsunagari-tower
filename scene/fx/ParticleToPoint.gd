extends Node2D

const POP = preload("res://scene/fx/Pop.tscn")

export var target := Vector2(0,0)
onready var tween = $Tween

func _ready():
	tween.interpolate_property(self, "position", position, target, 0.5, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween.start()


func _on_Tween_tween_completed(_object, _key):
	var pop = POP.instance()
	pop.position = position
	get_parent().add_child(pop)
	queue_free()
