extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.level = 1
	game.load_level()
	await create_timer(1.0).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://build/captures/preview-pirates.png")
	await game.dash(Vector2i.LEFT)
	game.dash(Vector2i.UP)
	while game.sinking_pirates.is_empty(): await process_frame
	await create_timer(0.23).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://build/captures/preview-pirate-impact.png")
	while game.busy: await process_frame
	await create_timer(0.7).timeout
	assert(game.pirates_sunk == 1 and game.player == Vector2i(9, 6))
	print("PASS native pirate collision continues to shore")
	await game.sound.shutdown()
	quit()
