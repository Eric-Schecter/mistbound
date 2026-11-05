extends SceneTree
const ROUTES := ["^><v>v>^", "<^", "v<^^v^><", "^><v>>v><", "><v<>^<^<^", "<^><>^><^>", "v<^v>^<<", "v>^v<^>v<^^", ">v^>v<vv<^>", "<>^<>^<>^<<<^", "^v<^<^<v>v<^>", "<>^<^<vv>><^>v<", "<v>^v<<<^>^v<<^<^", "<^<<^v<^>>^>>v<", ">>>><v^<v^>vv>^>^", "^v>^<^<v^>v<v>v>v", "v<^<v^^<^>vv<v>vv", "<v>>^vv<^<v><v>v><<", "v<>^<^^<vv<v<v<^^v<>^", "^<v>^v<<^>>^<>^<^><>v"]

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	DirAccess.make_dir_recursive_absolute("res://build/captures")
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	for level in range(ROUTES.size()):
		game.level = level
		var baseline: Array[Vector2i] = []
		for with_pirates in [false, true]:
			game.load_level()
			for cell in game.pirates: assert(game.tile(cell) == ".", "Pirates must not overlap puzzle objects")
			if not with_pirates: game.pirates.clear()
			var step := 0
			for symbol in ROUTES[level]:
				await game.dash(game.CURRENTS[symbol])
				if not with_pirates: baseline.append(game.player)
				else: assert(game.player == baseline[step], "Pirates must preserve every stopping point")
				step += 1
			assert(game.won and game.collected == 3)
			if with_pirates:
				assert(game.pirates_sunk == game.PIRATE_CELLS[level].size(), "All placed pirates must be reachable")
		game.load_level()
		assert(game.pirates.size() == game.PIRATE_CELLS[level].size() and game.sinking_pirates.is_empty() and game.pirates_sunk == 0)
	print("PASS all campaign routes validated, all pirates reachable, reset restores pirates")
	game.level = 1
	game.load_level()
	if DisplayServer.get_name() != "headless":
		await create_timer(0.3).timeout
		RenderingServer.force_draw()
		root.get_texture().get_image().save_png("res://build/captures/preview-pirates.png")
	await game.sound.shutdown()
	quit()
