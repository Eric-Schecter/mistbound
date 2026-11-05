extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func shot(path: String) -> void:
	await process_frame
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png(path)

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await create_timer(0.6).timeout
	await shot("res://build/captures/preview-ship-idle.png")
	game.dash(Vector2i.UP)
	await create_timer(0.7).timeout
	await shot("res://build/captures/preview-ship-sailing.png")
	while game.busy: await process_frame
	await create_timer(0.35).timeout
	await game.dash(Vector2i.RIGHT)
	await create_timer(0.35).timeout
	await game.dash(Vector2i.LEFT)
	await create_timer(0.7).timeout
	game.level = 1
	game.load_level()
	await create_timer(0.4).timeout
	await game.dash(Vector2i.LEFT)
	await game.dash(Vector2i.UP)
	await create_timer(0.8).timeout
	# One reef collision demonstrates recoil, spray, sail collapse and clean reset.
	game.level = 2
	game.load_level()
	game.board[game.player.y][game.player.x + 1] = "X"
	await game.dash(Vector2i.RIGHT)
	await create_timer(0.6).timeout
	print("PASS native animation capture")
	await game.sound.shutdown()
	quit()
