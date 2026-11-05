extends SceneTree

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for index in [0, 3, 5]:
		game.level = index
		game.load_level()
		await create_timer(0.2).timeout
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://build/captures/preview-island-%d.png" % (index + 1))
	print("PASS captured islands 1, 4, 6")
	await game.sound.shutdown()
	quit()
