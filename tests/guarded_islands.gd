extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	for level in range(1, game.MAPS.size()):
		game.level = level
		game.load_level()
		var initial: Vector2i = game.player
		await create_timer(0.3).timeout
		assert(game.player == initial and game.moves == 0 and game.sentry_shot.is_empty(), "Thinking must be untimed")
		var cell: Vector2i = game.pirates[0]
		var facing: Vector2i = game.pirate_heading(cell)
		var lane: Array[Vector2i] = game.firing_cells(cell)
		assert(not lane.is_empty() and not lane.has(initial))
		game.player = lane[0] + facing
		game.visual = game.center(game.player)
		await game.dash(-facing)
		assert(game.moves == 0 and game.player == initial, "Entering guarded lane must reset")
		game.board[cell.y + facing.y][cell.x + facing.x] = "B"
		assert(game.firing_cells(cell).is_empty(), "Wood must block line of fire")
		game.load_level()
		game.pirates.clear()
		assert(game.sentry_at(lane[0]) == Vector2i(-1,-1), "Destroying lookout must clear fire")
	print("PASS all guarded islands: threat, safe spawn, untimed thinking, cover, cleared firing lanes")
	await game.sound.shutdown()
	quit()
