extends Node2D
var pipe_scene = preload("res://pipe.tscn")
var pixel_font = preload("res://fonts/Press_Start_2P/PressStart2P-Regular.ttf")
var score = 0
var best_score = 0
var game_started = false
var game_over = false

func _ready():
	randomize()
	load_best_score()
	$PipeTimer.timeout.connect(spawn_pipe)
	$PipeTimer.stop()
	
	$UI/ScoreLabel.text = "0"
	$UI/ScoreLabel.add_theme_font_override("font", pixel_font)
	$UI/ScoreLabel.add_theme_font_size_override("font_size", 30)
	$UI/ScoreLabel.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	$UI/ScoreLabel.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	$UI/ScoreLabel.add_theme_constant_override("outline_size", 6)
	$UI/ScoreLabel.set_anchor(SIDE_LEFT, 1.0)
	$UI/ScoreLabel.set_anchor(SIDE_RIGHT, 1.0)
	$UI/ScoreLabel.set_offset(SIDE_LEFT, -100)
	$UI/ScoreLabel.set_offset(SIDE_RIGHT, 0)
	$UI/ScoreLabel.set_offset(SIDE_TOP, 10)
	$UI/ScoreLabel.set_offset(SIDE_BOTTOM, 50)

	$UI/BestLabel.text = "BEST: " + str(best_score)
	$UI/BestLabel.add_theme_font_override("font", pixel_font)
	$UI/BestLabel.add_theme_font_size_override("font_size", 16)
	$UI/BestLabel.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	$UI/BestLabel.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	$UI/BestLabel.add_theme_constant_override("outline_size", 4)
	$UI/BestLabel.set_anchor(SIDE_LEFT, 1.0)
	$UI/BestLabel.set_anchor(SIDE_RIGHT, 1.0)
	$UI/BestLabel.set_offset(SIDE_LEFT, -150)
	$UI/BestLabel.set_offset(SIDE_RIGHT, 0)
	$UI/BestLabel.set_offset(SIDE_TOP, 50)
	$UI/BestLabel.set_offset(SIDE_BOTTOM, 90)

	# New Best label
	$UI/NewBestLabel.text = "NEW BEST!"
	$UI/NewBestLabel.add_theme_font_override("font", pixel_font)
	$UI/NewBestLabel.add_theme_font_size_override("font_size", 28)
	$UI/NewBestLabel.add_theme_color_override("font_color", Color(1, 0.84, 0))
	$UI/NewBestLabel.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	$UI/NewBestLabel.add_theme_constant_override("outline_size", 4)
	$UI/NewBestLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UI/NewBestLabel.size = Vector2(500, 50)
	$UI/NewBestLabel.position = Vector2(326, 100)
	$UI/NewBestLabel.visible = false
	
	# Start screen
	$UI/StartScreen/StartLabel.text = "Press Space to Start"
	$UI/StartScreen/StartLabel.add_theme_font_override("font", pixel_font)
	$UI/StartScreen/StartLabel.add_theme_font_size_override("font_size", 20)
	$UI/StartScreen/StartLabel.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	$UI/StartScreen/StartLabel.add_theme_constant_override("outline_size", 3)
	$UI/StartScreen/StartLabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UI/StartScreen/StartLabel.size = Vector2(500, 50)
	$UI/StartScreen/StartLabel.position = Vector2(326, 300)
	$UI/StartScreen.visible = true
	
	# Dim overlay
	$UI/DimOverlay.color = Color(0, 0, 0, 0.5)
	$UI/DimOverlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	$UI/DimOverlay.size = Vector2(1152, 648)
	$UI/DimOverlay.position = Vector2(0, 0)
	$UI/DimOverlay.visible = false
	
	# Game over screen
	$UI/GameOverScreen.visible = false
	$UI/GameOverScreen/RestartButton.pressed.connect(_on_restart)
	$UI/GameOverScreen/ExitButton.pressed.connect(_on_exit)

func load_best_score():
	var config = ConfigFile.new()
	if config.load("user://save.cfg") == OK:
		best_score = config.get_value("scores", "best", 0)

func save_best_score():
	var config = ConfigFile.new()
	config.set_value("scores", "best", best_score)
	config.save("user://save.cfg")

var new_best_timer = 0.0

func _process(_delta):
	if not game_started and Input.is_action_just_pressed("ui_accept"):
		start_game()
	
	if new_best_timer > 0:
		new_best_timer -= _delta
		if new_best_timer <= 0:
			$UI/NewBestLabel.visible = false

func start_game():
	game_started = true
	$UI/StartScreen.visible = false
	$PipeTimer.start()
	$bee.active = true

func spawn_pipe():
	var pipe = pipe_scene.instantiate()
	var vp = get_viewport_rect().size
	pipe.position = Vector2(
		vp.x + 50,
		randf_range(vp.y * 0.3, vp.y * 0.7)
	)
	pipe.speed = 200 + (score * 5)
	pipe.scored.connect(_on_pipe_scored)
	get_tree().current_scene.add_child(pipe)
	
	var new_wait = max(0.8, $PipeTimer.wait_time - (score * 0.02))
	$PipeTimer.wait_time = new_wait

var new_best_flashed = false

func _on_pipe_scored():
	if game_over:
		return
	score += 1
	$UI/ScoreLabel.text = str(score)
	$score.play()
	
	if score > best_score and not new_best_flashed:
		new_best_flashed = true
		show_new_best_flash()

func show_new_best_flash():
	$UI/NewBestLabel.visible = true
	new_best_timer = 2.0

func show_game_over():
	if game_over:
		return
	game_over = true

	var is_new_best = false
	if score > best_score:
		best_score = score
		save_best_score()
		is_new_best = true

	$UI/BestLabel.text = "BEST: " + str(best_score)
	$UI/DimOverlay.visible = true

	$PipeTimer.stop()
	for pipe in get_tree().get_nodes_in_group("pipes"):
		pipe.set_process(false)

	$UI/GameOverScreen.position = Vector2(401, 174)
	$UI/GameOverScreen.size = Vector2(350, 300)

	$UI/GameOverScreen/PanelImage.texture = load("res://ui/scorepanell.png")
	$UI/GameOverScreen/PanelImage.position = Vector2(0, 0)
	$UI/GameOverScreen/PanelImage.size = Vector2(350, 300)
	$UI/GameOverScreen/PanelImage.stretch_mode = TextureRect.STRETCH_SCALE

	if is_new_best:
		$UI/GameOverScreen/ScoreNumber.text = str(score) + "\n\nNEW BEST!"
	else:
		$UI/GameOverScreen/ScoreNumber.text = str(score)

	$UI/GameOverScreen/ScoreNumber.add_theme_font_override("font", pixel_font)
	$UI/GameOverScreen/ScoreNumber.add_theme_font_size_override("font_size", 15)
	$UI/GameOverScreen/ScoreNumber.add_theme_color_override("font_color", Color(0.355, 0.161, 0.078, 1.0))
	$UI/GameOverScreen/ScoreNumber.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	$UI/GameOverScreen/ScoreNumber.add_theme_constant_override("outline_size", 2)
	$UI/GameOverScreen/ScoreNumber.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$UI/GameOverScreen/ScoreNumber.size = Vector2(350, 90)
	$UI/GameOverScreen/ScoreNumber.position = Vector2(0, 110)

	$UI/GameOverScreen/RestartButton.texture_normal = null
	$UI/GameOverScreen/RestartButton.position = Vector2(20, 225)
	$UI/GameOverScreen/RestartButton.size = Vector2(150, 60)

	$UI/GameOverScreen/ExitButton.texture_normal = null
	$UI/GameOverScreen/ExitButton.position = Vector2(180, 225)
	$UI/GameOverScreen/ExitButton.size = Vector2(150, 60)

	$UI/GameOverScreen.visible = true

func _on_restart():
	get_tree().reload_current_scene()

func _on_exit():
	get_tree().quit()
