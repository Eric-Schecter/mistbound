extends SceneTree
var game: Node2D

func _initialize() -> void:
	call_deferred("run")

func check(value: bool, message: String) -> void:
	if not value:
		push_error(message)
		quit(1)

func run() -> void:
	game = load("res://main.tscn").instantiate()
	root.add_child(game)
	await process_frame
	var audio: Node = game.sound
	check(audio.clips.size() == 5 and not audio.wake.playing, "Only retained event cues load; glide stays silent until movement")
	check(audio.wake.stream.get_length() < 0.7 and audio.wake.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "Glide must use the short seamless sustain loop")
	check(audio.glide_source.resource_path == audio.GLIDE_PATH, "Runtime must use the new normalized ElevenLabs asset")
	for player in audio.get_children():
		check(player.stream == null or not player.stream.resource_path.ends_with("sea.wav"), "No legacy background noise may be loaded")
	check(audio.music.playing and audio.music.stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "BGM starts and loops")
	var original_mute: bool = audio.muted
	audio.set_muted(false, false)
	game.dash(Vector2i.UP)
	var loudest := -80.0
	while game.busy:
		await process_frame
		loudest = maxf(loudest, audio.water_level)
		check(is_equal_approx(audio.wake.pitch_scale, 1.0), "Sailing wash must stay at a fixed pitch")
	check(not audio.history.has("launch") and not audio.history.has("brake") and not audio.history.has("berth"), "Legacy synthesized travel layers must never trigger")
	check(loudest > -25 and loudest <= -17, "Wake must remain audible but below the gentler sailing ceiling")
	await create_timer(0.18).timeout
	check(not audio.wake.playing, "Glide must stop promptly after arrival")
	check(audio.history.count("glide") == 1, "One voyage must start the sustain player only once")
	game.load_level()
	game.dash(Vector2i.RIGHT)
	await create_timer(1.0).timeout
	check(game.busy and audio.gliding and audio.wake.playing, "Long voyage must sustain audio beyond the original 0.65s excerpt")
	while game.busy: await process_frame
	await create_timer(0.18).timeout
	check(not audio.wake.playing, "Sustained audio must release promptly when the long voyage ends")
	game.load_level()
	game.dash(Vector2i.RIGHT)
	await create_timer(0.27).timeout
	game.toggle_pause()
	check(audio.music.stream_paused, "Pause suspends BGM")
	check(audio.wake.stream_paused, "Pause must suspend the short glide")
	for voice in audio.voices: check(not voice.playing or voice.stream_paused, "Pause must suspend active event voices")
	var music_position: float = audio.music.get_playback_position()
	game.load_level()
	check(audio.music.playing and not audio.music.stream_paused and absf(audio.music.get_playback_position() - music_position) < 0.1, "Restart resumes BGM without restarting song")
	for voice in audio.voices: check(not voice.playing, "Restart must cancel old event audio")
	check(not audio.suspended and not audio.wake.stream_paused and audio.wake.volume_db == -70.0, "Restart must reset the wake mix")
	audio.set_muted(true, false)
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index(audio.BUS)), "Mute must silence the complete game bus")
	audio.set_muted(false, false)
	check(not AudioServer.is_bus_mute(AudioServer.get_bus_index(audio.BUS)), "Unmute must restore the bus")
	for event in ["wood", "impact", "dock", "chart"]:
		game.load_level()
		audio.history.clear()
		var next: Vector2i = game.player + Vector2i.RIGHT
		if event == "chart": game.stars.append(next)
		else: game.board[next.y][next.x] = {"wood": "B", "impact": "X", "dock": "G"}[event]
		await game.dash(Vector2i.RIGHT)
		check(audio.history.has(event), "Gameplay audio missing: " + event)
	game.level = 1
	game.load_level()
	game.player = Vector2i(1, 5)
	game.visual = game.center(game.player)
	game.ship.reset()
	audio.reset()
	audio.history.clear()
	await game.dash(Vector2i.UP)
	check(not audio.history.has("turn"), "Current steering must not reintroduce the legacy creak")
	audio.set_muted(original_mute, false)
	print("PASS clips, loops, speed mix, action cues, pause, restart and mute")
	await audio.shutdown()
	game.free()
	for i in range(3): await process_frame
	quit()
