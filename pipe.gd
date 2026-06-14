extends Node2D

signal scored

var speed = 200
var gap = 180
var has_scored = false

func _ready():
	add_to_group("pipes")
	$"top pipe".scale = Vector2(3.0, 3.0)
	$"bottom pipe".scale = Vector2(3.0, 3.0)
	$"top pipe".flip_v = true
	$"top pipe".position.y = -(gap / 2.0 + 200)
	$"bottom pipe".position.y = gap / 2.0 + 200
	$CollisionShape2D.shape.size = Vector2(48, 326)
	$CollisionShape2D.position = Vector2(0, $"top pipe".position.y)
	$CollisionShape2D2.shape.size = Vector2(48, 326)
	$CollisionShape2D2.position = Vector2(0, $"bottom pipe".position.y)

func _process(delta):
	position.x -= speed * delta
	
	if not has_scored:
		var bee = get_tree().current_scene.get_node("bee")
		if bee and global_position.x < bee.global_position.x:
			has_scored = true
			emit_signal("scored")
	
	if position.x < -300:
		queue_free()
