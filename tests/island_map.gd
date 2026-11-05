extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.best.clear()
	game.best_moves.clear()
	assert(game.island_available(0) and not game.island_available(1))
	game.collected = 2
	game.moves = 9
	game.record_result(false)
	assert(game.island_available(1) and not game.island_available(2))
	game.collected = 3
	game.moves = 12
	game.record_result(false)
	game.moves = 10
	game.record_result(false)
	game.collected = 1
	game.moves = 2
	game.record_result(false)
	assert(game.best['0'] == 3 and game.best_moves['0'].moves == 10 and game.best_moves['0'].charts == 3)
	game.load_level()
	game.dash(Vector2i.UP)
	await create_timer(0.1).timeout
	game.open_islands()
	var position: Vector2 = game.visual
	await create_timer(0.2).timeout
	assert(game.visual == position and game.paused)
	game.choose_island(19)
	assert(game.level == 0 and game.selecting_island)
	game.choose_island(1)
	assert(game.level == 1 and not game.paused and not game.busy and not game.selecting_island)
	game.level = 19
	game.load_level()
	game.won = true
	var enter := InputEventKey.new()
	enter.pressed = true
	enter.keycode = KEY_ENTER
	game._unhandled_input(enter)
	assert(game.campaign_complete() and game.selecting_island)
	game.close_islands()
	assert(game.campaign_complete() and not game.paused)
	print("PASS unlocks, best-score retention, mid-voyage pause, replay, victory return")
	await game.sound.shutdown()
	quit()
