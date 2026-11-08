extends Node2D

const GAME_TIME := 30.0

var player: Player
var coin: Coin
var score := 0
var time_left := GAME_TIME
var playing := true
var score_label: Label
var time_label: Label
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	player = Player.new()
	player.position = Vector2(400, 300)
	add_child(player)
	_spawn_coin()
	var layer := CanvasLayer.new()
	add_child(layer)
	score_label = Label.new()
	score_label.position = Vector2(16, 10)
	score_label.add_theme_font_size_override("font_size", 28)
	layer.add_child(score_label)
	time_label = Label.new()
	time_label.position = Vector2(16, 44)
	time_label.add_theme_font_size_override("font_size", 20)
	layer.add_child(time_label)
	_update_hud()
	print("GAME_START coins_target=score, time_limit=", GAME_TIME)
	if "--auto-test" in OS.get_cmdline_user_args():
		_run_auto_test()

func _process(delta: float) -> void:
	if not playing:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		playing = false
		print("GAME_OVER final_score=", score)
	_update_hud()

func _update_hud() -> void:
	score_label.text = "Score: %d" % score
	time_label.text = "Time: %.0f" % ceil(time_left)

func _spawn_coin() -> void:
	coin = Coin.new()
	coin.position = Vector2(rng.randf_range(60, 740), rng.randf_range(60, 540))
	coin.body_entered.connect(_on_coin_body_entered)
	add_child(coin)
	print("COIN_SPAWN pos=", coin.position)

func _on_coin_body_entered(body: Node2D) -> void:
	if not playing:
		return
	if body.is_in_group("player"):
		score += 1
		print("COIN_COLLECTED score=", score)
		coin.queue_free()
		_spawn_coin()
		_update_hud()

func _run_auto_test() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame
	# Test 1: teleport onto the coin -> collection must fire
	player.position = coin.position
	for i in range(5):
		await get_tree().physics_frame
	if score != 1:
		print("TEST_FAIL collect score=", score)
		get_tree().quit(1)
		return
	print("TEST_PASS collect score=1")
	# Test 2: hold right for 30 physics frames -> player must move right
	var x0 := player.position.x
	Input.action_press("ui_right")
	for i in range(30):
		await get_tree().physics_frame
	Input.action_release("ui_right")
	var moved := player.position.x - x0
	if moved < 50.0:
		print("TEST_FAIL move moved=", moved)
		get_tree().quit(1)
		return
	print("TEST_PASS move dx=", snappedf(moved, 0.1))
	print("TEST_ALL_PASS score=", score)
	get_tree().quit(0)
