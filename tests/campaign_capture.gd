extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.set_process_unhandled_input(false)
	for level in range(6, 20):
		game.level = level
		game.load_level()
		await create_timer(0.12).timeout
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://build/captures/preview-campaign-%02d.png" % (level + 1))
	game.won = true
	game.collected = 3
	await create_timer(0.2).timeout
	RenderingServer.force_draw()
	root.get_texture().get_image().save_png("res://build/captures/preview-campaign-victory.png")
	await game.sound.shutdown()
	quit()
