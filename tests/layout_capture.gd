extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	for dimensions in [Vector2i(1100, 800), Vector2i(1440, 810)]:
		DisplayServer.window_set_size(dimensions)
		await create_timer(0.5).timeout
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://build/captures/preview-ui-%d.png" % dimensions.x)
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.pressed = true
		click.position = game.get_global_transform_with_canvas() * Vector2(646, 119)
		game._unhandled_input(click)
		assert(not game.paused, "Removed pause button must not have an active hit area")
		game.toggle_pause()
		assert(game.paused)
		game.toggle_pause()
	print("PASS standard/wide layouts and removed pause hit area and keyboard pause")
	await game.sound.shutdown()
	quit()
