extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var paths := ["user://archipelago_progress.json", "user://archipelago_records.json"]
	var backup := {}
	for path in paths:
		if FileAccess.file_exists(path): backup[path] = FileAccess.get_file_as_bytes(path)
	var game = load("res://main.tscn").instantiate()
	root.add_child(game)
	game.best_moves.clear()
	game.level = 0
	game.collected = 3
	game.moves = 8
	game.record_result()
	await game.sound.shutdown()
	game.free()
	var reloaded = load("res://main.tscn").instantiate()
	root.add_child(reloaded)
	var passed: bool = reloaded.best_moves['0'].moves == 8 and reloaded.best_moves['0'].charts == 3
	await reloaded.sound.shutdown()
	reloaded.free()
	for path in paths:
		if backup.has(path):
			var file := FileAccess.open(path, FileAccess.WRITE)
			file.store_buffer(backup[path])
		else: DirAccess.remove_absolute(path)
	assert(passed, "Records must survive a fresh game instance")
	print("PASS persisted score reload; original saves restored")
	quit()
