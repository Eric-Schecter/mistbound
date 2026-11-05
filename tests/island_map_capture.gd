extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process_unhandled_input(false)
	game.open_islands()
	await create_timer(0.3).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://build/captures/preview-island-map.png")
	game.close_islands()
	game.level = 19
	game.load_level()
	game.won = true
	game.collected = 3
	await create_timer(0.2).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://build/captures/preview-victory-return.png")
	await game.sound.shutdown()
	quit()
