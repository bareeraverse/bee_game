extends CharacterBody2D
var gravity = 500
var jump_force = -250
var active = false

func _ready():
	$AnimatedSprite2D.play()

func _physics_process(delta):
	if not active:
		return
	
	velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force
		$flap.play()  # 👈 add this line
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision:
			die()
			return
	
	if position.y < 0:
		position.y = 0
	if position.y > 617:
		die()

func die():
	active = false
	velocity = Vector2.ZERO
	$hit.play()  
	get_parent().show_game_over()
