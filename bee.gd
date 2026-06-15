extends CharacterBody2D
var gravity = 500
var jump_force = -250
var active = false
var dying = false

func _ready():
	$AnimatedSprite2D.play()
	$DeadSprite.visible = false
	$DeadSprite.scale = Vector2(3.0, 3.0)

func _physics_process(delta):
	if not active and not dying:
		return
	
	velocity.y += gravity * delta
	
	if active and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force
		$flap.play()
	
	move_and_slide()
	
	if active:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision:
				die()
				return
		
		if position.y < 0:
			position.y = 0
		if position.y > 617:
			die()
	
	if dying:
		rotation_degrees += 300 * delta
		if position.y > 700:
			get_parent().show_game_over()

func die():
	active = false
	dying = true
	velocity.y = -200
	velocity.x = 0
	position.x = min(position.x, 350)  # bee ko thoda peeche khinch lo agar zyada aage chali gayi
	$hit.play()
	$AnimatedSprite2D.visible = false
	$DeadSprite.texture = load("res://dead.png")
	$DeadSprite.visible = true
	for pipe in get_tree().get_nodes_in_group("pipes"):
		pipe.set_process(false)
	get_parent().get_node("PipeTimer").stop()
	get_parent().show_game_over()  # <-- seedha yahan call karo
