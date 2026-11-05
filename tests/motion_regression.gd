extends SceneTree
var game: Node2D

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
	var start: Vector2 = game.visual
	game.dash(Vector2i.UP)
	require(game.busy, "Launch must start immediately")
	await create_timer(0.10).timeout
	require(game.visual != start, "Ship must move while sails fill")
	game.toggle_pause()
	var cloth: float = game.sail_power
	var turn: float = game.ship.angle
	var clock: float = game.clock
	await create_timer(0.20).timeout
	require(game.sail_power == cloth and game.ship.angle == turn and game.clock == clock, "Pause must freeze cloth, steering and world time")
	game.toggle_pause()
	while game.busy: await process_frame
	require(game.ship_phase == "settle", "Arrival releases input before settling")
	await create_timer(0.18).timeout
	require(game.ship_phase == "idle" and is_equal_approx(game.sail_power, 0.32), "Arrival must settle and reef sails")
	require(not game.ship.wake.is_empty(), "Movement must emit persistent wake")
	await create_timer(1.7).timeout
	require(game.ship.wake.is_empty(), "Wake must decay after arrival")
	game.load_level()
	game.dash(Vector2i.UP)
	await create_timer(0.05).timeout
	game.load_level()
	var reset: Vector2 = game.visual
	await create_timer(0.4).timeout
	require(game.visual == reset and game.ship_phase == "idle" and is_equal_approx(game.sail_power, 0.32), "Restart must cancel anticipation and all old pose changes")
	print("PASS launch anticipation, cloth, pause, arrival, wake decay, reset cancellation")
	await game.sound.shutdown()
	quit()
