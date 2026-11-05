extends RefCounted

var g: Node2D
var atlas: Texture2D
var terrain: Texture2D
var art: Array[AtlasTexture] = []
var pirate_texture: Texture2D
var background: Sprite2D
var water: ColorRect
var gold := Color("dfb979")
var cream := Color("f4e8cc")

func _init(game: Node2D) -> void:
	g = game
	var pirate_source: Texture2D = load("res://assets/art/toy/atlas.png")
	var source_size := pirate_source.get_size()
	var pirate_image := pirate_source.get_image().get_region(Rect2i(0, 0, int(source_size.x / 4), int(source_size.y / 2)))
	pirate_image.resize(256, 256, Image.INTERPOLATE_LANCZOS)
	pirate_texture = ImageTexture.create_from_image(pirate_image)
	background = Sprite2D.new()
	background.texture = load("res://assets/art/toy/harbor.png")
	background.position = Vector2(550, 400)
	var tex_size := background.texture.get_size()
	background.scale = Vector2.ONE * maxf(1100.0 / tex_size.x, 800.0 / tex_size.y)
	var backdrop_material := ShaderMaterial.new()
	backdrop_material.shader = load("res://assets/art/harbor-backdrop.gdshader")
	background.material = backdrop_material
	background.z_index = -10
	g.add_child(background)
	water = ColorRect.new()
	water.position = g.ORIGIN
	water.size = Vector2(696, 522)
	water.mouse_filter = Control.MOUSE_FILTER_IGNORE
	water.z_index = -5
	var material := ShaderMaterial.new()
	material.shader = load("res://assets/art/ocean.gdshader")
	water.material = material
	g.add_child(water)
	terrain = load("res://assets/art/toy/terrain.png")
	atlas = load("res://assets/art/toy/atlas.png")
	var size := atlas.get_size() / Vector2(4, 2)
	for i in range(8):
		var region := AtlasTexture.new()
		region.atlas = atlas
		region.region = Rect2(Vector2(i % 4, i / 4) * size, size)
		art.append(region)

func update_water(time: float) -> void:
	var viewport_size := g.get_viewport_rect().size
	# Enlarge the play area while retaining the full HUD and hint within the viewport.
	var layout_scale := minf(viewport_size.x / 850.0, viewport_size.y / 700.0)
	g.scale = Vector2.ONE * layout_scale
	g.position = viewport_size * 0.5 - Vector2(550, 413) * layout_scale
	background.position = (viewport_size * 0.5 - g.position) / layout_scale
	var tex_size := background.texture.get_size()
	background.scale = Vector2.ONE * maxf(viewport_size.x / tex_size.x, viewport_size.y / tex_size.y) / layout_scale
	water.material.set_shader_parameter("motion_time", time)

func label(value: String, pos: Vector2, size: int, color := Color("f4e8cc")) -> void:
	g.draw_string(g.font, pos + Vector2(0, 2), value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(0, 0.03, 0.04, 0.9))
	g.draw_string(g.font, pos, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func centered_label(value: String, y: float, size: int, color := Color("f4e8cc")) -> void:
	var width: float = g.font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	label(value, Vector2(550 - width * 0.5, y), size, color)

func panel(rect: Rect2, fill := Color("286b72"), border := Color("a28d62"), radius := 9) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0.03, 0.04, 0.5)
	style.shadow_size = 5 if fill.a > 0.0 else 0
	style.shadow_offset = Vector2(0, 3)
	g.draw_style_box(style, rect)

func sprite(index: int, pos: Vector2, size: Vector2, tint := Color.WHITE, angle := 0.0) -> void:
	g.draw_set_transform(pos, angle)
	g.draw_texture_rect(art[index], Rect2(-size / 2, size), false, tint)
	g.draw_set_transform(Vector2.ZERO)

func glow(pos: Vector2, radius: float, color: Color) -> void:
	for i in range(5, 0, -1):
		g.draw_circle(pos, radius * float(i) / 5.0, Color(color, 0.025 * (6 - i)))

func coast(p: Vector2i) -> void:
	var c: Vector2 = g.center(p)
	var rect := Rect2(c - Vector2.ONE * 29, Vector2.ONE * 58)
	# Connected land silhouettes follow the actual collision cells.
	g.draw_rect(Rect2(rect.position + Vector2(0, 4), rect.size), Color("b88b55"))
	var tex_scale := minf(terrain.get_width() / 696.0, terrain.get_height() / 522.0)
	g.draw_texture_rect_region(terrain, rect, Rect2((rect.position - g.ORIGIN) * tex_scale, rect.size * tex_scale), Color.WHITE)
	for d in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if g.tile(p + d) != "#":
			var n := Vector2(d)
			var side := n.orthogonal()
			var edge := c + n * 27
			g.draw_line(edge - side * 29 + Vector2(0, 4), edge + side * 29 + Vector2(0, 4), Color("367b7b"), 10, true)
			g.draw_line(edge - side * 29, edge + side * 29, Color("ffe5ae"), 4, true)
			g.draw_line(edge - side * 27 + n * 5, edge + side * 27 + n * 5, Color(0.65, 0.89, 0.8, 0.25), 2, true)
	var seed_value := p.x * 31 + p.y * 13
	var border := p.x == 0 or p.x == 11 or p.y == 0 or p.y == 8
	if not border and g.level == 1:
		if seed_value % 4 == 0: sprite(6, c + Vector2(0, -3), Vector2(49, 49), Color.WHITE)
	elif not border:
		sprite(1, c + Vector2(0, -4), Vector2(65, 65), Color.WHITE, (seed_value % 3 - 1) * 0.08)
	elif seed_value % 5 == 0:
		sprite(6, c + Vector2(0, -3), Vector2(62, 62), Color.WHITE, (seed_value % 3 - 1) * 0.17)

func current(pos: Vector2, direction: Vector2) -> void:
	var side := direction.orthogonal()
	glow(pos, 26, Color("85e8d7"))
	for i in range(3):
		var tip := pos + direction * (fmod(g.clock * 14 + i * 13, 39) - 14)
		g.draw_polyline(PackedVector2Array([tip - direction * 7 + side * 6, tip, tip - direction * 7 - side * 6]), Color(0.65, 0.97, 0.89, 0.68), 2.5, true)
	g.draw_arc(pos, 24, 0.15, 2.8, 24, Color(0.6, 0.95, 0.87, 0.24), 1, true)

func pirate_boat(cell: Vector2i) -> void:
	var pos: Vector2 = g.center(cell) + Vector2(0, sin(g.clock * 2.0 + cell.x) * 1.3)
	g.draw_set_transform(pos, (Vector2(g.pirate_heading(cell)).angle() + PI / 2) + sin(g.clock * 1.5 + cell.y) * 0.035)
	g.draw_texture_rect_region(pirate_texture, Rect2(-27, -34, 54, 68), Rect2(0, 0, 256, 256))
	g.draw_set_transform(Vector2.ZERO)

func pirate_wreck(wreck: Dictionary) -> void:
	var age: float = wreck.age
	var t := clampf(age / 1.15, 0.0, 1.0)
	var split := 1.0 - exp(-age * 7.0)
	var fade := 1.0 - smoothstep(0.55, 1.0, t)
	var pos: Vector2 = g.center(wreck.cell)
	var side: Vector2 = wreck.direction.orthogonal()
	# Two independently rolling sections, followed by a slower sinking tail.
	for section in range(2):
		var sign_value := -1.0 if section == 0 else 1.0
		var drift: Vector2 = side * sign_value * split * 15.0 + wreck.direction * split * 8.0
		g.draw_set_transform(pos + drift + Vector2(0, t * t * 12), -0.30 + sign_value * split * 0.85, Vector2(1.0 - t * 0.35, 1.0 - t * 0.15))
		g.draw_texture_rect_region(pirate_texture, Rect2(-27, -34 + section * 34, 54, 34), Rect2(0, section * 128, 256, 128), Color(0.85, 0.91, 0.89, fade))
	g.draw_set_transform(Vector2.ZERO)
	# Low spreading spray and tumbling timber make the contact legible at game scale.
	for i in range(16):
		var angle := i * 2.399
		var direction := Vector2(cos(angle), sin(angle) * 0.65)
		var spread := (20.0 + (i % 4) * 7) * split
		var point: Vector2 = pos + direction * spread + Vector2(0, -sin(t * PI) * (9 + i % 5))
		var alpha := pow(1.0 - t, 1.4)
		if i % 3 == 0:
			g.draw_set_transform(point, angle + t * 4.0)
			g.draw_rect(Rect2(-3, -1, 6, 2), Color(0.65, 0.43, 0.24, alpha))
			g.draw_set_transform(Vector2.ZERO)
		else:
			g.draw_line(point, point - direction * 4.0, Color(0.77, 0.94, 0.87, alpha * 0.9), 2.0, true)

func render() -> void:
	label("%02d / 20  %s" % [g.level + 1, g.NAMES[g.level]], Vector2(202, 90), 23)
	label("MISTBOUND", Vector2(793, 90), 16, Color("d4c29b"))
	panel(Rect2(202, 102, 696, 34), Color(0.10, 0.35, 0.38, 0.94), Color("dbb278"), 7)
	label("Moves  %02d" % g.moves, Vector2(218, 125), 17)
	for i in range(3): sprite(2, Vector2(343 + i * 34, 119), Vector2(26, 26), Color.WHITE if i < g.collected else Color(0.3, 0.45, 0.43, 0.9))
	label("Islands", Vector2(613, 125), 16)
	label("Sound Off" if g.sound.muted else "Sound On", Vector2(714, 125), 16)
	if not g.campaign_complete() and not (g.won and g.collected == 3):
		label("Retry", Vector2(840, 125), 16)
	# Bronze, stone and a fine inner highlight echo the illustrated architecture.
	panel(Rect2(g.ORIGIN - Vector2(10, 10), Vector2(716, 542)), Color(0, 0, 0, 0), Color("b8864b"), 12)
	panel(Rect2(g.ORIGIN - Vector2(6, 6), Vector2(708, 534)), Color(0, 0, 0, 0), gold, 8)
	for corner in [Vector2(197, 155), Vector2(903, 155), Vector2(197, 687), Vector2(903, 687)]:
		g.draw_circle(corner, 4, Color("e2c98a"))
	g.ship.draw_water()
	for y in range(g.board.size()):
		for x in range(g.board[y].size()):
			var p := Vector2i(x, y)
			if g.tile(p) == "#": coast(p)
	for y in range(g.board.size()):
		for x in range(g.board[y].size()):
			var p := Vector2i(x, y)
			var pos: Vector2 = g.center(p)
			var t: String = g.tile(p)
			if t == "#": continue
			# Sparse dotted navigation marks preserve cell alignment without a checkerboard.
			g.draw_circle(pos + Vector2(-29, -29), 0.8, Color(0.8, 0.88, 0.74, 0.13))
			if g.CURRENTS.has(t): current(pos, Vector2(g.CURRENTS[t]))
			elif t == "B": sprite(5, pos, Vector2(56, 56))
			elif t == "X":
				g.draw_arc(pos + Vector2(0, 10), 23, 0, TAU, 36, Color(0.95, 0.49, 0.36, 0.5), 1, true)
				sprite(4, pos + Vector2(0, -2), Vector2(61, 61))
			elif t == "G":
				glow(pos - Vector2(0, 12), 37, Color("ffd681"))
				sprite(3, pos + Vector2(0, -8), Vector2(79, 79))
	for p in g.stars:
		var pos: Vector2 = g.center(p) + Vector2(0, sin(g.clock * 2.4 + p.x) * 2)
		glow(pos, 29, Color("ffd683"))
		sprite(2, pos, Vector2(43, 43), Color.WHITE, sin(g.clock + p.y) * 0.04)
		for n in range(3):
			var a: float = g.clock * 0.5 + n * TAU / 3
			var spark := pos + Vector2(cos(a), sin(a)) * 23
			g.draw_circle(spark, 1.1, Color(1, 0.87, 0.55, 0.55))
	for cell in g.pirates:
		var facing: Vector2 = Vector2(g.pirate_heading(cell))
		var side := facing.orthogonal()
		for target in g.firing_cells(cell):
			var lane: Vector2 = g.center(target)
			g.draw_rect(Rect2(lane - Vector2(24, 24), Vector2(48, 48)), Color(0.85, 0.19, 0.12, 0.16 + sin(g.clock * 3) * 0.025))
			g.draw_polyline(PackedVector2Array([lane - facing * 4 + side * 7, lane + facing * 4, lane - facing * 4 - side * 7]), Color(0.96, 0.50, 0.29, 0.65), 2, true)
	for cell in g.pirates: pirate_boat(cell)
	for wreck in g.sinking_pirates: pirate_wreck(wreck)
	g.ship.draw_ship()
	if not g.sentry_shot.is_empty():
		var shot: Dictionary = g.sentry_shot
		var travel := clampf(shot.age / 0.10, 0.0, 1.0)
		if travel < 1.0:
			var bullet: Vector2 = shot.from.lerp(shot.to, travel)
			g.draw_line(bullet - (shot.to - shot.from).normalized() * 10, bullet, Color("eac58a"), 3, true)
			g.draw_circle(bullet, 4, Color("292a26"))
	# Small lantern accents and a restrained compass belong to the world, not the board.
	label(g.status, Vector2(202, 726), 14, Color("eadbb8"))
	if g.moves == 0:
		label("Arrow keys / WASD / Swipe to sail", Vector2(202, 755), 12, Color("b3c5b9"))
	if g.selecting_island: island_map()
	elif g.won or g.paused: overlay()

func overlay() -> void:
	g.draw_rect(Rect2(-g.position / g.scale, g.get_viewport_rect().size / g.scale), Color(0.015, 0.07, 0.09, 0.79))
	panel(Rect2(312, 230, 476, 330), Color("286b72"), gold, 15)
	centered_label(("Victory!" if g.campaign_complete() else "Safe Harbor") if g.won else "At Anchor", 291, 29)
	if g.won:
		for i in range(3): sprite(2, Vector2(480 + i * 70, 357), Vector2(64, 64), Color.WHITE if i < g.collected else Color("526f69"))
		centered_label("%d moves · %d / 3 chart pieces" % [g.moves, g.collected], 427, 21)
		if g.campaign_complete():
			centered_label("All 20 islands completed · %d / 60 charts" % g.total_charts(), 465, 17)
			panel(Rect2(430, 490, 240, 44), Color("28555a"), gold, 8)
			centered_label("Return to Islands", 519, 19)
			return
		centered_label("Enter / Click: Next Island", 481, 19)
		if g.collected < 3:
			centered_label("R: Retry to find every chart piece", 522, 16, Color("a9c3bb"))
		elif not g.PIRATE_CELLS[g.level].is_empty():
			centered_label("%d pirate boats sunk" % g.pirates_sunk, 522, 16, Color("a9c3bb"))
	else:
		centered_label("Esc: Continue sailing", 401, 20)
		centered_label("R: Restart voyage", 453, 18, Color("a9c3bb"))

func island_map() -> void:
	g.draw_rect(Rect2(-g.position / g.scale, g.get_viewport_rect().size / g.scale), Color(0.015, 0.07, 0.09, 0.88))
	panel(Rect2(126, 92, 848, 642), Color("245d66"), gold, 14)
	label("The Archipelago", Vector2(153, 139), 28)
	label("%d / 20 islands reached  ·  %d / 60 chart pieces" % [g.best.size(), g.total_charts()], Vector2(153, 170), 15, cream)
	panel(g.CLOSE_RECT, Color("498f94") if g.close_hovered else Color("28555a"), gold if g.close_hovered else Color("608b88"), 8)
	label("Close", Vector2(890, 135), 16, gold if g.close_hovered else cream)
	for index in range(g.MAPS.size()):
		var rect: Rect2 = g.island_card(index)
		var available: bool = g.island_available(index)
		var focused: bool = g.selection_index == index
		panel(rect, Color("397c80") if available else Color("173038"), gold if focused else Color("466663"), 8)
		var name_width: float = g.font.get_string_size(g.NAMES[index], HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		label(g.NAMES[index], rect.position + Vector2((150 - name_width) * 0.5, 19), 12, cream if available else Color("758b8c"))
		sprite(1, rect.position + Vector2(75, 48), Vector2(49, 42), Color.WHITE if available else Color(0.4, 0.5, 0.5, 0.65))
		label("%02d" % (index + 1), rect.position + Vector2(12, 51), 17, cream if available else Color("758b8c"))
		var stars: int = int(g.best.get(str(index), 0))
		label("%d / 3 charts" % stars if available else "Locked", rect.position + Vector2(37, 82), 13, cream if available else Color("758b8c"))
		var record: Dictionary = g.best_moves.get(str(index), {})
		var record_text := "Best: %d moves (%d/3)" % [int(record.moves), int(record.charts)] if not record.is_empty() else ("Not recorded" if g.best.has(str(index)) else "Ready to explore")
		if available: label(record_text, rect.position + Vector2(10, 101), 11, Color("adc6bf"))
	label("Select an island to sail again · Arrow keys + Enter · Esc to return", Vector2(153, 712), 14, Color("adc6bf"))
