extends Node2D

var speed = 120

func _process(delta):
	position.x -= speed * delta
