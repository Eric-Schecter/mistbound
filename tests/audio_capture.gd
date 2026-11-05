extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.sound.set_muted(false, false)
	await create_timer(0.6).timeout
	await game.dash(Vector2i.UP)
	await game.dash(Vector2i.RIGHT)
	await game.dash(Vector2i.DOWN)
	await create_timer(1.6).timeout
	game.level = 1
	game.load_level()
	await game.dash(Vector2i.LEFT)
	await game.dash(Vector2i.UP)
	await create_timer(0.3).timeout
	game.load_level()
	game.board[game.player.y][game.player.x + 1] = "B"
	await game.dash(Vector2i.RIGHT)
	await create_timer(0.4).timeout
	game.board[game.player.y][game.player.x + 1] = "X"
	await game.dash(Vector2i.RIGHT)
	await create_timer(0.8).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://build/captures/preview-audio.png")
	print("PASS native sound capture")
	await game.sound.shutdown()
	quit()
