extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.sound.set_muted(false, false)
	await create_timer(4.0).timeout
	await game.dash(Vector2i.UP)
	await create_timer(2.0).timeout
	await game.dash(Vector2i.RIGHT)
	await create_timer(2.0).timeout
	await game.dash(Vector2i.LEFT)
	await create_timer(3.0).timeout
	await game.sound.shutdown()
	quit()
