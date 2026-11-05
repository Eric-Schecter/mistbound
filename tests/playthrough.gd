extends SceneTree

const ROUTES := ["^><v>v>^", "<^", "v<^^v^><", "^><v>>v><", "><v<>^<^<^", "<^><>^><^>", "v<^v>^<<", "v>^v<^>v<^^", ">v^>v<vv<^>", "<>^<>^<>^<<<^", "^v<^<^<v>v<^>", "<>^<^<vv>><^>v<", "<v>^v<<<^>^v<<^<^", "<^<<^v<^>>^>>v<", ">>>><v^<v^>vv>^>^", "^v>^<^<v^>v<v>v>v", "v<^<v^^<^>vv<v>vv", "<v>>^vv<^<v><v>v><<", "v<>^<^^<vv<v<v<^^v<>^", "^<v>^v<<^>>^<>^<^><>v"]
var game: Node

func _initialize() -> void:
	call_deferred("run")

func require(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for index in range(ROUTES.size()):
		game.level = index
		game.load_level()
		for symbol in ROUTES[index]:
			await game.dash(game.CURRENTS[symbol])
		require(game.won and game.collected == 3, "Three-chart completion failed: %d" % index)
		print("PASS island %d: %d voyages, 3 charts" % [index + 1, game.moves])
	require(game.campaign_complete(), "Last island must end the campaign")
	for code in [KEY_R, KEY_ESCAPE]:
		var key := InputEventKey.new()
		key.pressed = true
		key.keycode = code
		game._unhandled_input(key)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(550, 450)
	game._unhandled_input(click)
	var touch := InputEventScreenTouch.new()
	touch.pressed = true
	touch.position = Vector2(550, 450)
	game._unhandled_input(touch)
	require(game.level == 19 and game.campaign_complete() and not game.paused, "Victory screen must not restart on keyboard, click or touch")
	var enter := InputEventKey.new()
	enter.pressed = true
	enter.keycode = KEY_ENTER
	game._unhandled_input(enter)
	require(game.selecting_island and game.level == 19, "Enter opens islands without replaying")
	game.close_islands()
	print("PASS final victory and explicit return to islands")
	game.level = 0
	game.load_level()
	var old_position: Vector2 = game.visual
	game.dash(Vector2i.UP)
	await create_timer(0.30).timeout
	game.toggle_pause()
	var stopped: Vector2 = game.visual
	await create_timer(0.20).timeout
	require(game.visual == stopped and stopped != old_position, "Pause must freeze an active voyage")
	game.load_level()
	var reset_position: Vector2 = game.visual
	await create_timer(0.25).timeout
	require(game.visual == reset_position and not game.busy and game.moves == 0, "Restart must cancel old voyage")
	game.board[game.player.y][game.player.x + 1] = "X"
	await game.dash(Vector2i.RIGHT)
	require(game.moves == 0 and not game.busy and not game.won, "Reef must reset voyage")
	var stored = JSON.parse_string(FileAccess.get_file_as_string("user://archipelago_progress.json"))
	require(stored is Dictionary and stored.size() >= ROUTES.size(), "All campaign best scores must be persisted")
	print("PASS pause, restart cancellation, reef reset and save")
	await game.sound.shutdown()
	quit()
