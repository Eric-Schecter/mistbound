extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	for level in range(2,6):
		game.level = level
		game.load_level()
		await create_timer(0.2).timeout
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://build/captures/preview-guarded-%d.png" % (level + 1))
	await game.sound.shutdown()
	quit()
