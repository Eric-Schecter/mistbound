extends Node2D

const CELL := 58.0
const ORIGIN := Vector2(202, 160)
const MAPS := [
	["############", "#.........*#", "#.#........#", "#*.....#..G#", "##..P......#", "#.........*#", "##.........#", "#..........#", "############"],
	["############", "##X#########", "##>..*...vX#", "##.###.##.##", "##*###.##*##", "##.###.##.##", "##....P..G##", "############", "############"],
	["############", "#....#....X#", "#...G....*.#", "#...<.#.P..#", "#>..*.#.*..#", "##.X.......#", "#......#...#", "#..#.......#", "############"],
	["############", "#..#...*...#", "#..X.##..#.#", "#.#.....P#.#", "#........*v#", "#..#....B..#", "#B..*......#", "#....^X..G.#", "############"],
	["############", "#.#v..#..G.#", "#...#......#", "##.B#....*.#", "#.X....#...#", "#....#..P..#", "#B.>..*..^.#", "#..*...#.X.#", "############"],
	["############", "#>....v##..#", "#.B......#.#", "#.#...P.X..#", "#..Xv...G..#", "#.#..##..B.#", "#.......*.*#", "#...*..#..##", "############"],
	["############", "#*#.#.v..#.#", "#.#...G..#.#", "#....X..^.B#", "#*.X.##B...#", "#...#..#...#", "#*.....P#..#", "#.........##", "############"],
	["############", "#.#.G#.##..#", "###.....P*.#", "##.X*..#.X.#", "#.#.B..#...#", "#B....#.#..#", "#.#..*.#...#", "##.#B......#", "############"],
	["############", "#..#PB.....#", "#.>v..#....#", "#.......XG##", "##**...B.*.#", "#.#..####..#", "#.#.#.....X#", "##.......^.#", "############"],
	["############", "#G#..v...*.#", "#..P*.#.#.B#", "#.#*......##", "#........#.#", "#.^...#.#..#", "#.#..##..#.#", "#..X..X..#.#", "############"],
	["############", "#..#.##X.X.#", "#......##..#", "#*>.....*..#", "#..#..#..#.#", "#...#...G..#", "#.^B##.#..P#", "###.##..*..#", "############"],
	["############", "##..*.#XBB.#", "#.>.#......#", "#.*..*.....#", "#.X....##..#", "#....##....#", "##.......P##", "#.G.^.#...##", "############"],
	["############", "#G.#*..X#..#", "#....B..#..#", "#.#..#....B#", "#.#.B.#.P..#", "##........##", "#.....X..#*#", "#>.*.^.....#", "############"],
	["############", "#.v..B.....#", "#...#X..v..#", "#**.#.##.###", "#.#BB..#G.##", "#..*..#....#", "#..#.##..###", "#X.#^.P.X..#", "############"],
	["############", "#....#..*B.#", "#P....B^..G#", "#...*#.##..#", "#.#.....*..#", "#.#.<.<#...#", "#...X..#...#", "#.X...B##.X#", "############"],
	["############", "#........#.#", "#.#........#", "#...*...##.#", "#.#..#*..X.#", "#.#>^#B...G#", "#...X.....##", "#.X..P..*#.#", "############"],
	["############", "#.....P....#", "#.X..#*.#.<#", "#..#X..B.*##", "#..*.#.X.^##", "###B<....#.#", "##.........#", "#..G#..#...#", "############"],
	["############", "#.#..*.X...#", "#.......#..#", "#..#...G*###", "##.>...#^..#", "#.......*P^#", "#.#...B#.B.#", "#..B#..X..X#", "############"],
	["############", "#..G..#...*#", "##>.#X.B.X.#", "#...#>.....#", "##*...#.X.##", "#*..#.....P#", "#>.#...#...#", "#....#.....#", "############"],
	["############", "#..###..vX.#", "#^.......*##", "##.#.......#", "#.....^#.X.#", "#......X.#.#", "#.G#.....*P#", "#.B...#.B*##", "############"]
]
const NAMES := ["First Light Bay", "With the Current", "Hidden Reefs", "Driftwood Strait", "Turning Tides", "Distant Lights", "Amber Shoals", "Lookout Cove", "Broken Passage", "Crosswind Reach", "Smuggler Bay", "Coral Channels", "Whispering Tide", "Twin Lookouts", "Copper Coast", "Splitwater Sound", "Sentinel Strait", "Stormglass Isles", "Last Watch", "Homeward Light"]
const CURRENTS := {">": Vector2i.RIGHT, "<": Vector2i.LEFT, "^": Vector2i.UP, "v": Vector2i.DOWN}
const HINTS := ["Sail until the shore. Collect 3 chart pieces and reach the lighthouse.", "Follow the currents: teal arrows turn your boat as you pass.", "Flank the lookout before using its guarded channel. Avoid the reefs.", "Clear driftwood and flank the lookout. Wood blocks its firing lane.", "Clear the lookout before riding the currents through the islands.", "Plan your turns, flank the lookout, and bring every chart piece home.", "Read the red firing lanes before setting sail. Every current offers a route.", "Read the red firing lanes before setting sail. Every current offers a route.", "Read the red firing lanes before setting sail. Every current offers a route.", "Read the red firing lanes before setting sail. Every current offers a route.", "Read the red firing lanes before setting sail. Every current offers a route.", "Read the red firing lanes before setting sail. Every current offers a route.", "Read the red firing lanes before setting sail. Every current offers a route.", "Two lookouts guard these waters. Clear their firing lanes one at a time.", "Two lookouts guard these waters. Clear their firing lanes one at a time.", "Two lookouts guard these waters. Clear their firing lanes one at a time.", "Two lookouts guard these waters. Clear their firing lanes one at a time.", "Two lookouts guard these waters. Clear their firing lanes one at a time.", "Two lookouts guard these waters. Clear their firing lanes one at a time.", "Two lookouts guard these waters. Clear their firing lanes one at a time."]
const CLOSE_RECT := Rect2(870, 110, 85, 36)
var close_hovered := false
var level := 0
var board: Array = []
const PIRATE_CELLS := [[], [Vector2i(6, 2)], [Vector2i(1, 2)], [Vector2i(10, 1)], [Vector2i(9, 5)], [Vector2i(3, 1)], [Vector2i(4, 7)], [Vector2i(10, 3)], [Vector2i(4, 5)], [Vector2i(1, 2)], [Vector2i(10, 3)], [Vector2i(4, 6)], [Vector2i(7, 6)], [Vector2i(3, 1), Vector2i(1, 4)], [Vector2i(10, 1), Vector2i(1, 7)], [Vector2i(1, 3), Vector2i(5, 6)], [Vector2i(1, 2), Vector2i(4, 6)], [Vector2i(5, 2), Vector2i(7, 2)], [Vector2i(6, 7), Vector2i(7, 5)], [Vector2i(7, 7), Vector2i(5, 2)]]
const PIRATE_HEADINGS := [[], [Vector2i(0, 1)], [Vector2i(1, 0)], [Vector2i(0, 1)], [Vector2i(0, 1)], [Vector2i(-1, 0)], [Vector2i(0, -1)], [Vector2i(0, -1)], [Vector2i(-1, 0)], [Vector2i(0, 1)], [Vector2i(-1, 0)], [Vector2i(0, 1)], [Vector2i(1, 0)], [Vector2i(-1, 0), Vector2i(0, -1)], [Vector2i(0, 1), Vector2i(1, 0)], [Vector2i(1, 0), Vector2i(1, 0)], [Vector2i(0, -1), Vector2i(-1, 0)], [Vector2i(1, 0), Vector2i(0, 1)], [Vector2i(0, -1), Vector2i(0, -1)], [Vector2i(0, -1), Vector2i(1, 0)]]
var pirates: Array[Vector2i] = []
var sinking_pirates: Array[Dictionary] = []
var pirates_sunk := 0
var sentry_shot: Dictionary = {}
var player := Vector2i.ZERO
var visual := Vector2.ZERO
var stars: Array[Vector2i] = []
var moves := 0
var collected := 0
var busy := false
var won := false
var paused := false
var clock := 0.0
var trail: Array[Vector2] = []
var swipe_start := Vector2.ZERO
var best: Dictionary = {}
var best_moves: Dictionary = {}
var selecting_island := false
var selection_index := 0
var map_was_paused := false
var status := ""
var generation := 0
var font: Font
var active_tween: Tween
var settle_tween: Tween
var queued_direction := Vector2i.ZERO
var queued_at := -1.0
var heading := Vector2.RIGHT
var gesture := false
var renderer: RefCounted
var ship: RefCounted
var ship_phase := "idle"
var sail_power := 0.32
var sound: Node

func _ready() -> void:
	get_tree().auto_accept_quit = false
	DisplayServer.window_set_title("Mistbound · Harbor Voyage")
	font = ThemeDB.fallback_font
	if DisplayServer.get_name() != "headless":
		var system_font := SystemFont.new()
		system_font.font_names = PackedStringArray(["Arial Unicode MS", "PingFang SC", "Noto Sans CJK SC", "Arial"])
		font = system_font
	if FileAccess.file_exists("user://archipelago_progress.json"):
		var data = JSON.parse_string(FileAccess.get_file_as_string("user://archipelago_progress.json"))
		if data is Dictionary:
			best = data
	if FileAccess.file_exists("user://archipelago_records.json"):
		var records = JSON.parse_string(FileAccess.get_file_as_string("user://archipelago_records.json"))
		if records is Dictionary: best_moves = records
	ship = preload("res://scripts/ship_rig.gd").new(self)
	renderer = preload("res://scripts/sea_renderer.gd").new(self)
	sound = preload("res://scripts/sea_audio.gd").new()
	add_child(sound)
	sound.setup(self)
	load_level()

func load_level() -> void:
	selecting_island = false
	generation += 1
	queued_direction = Vector2i.ZERO
	if settle_tween and settle_tween.is_valid(): settle_tween.kill()
	if active_tween and active_tween.is_valid(): active_tween.kill()
	board.clear()
	stars.clear()
	pirates.assign(PIRATE_CELLS[level])
	sinking_pirates.clear()
	sentry_shot.clear()
	pirates_sunk = 0
	trail.clear()
	for y in range(MAPS[level].size()):
		board.append(MAPS[level][y].split(""))
		for x in range(board[y].size()):
			if board[y][x] == "P": player = Vector2i(x, y)
			if board[y][x] == "*": stars.append(Vector2i(x, y))
	visual = center(player)
	moves = 0
	collected = 0
	busy = false
	won = false
	paused = false
	status = "Avoid the red firing lane. Ride both currents to ram the sentry from the side." if level == 1 else HINTS[level]
	heading = Vector2.RIGHT
	ship_phase = "idle"
	sail_power = 0.32
	if ship: ship.reset()
	if sound: sound.reset()

func center(p: Vector2i) -> Vector2:
	return ORIGIN + Vector2(p) * CELL + Vector2.ONE * CELL / 2

func pirate_heading(cell: Vector2i) -> Vector2i:
	return PIRATE_HEADINGS[level][PIRATE_CELLS[level].find(cell)]

func firing_cells(cell: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var facing := pirate_heading(cell)
	for distance in range(1, 4):
		var target := cell + facing * distance
		if tile(target) in ["#", "B"]: break
		cells.append(target)
	return cells

func sentry_at(p: Vector2i) -> Vector2i:
	for cell in pirates:
		if firing_cells(cell).has(p): return cell
	return Vector2i(-1, -1)

func tile(p: Vector2i) -> String:
	if p.y < 0 or p.y >= board.size() or p.x < 0 or p.x >= board[0].size(): return "#"
	return board[p.y][p.x]

func _process(delta: float) -> void:
	if not paused:
		clock += delta
		if not sentry_shot.is_empty(): sentry_shot.age += delta
		for wreck in sinking_pirates: wreck.age += delta
		sinking_pirates = sinking_pirates.filter(func(wreck: Dictionary) -> bool: return wreck.age < 1.15)
	if ship: ship.update(delta)
	if sound: sound.update(delta)
	if renderer: renderer.update_water(clock)
	queue_redraw()

func campaign_complete() -> bool:
	return won and level == MAPS.size() - 1

func advance_level() -> void:
	if won and level < MAPS.size() - 1:
		level += 1
		load_level()

func island_available(index: int) -> bool:
	return index == 0 or best.has(str(index)) or best.has(str(index - 1))

func island_card(index: int) -> Rect2:
	return Rect2(150 + (index % 5) * 160, 190 + (index / 5) * 125, 150, 110)

func open_islands() -> void:
	if selecting_island: return
	map_was_paused = paused
	if not paused: toggle_pause()
	selecting_island = true
	close_hovered = false
	selection_index = level
	gesture = false

func close_islands() -> void:
	selecting_island = false
	close_hovered = false
	if not map_was_paused and paused: toggle_pause(false)
	sound.menu_cue(false)

func choose_island(index: int) -> void:
	if index < 0 or index >= MAPS.size() or not island_available(index): return
	level = index
	load_level()

func record_result(persist := true) -> void:
	var key := str(level)
	best[key] = maxi(int(best.get(key, 0)), collected)
	var previous: Dictionary = best_moves.get(key, {})
	if previous.is_empty() or collected > int(previous.get("charts", -1)) or (collected == int(previous.get("charts", -1)) and moves < int(previous.get("moves", 99999))):
		best_moves[key] = {"charts": collected, "moves": moves}
	if not persist: return
	var progress := FileAccess.open("user://archipelago_progress.json", FileAccess.WRITE)
	if progress: progress.store_string(JSON.stringify(best))
	var records := FileAccess.open("user://archipelago_records.json", FileAccess.WRITE)
	if records: records.store_string(JSON.stringify(best_moves))

func _unhandled_input(event: InputEvent) -> void:
	if selecting_island:
		if event is InputEventMouseMotion:
			var hovering := CLOSE_RECT.has_point(get_global_transform_with_canvas().affine_inverse() * event.position)
			if hovering and not close_hovered: sound.menu_cue(true)
			close_hovered = hovering
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_ESCAPE, KEY_TAB: close_islands()
				KEY_LEFT: selection_index = maxi(0, selection_index - 1)
				KEY_RIGHT: selection_index = mini(MAPS.size() - 1, selection_index + 1)
				KEY_UP: selection_index = maxi(0, selection_index - 5)
				KEY_DOWN: selection_index = mini(MAPS.size() - 1, selection_index + 5)
				KEY_ENTER, KEY_SPACE: choose_island(selection_index)
		elif (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
			if event is InputEventMouseButton and event.button_index != MOUSE_BUTTON_LEFT: return
			var pointer: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
			if CLOSE_RECT.has_point(pointer): close_islands()
			else:
				for index in range(MAPS.size()):
					if island_card(index).has_point(pointer): choose_island(index); break
		return
	if campaign_complete():
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_M: sound.toggle_mute()
			elif event.keycode in [KEY_ENTER, KEY_SPACE, KEY_TAB]: open_islands()
		elif (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
			var pointer: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
			if Rect2(704, 102, 106, 34).has_point(pointer): sound.toggle_mute()
			elif Rect2(430, 490, 240, 44).has_point(pointer) or Rect2(605, 102, 86, 34).has_point(pointer): open_islands()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_TAB: open_islands()
			KEY_M: sound.toggle_mute()
			KEY_R: load_level()
			KEY_ESCAPE: toggle_pause()
			KEY_ENTER, KEY_SPACE:
				if won: advance_level()
			KEY_LEFT, KEY_A: request_dash(Vector2i.LEFT)
			KEY_RIGHT, KEY_D: request_dash(Vector2i.RIGHT)
			KEY_UP, KEY_W: request_dash(Vector2i.UP)
			KEY_DOWN, KEY_S: request_dash(Vector2i.DOWN)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			gesture = false
			swipe_start = event.position
			var local_pointer: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
			if Rect2(830, 102, 68, 34).has_point(local_pointer) and not (won and collected == 3): load_level()
			elif Rect2(704, 102, 106, 34).has_point(local_pointer): sound.toggle_mute()
			elif Rect2(605, 102, 86, 34).has_point(local_pointer): open_islands()
			elif won: advance_level()
			else: gesture = true
		else:
			if not gesture: return
			gesture = false
			var offset: Vector2 = event.position - swipe_start
			if offset.length() > 28:
				request_dash(Vector2i(signi(int(offset.x)), 0) if absf(offset.x) > absf(offset.y) else Vector2i(0, signi(int(offset.y))))
	if event is InputEventScreenTouch:
		# Share button hit testing and swipe ownership with the mouse path.
		var mouse := InputEventMouseButton.new()
		mouse.button_index = MOUSE_BUTTON_LEFT
		mouse.pressed = event.pressed
		mouse.position = event.position
		_unhandled_input(mouse)

func toggle_pause(feedback := true) -> void:
	paused = not paused
	sound.set_paused(paused)
	queued_direction = Vector2i.ZERO
	if settle_tween and settle_tween.is_valid():
		if paused: settle_tween.pause()
		else: settle_tween.play()
	if not paused and feedback: sound.cue("ui", visual)
	if active_tween and active_tween.is_valid():
		if paused: active_tween.pause()
		else: active_tween.play()

func request_dash(direction: Vector2i) -> void:
	if paused or won: return
	if busy:
		if ship_phase == "brake":
			queued_direction = direction
			queued_at = clock
		return
	dash(direction)

func dash(direction: Vector2i) -> void:
	if busy or won or paused or tile(player + direction) == "#": return
	if settle_tween and settle_tween.is_valid(): settle_tween.kill()
	queued_direction = Vector2i.ZERO
	busy = true
	moves += 1
	var token := generation
	var visited := {}
	heading = Vector2(direction)
	var first_leg := true
	while tile(player + direction) != "#":
		var state := Vector4i(player.x, player.y, direction.x, direction.y)
		if visited.has(state):
			status = "Anchored in a looping current. Choose a new heading."
			break
		visited[state] = true
		heading = Vector2(direction)
		var next := player + direction
		if tile(next) == "B":
			board[next.y][next.x] = "."
			status = "Driftwood cleared. The way is open for your next move."
			ship.burst("wood", center(next))
			sound.cue("wood", center(next))
			break
		trail.append(visual)
		if trail.size() > 16: trail.pop_front()
		if first_leg: sound.begin_glide()
		var approaching: bool = tile(next + direction) in ["#", "B"] and not CURRENTS.has(tile(next))
		ship_phase = "brake" if approaching else "sail"
		active_tween = create_tween()
		var duration := 0.26 if approaching else (0.23 if first_leg else 0.145)
		var motion := active_tween.tween_property(self, "visual", center(next), duration)
		if approaching:
			motion.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			active_tween.parallel().tween_property(self, "sail_power", 0.35, duration)
		elif first_leg:
			motion.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			active_tween.parallel().tween_property(self, "sail_power", 1.0, duration)
		first_leg = false
		await active_tween.finished
		if token != generation: return
		player = next
		if pirates.has(player):
			pirates.erase(player)
			pirates_sunk += 1
			sinking_pirates.append({"cell": player, "age": 0.0, "direction": Vector2(direction)})
			ship.burst("wood", visual)
			ship.burst("splash", visual)
			sound.cue("wood", visual, 0.85)
			status = "Pirate boat sunk! Keep sailing."
		if stars.has(player):
			stars.erase(player)
			collected += 1
			ship.burst("chart", visual)
			sound.cue("chart", visual, 1.0 + (collected - 1) * 0.08)
		if tile(player) == "X" or sentry_at(player) != Vector2i(-1, -1):
			var shot := sentry_at(player) != Vector2i(-1, -1)
			if shot: sentry_shot = {"from": center(sentry_at(player)), "to": visual, "age": 0.0}
			status = "Caught in the sentry's firing lane! Try the currents." if shot else "Reef ahead! Restarting the voyage..."
			sound.end_glide()
			ship_phase = "impact"
			sail_power = 0.12
			ship.burst("impact", visual + heading * 17)
			sound.cue("impact", visual)
			var wait := 0.0
			while wait < 0.55:
				await get_tree().process_frame
				if token != generation: return
				if not paused: wait += get_process_delta_time()
			if token == generation: load_level()
			return
		if tile(player) == "G":
			sound.end_glide()
			ship_phase = "dock"
			ship.burst("dock", visual)
			sound.cue("dock", visual)
			active_tween = create_tween()
			active_tween.tween_property(self, "sail_power", 0.18, 0.32).set_trans(Tween.TRANS_SINE)
			await active_tween.finished
			if token != generation: return
			won = true
			record_result()
			break
		if CURRENTS.has(tile(player)):
			var new_direction: Vector2i = CURRENTS[tile(player)]
			if new_direction != direction:
				direction = new_direction
				heading = Vector2(direction)
				ship_phase = "turn"
				ship.burst("turn", visual)
				active_tween = create_tween()
				active_tween.tween_property(self, "sail_power", 0.72, 0.16)
				await active_tween.finished
				if token != generation: return
				sail_power = 1.0
	sound.end_glide()
	busy = false
	trail.clear()
	if not won:
		ship_phase = "settle"
		settle_tween = create_tween()
		settle_tween.tween_property(self, "sail_power", 0.32, 0.15)
		settle_tween.tween_callback(func(): ship_phase = "idle")
	var next_direction := queued_direction
	queued_direction = Vector2i.ZERO
	if not won and next_direction != Vector2i.ZERO and clock - queued_at <= 0.22:
		dash(next_direction)

func _draw() -> void:
	if renderer: renderer.render()

func total_charts() -> int:
	var result := 0
	for value in best.values(): result += int(value)
	return result

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if sound: await sound.shutdown()
		get_tree().quit()
