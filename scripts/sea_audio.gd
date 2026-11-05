extends Node

const BUS := "Mistbound"
const GLIDE_LEVEL_DB := -17.0
const GLIDE_PATH := "res://assets/audio/glide-elevenlabs-sustain.wav"
const LEVELS := {"chart": -16.0, "wood": -12.0, "impact": -11.0, "dock": -16.0, "ui": -23.0}
var game: Node2D
var clips: Dictionary = {}
var voices: Array[AudioStreamPlayer2D] = []
var music: AudioStreamPlayer
var music_gain := 0.0
var wake: AudioStreamPlayer
var glide_source: AudioStreamWAV
var muted := false
var suspended := false
var history: Array[String] = []
var cursor := 0
var water_level := -70.0
var water_gain := 0.0
var gliding := false
var rng := RandomNumberGenerator.new()

func setup(owner_game: Node2D) -> void:
	game = owner_game
	rng.seed = 710
	if AudioServer.get_bus_index(BUS) < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, BUS)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(BUS), 4.0)
	for name in LEVELS:
		clips[name] = load("res://assets/audio/%s.wav" % name)
	for i in range(12):
		var voice := AudioStreamPlayer2D.new()
		voice.bus = BUS
		voice.max_distance = 1800.0
		voice.attenuation = 0.5
		voice.panning_strength = 0.5
		add_child(voice)
		voices.append(voice)
	wake = AudioStreamPlayer.new()
	wake.bus = BUS
	glide_source = load(GLIDE_PATH)
	var sustain: AudioStreamWAV = glide_source.duplicate()
	sustain.loop_mode = AudioStreamWAV.LOOP_FORWARD
	sustain.loop_begin = 0
	sustain.loop_end = int(sustain.get_length() * sustain.mix_rate)
	wake.stream = sustain
	wake.volume_db = -70.0
	add_child(wake)
	var config := ConfigFile.new()
	if config.load("user://audio.cfg") == OK:
		muted = bool(config.get_value("audio", "muted", false))
	set_muted(muted, false)
	music = AudioStreamPlayer.new()
	music.bus = BUS
	var song: AudioStreamWAV = load("res://assets/audio/mistbound-harbor-bgm.wav").duplicate()
	song.loop_mode = AudioStreamWAV.LOOP_FORWARD
	song.loop_begin = 0
	song.loop_end = int(song.get_length() * song.mix_rate)
	music.stream = song
	music.volume_db = -70.0
	add_child(music)
	music.play()

func cue(name: String, position: Vector2, pitch := 1.0) -> void:
	if suspended or not clips.has(name): return
	history.append(name)
	if history.size() > 64: history.pop_front()
	var voice: AudioStreamPlayer2D
	for candidate in voices:
		if not candidate.playing:
			voice = candidate
			break
	if voice == null:
		voice = voices[cursor]
		cursor = (cursor + 1) % voices.size()
	voice.stop()
	voice.position = position
	voice.stream = clips[name]
	voice.volume_db = LEVELS[name]
	voice.pitch_scale = pitch if name in ["chart", "dock"] else pitch * rng.randf_range(0.96, 1.04)
	voice.stream_paused = false
	voice.play()

func begin_glide() -> void:
	if suspended: return
	history.append("glide")
	if history.size() > 64: history.pop_front()
	gliding = true
	water_gain = 0.0
	wake.volume_db = -70.0
	wake.pitch_scale = 1.0
	wake.play()

func end_glide() -> void:
	gliding = false

func update(delta: float) -> void:
	if suspended: return
	# A quiet bed, slightly lower during sailing so the water stays distinct.
	var music_target := db_to_linear(-27.0 if gliding else -24.0)
	music_gain = lerpf(music_gain, music_target, 1.0 - exp(-delta * 1.5))
	music.volume_db = linear_to_db(maxf(0.00001, music_gain))
	var target_gain := db_to_linear(GLIDE_LEVEL_DB) if gliding and wake.playing else 0.0
	water_gain = lerpf(water_gain, target_gain, 1.0 - exp(-delta * (35.0 if target_gain > water_gain else 48.0)))
	water_level = maxf(-70.0, linear_to_db(maxf(0.00001, water_gain)))
	wake.volume_db = water_level
	if not gliding and water_gain < 0.0001: wake.stop()

func set_paused(value: bool) -> void:
	suspended = value
	for voice in voices: voice.stream_paused = value
	wake.stream_paused = value
	music.stream_paused = value

func reset() -> void:
	for voice in voices:
		voice.stop()
		voice.stream_paused = false
	suspended = false
	music.stream_paused = false
	wake.stream_paused = false
	water_level = -70.0
	water_gain = 0.0
	gliding = false
	wake.stop()
	wake.volume_db = water_level

func set_muted(value: bool, persist := true) -> void:
	muted = value
	AudioServer.set_bus_mute(AudioServer.get_bus_index(BUS), value)
	if persist:
		var config := ConfigFile.new()
		config.set_value("audio", "muted", value)
		config.save("user://audio.cfg")

func toggle_mute() -> void:
	set_muted(not muted)
	if not muted: cue("ui", game.visual)

func _exit_tree() -> void:
	for voice in voices: voice.stop()
	if is_instance_valid(wake): wake.stop()
	if is_instance_valid(music): music.stop()

func shutdown() -> void:
	# AudioServer releases stopped playbacks asynchronously (Godot issue #76745).
	suspended = true
	music.stream_paused = false
	music.stop()
	for voice in voices:
		voice.stream_paused = false
		voice.stop()
	wake.stream_paused = false
	wake.stop()
	var until := Time.get_ticks_msec() + 160
	while Time.get_ticks_msec() < until:
		await get_tree().process_frame
