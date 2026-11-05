extends SceneTree

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var game: Node2D = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	game.sound.set_muted(false, false)
	game.status = "短程航行 · 停船时水声收尾"
	await create_timer(0.6).timeout
	await game.dash(Vector2i.UP)
	await create_timer(0.5).timeout
	game.status = "长程航行 · 水声持续到停船"
	await game.dash(Vector2i.RIGHT)
	await create_timer(0.5).timeout
	game.status = "长程返航 · 同样的水声随航程延续"
	await game.dash(Vector2i.LEFT)
	await create_timer(0.6).timeout
	await game.sound.shutdown()
	print("PASS short/long glide capture")
	quit()
