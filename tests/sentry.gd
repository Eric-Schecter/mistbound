extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.level = 1
	game.load_level()
	await game.dash(Vector2i.UP)
	assert(game.moves == 0 and game.player == Vector2i(6, 6) and game.pirates.size() == 1, "Frontal approach must fail and restore level")
	await game.dash(Vector2i.LEFT)
	await game.dash(Vector2i.UP)
	assert(game.won and game.collected == 3 and game.pirates_sunk == 1, "Both currents must guide a safe flanking route")
	assert(game.sentry_at(Vector2i(6, 5)) == Vector2i(-1,-1), "Sinking sentry removes its firing lane")
	print("PASS frontal danger, flanking kill, both currents and complete collection")
	await game.sound.shutdown()
	quit()
