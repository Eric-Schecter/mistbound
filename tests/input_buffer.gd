extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.dash(Vector2i.UP)
	while game.ship_phase != "brake": await process_frame
	await create_timer(0.12).timeout
	game.request_dash(Vector2i.LEFT)
	game.request_dash(Vector2i.RIGHT)
	while game.moves == 1: await process_frame
	assert(game.moves == 2 and game.heading == Vector2.RIGHT, "Latest buffered direction must launch on arrival")
	while game.busy: await process_frame
	assert(game.moves == 2, "Buffer must execute once")
	game.request_dash(Vector2i.LEFT)
	assert(game.busy and game.moves == 3, "Settling must not lock input")
	game.load_level()
	assert(game.queued_direction == Vector2i.ZERO, "Reset clears buffer")
	await create_timer(0.3).timeout
	assert(not game.busy and game.moves == 0)
	print("PASS queued turn, latest input, single execution, immediate departure, reset")
	await game.sound.shutdown()
	quit()
