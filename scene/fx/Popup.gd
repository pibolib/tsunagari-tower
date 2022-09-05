extends Node2D


var text = ""
var dir = Vector2(0,-1)
var speed = 8
var time = 0
var color = Color(1,1,1)

func _ready():
	$Text.text = text
	$Text.modulate = color

func _process(delta):
	time += delta
	position += dir*speed*delta
	if time >= 1:
		queue_free()
