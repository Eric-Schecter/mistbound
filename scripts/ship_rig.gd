extends RefCounted

var g: Node2D
var texture: Texture2D
var hull: AtlasTexture
var angle := PI / 2
var turn_velocity := 0.0
var heel := 0.0
var speed := 0.0
var previous := Vector2.ZERO
var wake: Array[Dictionary] = []
var particles: Array[Dictionary] = []
var emit_distance := 0.0
var rng := RandomNumberGenerator.new()
var time := 0.0
var impact := 0.0
var impact_direction := Vector2.ZERO
var dock_light := 0.0
var last_turn := 0.0
var recoil := 0.0
var recoil_velocity := 0.0
var last_phase := "idle"
var sail_breath := 0.0

func _init(game: Node2D) -> void:
	g = game
	texture = load("res://assets/art/toy/rig.png")
	hull = AtlasTexture.new()
	hull.atlas = texture
	hull.region = Rect2(150, 40, 330, 560)
	rng.seed = 8317

func reset() -> void:
	previous = g.visual
	angle = g.heading.angle() + PI / 2
	turn_velocity = 0.0
	heel = 0.0
	speed = 0.0
	emit_distance = 0.0
	impact = 0.0
	dock_light = 0.0
	recoil = 0.0
	recoil_velocity = 0.0
	last_phase = "idle"
	sail_breath = 0.0
	wake.clear()
	particles.clear()

func update(delta: float) -> void:
	if g.paused: return
	time += delta
	if g.ship_phase != last_phase:
		if g.ship_phase == "settle" or g.ship_phase == "dock": recoil_velocity = 30.0
		elif last_phase in ["idle", "settle"] and g.ship_phase in ["sail", "brake"]: recoil_velocity = -20.0
		last_phase = g.ship_phase
	# A visual spring only: never delays accepting the next heading.
	recoil_velocity += (-recoil * 85.0 - recoil_velocity * 9.0) * delta
	recoil += recoil_velocity * delta
	recoil = clampf(recoil, -3.0, 3.0)
	sail_breath = sin(time * 2.6) * 0.10 + sin(time * 4.1) * 0.035
	var displacement: Vector2 = g.visual - previous
	var distance := displacement.length()
	speed = lerpf(speed, minf(distance / maxf(delta, 0.001), 520.0), 1.0 - exp(-delta * 11))
	var target: float = g.heading.angle() + PI / 2
	var error := angle_difference(angle, target)
	# Damped steering keeps a readable nose-first turn without snapping the sprite.
	turn_velocity += (error * 105.0 - turn_velocity * 19.0) * delta
	turn_velocity = clampf(turn_velocity, -8, 8)
	angle += turn_velocity * delta
	heel = lerpf(heel, clampf(-turn_velocity * 0.045, -0.23, 0.23), 1.0 - exp(-delta * 9))
	impact = maxf(0, impact - delta * 1.8)
	dock_light = maxf(0, dock_light - delta * 0.8)
	if distance > 0.01 and g.ship_phase != "impact":
		emit_distance += distance
		while emit_distance >= 7:
			emit_distance -= 7
			var pos: Vector2 = g.visual - displacement.normalized() * emit_distance
			wake.append({"p": pos - g.heading * 23, "d": g.heading, "age": 0.0})
		# Bow spray is emitted at distance intervals, rather than once per cell.
		if rng.randf() < minf(1.0, distance * 0.13):
			var side: Vector2 = g.heading.orthogonal() * (-1.0 if rng.randf() < 0.5 else 1.0)
			particles.append({"p": g.visual + g.heading * 23 + side * 6, "v": side * rng.randf_range(12, 28) - g.heading * 24, "life": 0.48, "max": 0.48, "color": Color("d8fff0"), "size": 1.4})
	previous = g.visual
	for ripple in wake: ripple.age += delta
	while not wake.is_empty() and wake[0].age > 1.5: wake.pop_front()
	for particle in particles:
		particle.life -= delta
		particle.p += particle.v * delta
		particle.v *= exp(-delta * 2)
	particles = particles.filter(func(p: Dictionary) -> bool: return p.life > 0)

func burst(kind: String, pos: Vector2) -> void:
	if kind == "impact":
		impact = 1.0
		impact_direction = -g.heading
	elif kind == "dock": dock_light = 1.0
	var color := Color("e1fff1")
	var count := 17
	if kind == "chart":
		color = Color("ffe3a0")
		count = 15
	elif kind == "wood":
		color = Color("cfa16b")
		count = 12
	for i in range(count):
		var a := rng.randf_range(0, TAU)
		var life := rng.randf_range(0.4, 0.85)
		particles.append({"p": pos, "v": Vector2(cos(a), sin(a)) * rng.randf_range(18, 72), "life": life, "max": life, "color": color, "size": rng.randf_range(1, 2.4)})

func draw_water() -> void:
	for side_sign in [-1, 1]:
		var edge := PackedVector2Array()
		var colors := PackedColorArray()
		for ripple in wake:
			var age: float = ripple.age
			var pos: Vector2 = ripple.p
			var d: Vector2 = ripple.d
			var width: float = 7 + age * 14
			var scatter := sin(pos.x * 0.39 + pos.y * 0.23 + time * 2) * age * 1.3
			var alpha: float = pow(maxf(0, 1.0 - age / 1.5), 1.5) * 0.32
			edge.append(pos + d.orthogonal() * (width + scatter) * side_sign)
			colors.append(Color(0.72, 0.94, 0.86, alpha))
			if int(pos.x * 3 + pos.y * 7) % 5 == 0:
				g.draw_circle(pos + d.orthogonal() * sin(pos.x + pos.y) * width * 0.55, 0.7 + age * 0.4, Color(0.8, 0.97, 0.9, alpha * 0.6))
		if edge.size() > 1: g.draw_polyline_colors(edge, colors, 1.7, true)
	var bob := sin(time * 2.1) * 1.8
	var p: Vector2 = g.visual + Vector2(0, bob) + g.heading * recoil
	var forward := Vector2.UP.rotated(angle)
	var cross_axis := forward.orthogonal()
	# A narrow contact shadow sits under the hull and never follows the sail outline.
	g.draw_set_transform(p + Vector2(2, 3), angle, Vector2(0.52, 1))
	g.draw_circle(Vector2.ZERO, 28, Color(0.015, 0.09, 0.10, 0.25))
	g.draw_set_transform(Vector2.ZERO)
	for side_sign in [-1, 1]:
		var offset: Vector2 = cross_axis * side_sign * 10
		g.draw_polyline(PackedVector2Array([p + forward * 23, p + offset + forward * 12, p + offset * 1.15 - forward * 14]), Color(0.75, 0.95, 0.87, 0.18 + speed / 520.0 * 0.32), 1.4, true)
	for particle in particles:
		var color: Color = particle.color
		color.a = clampf(particle.life / particle.max, 0, 1)
		g.draw_circle(particle.p, particle.size, color)

func cloth(region: Rect2, rect: Rect2, power: float, flutter: float, shade := Color.WHITE) -> void:
	# Eight independently deformed strips keep the luff attached while the free edge breathes.
	var texture_size := texture.get_size()
	for row in range(8):
		var points := PackedVector2Array()
		var uvs := PackedVector2Array()
		for corner in [Vector2(0, row / 8.0), Vector2(1, row / 8.0), Vector2(1, (row + 1) / 8.0), Vector2(0, (row + 1) / 8.0)]:
			var u: float = corner.x
			var v: float = corner.y
			var bulge := sin(v * PI) * u * (2.0 + power * 3.2 + sin(time * 3.2) * 1.2)
			var ripple := sin(v * 11.0 - time * (5.0 + power * 5.0)) * u * minf(flutter, rect.size.y * 0.045)
			points.append(rect.position + Vector2(u * rect.size.x * (0.45 + power * 0.55) + bulge + sin(time * 4.0 - v * 5.0) * u * flutter * 0.6, v * rect.size.y + ripple))
			uvs.append((region.position + corner * region.size) / texture_size)
		g.draw_polygon(points, PackedColorArray([shade]), uvs, texture)

func draw_ship() -> void:
	var rocking := sin(time * 2.1) * 0.065 * (1.0 - speed / 700.0)
	var hit_offset := impact_direction * sin(impact * PI * 3) * impact * 6
	var pos: Vector2 = g.visual + Vector2(0, sin(time * 2.1) * 1.8) + g.heading * recoil + hit_offset
	var tilt := heel + rocking + sin(impact * 14) * impact * 0.12
	g.draw_set_transform(pos, angle + tilt, Vector2(1.0 - absf(heel) * 0.3, 1))
	g.draw_texture_rect(hull, Rect2(-18, -31, 36, 62), false, Color(1, 0.8, 0.7, 1) if impact > 0.6 else Color.WHITE)
	var power: float = clampf(0.25 + g.sail_power * 0.70 + sail_breath, 0.35, 1.10)
	var flutter: float = 1.5 + (1.0 - g.sail_power) * 1.6
	# Rigging, spars and sail shadows remain separate from the painted deck.
	g.draw_line(Vector2(0, -29), Vector2(0, 24), Color("5a4834"), 1.6, true)
	g.draw_line(Vector2(0, -7), Vector2(-16, -12), Color(0.12, 0.15, 0.11, 0.24), 3, true)
	g.draw_line(Vector2(0, -5), Vector2(25 * power, 17), Color(0.12, 0.15, 0.11, 0.25), 4, true)
	cloth(Rect2(170, 750, 320, 380), Rect2(-18, -30, 19, 28), 0.5 + power * 0.5, flutter * 0.55, Color("e2e3ce"))
	cloth(Rect2(700, 60, 490, 540), Rect2(-2, -23, 32, 43), power, flutter)
	g.draw_line(Vector2(0, -24), Vector2(0, 19), Color("c4a775"), 1.2, true)
	g.draw_line(Vector2(0, 18), Vector2(24 * (0.45 + power * 0.55), 18), Color("8c6b40"), 1.4, true)
	cloth(Rect2(710, 820, 460, 220), Rect2(0, -32, 16, 9), 0.8, 2.4)
	g.draw_set_transform(Vector2.ZERO)
	if dock_light > 0:
		g.draw_arc(pos, 27 + (1.0 - dock_light) * 32, 0, TAU, 40, Color(1, 0.87, 0.55, dock_light * 0.65), 2, true)
