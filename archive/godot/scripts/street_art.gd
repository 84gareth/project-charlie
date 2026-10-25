extends Node2D
## Placeholder city street made of simple shapes: sky, a row of buildings,
## the pavement and the road. Drawn once; the camera slides along it.

const Layout = preload("res://scripts/street_layout.gd")

const SKY: Color = Color(0.55, 0.8, 0.98)
const PAVEMENT: Color = Color(0.72, 0.72, 0.74)
const KERB: Color = Color(0.55, 0.55, 0.58)
const ROAD: Color = Color(0.3, 0.31, 0.34)
const ROAD_LINE: Color = Color(0.98, 0.85, 0.2)
const WINDOW: Color = Color(0.98, 0.95, 0.7)
const BUILDING_COLOURS: Array[Color] = [
	Color(0.9, 0.45, 0.35), Color(0.95, 0.75, 0.3), Color(0.45, 0.7, 0.45),
	Color(0.55, 0.5, 0.85), Color(0.85, 0.55, 0.75), Color(0.4, 0.65, 0.8),
]

func _draw() -> void:
	var w: float = Layout.WORLD_WIDTH
	draw_rect(Rect2(0, 0, w, Layout.PAVEMENT_TOP), SKY)
	_draw_buildings(w)
	draw_rect(Rect2(0, Layout.PAVEMENT_TOP, w, Layout.ROAD_TOP - Layout.PAVEMENT_TOP), PAVEMENT)
	draw_rect(Rect2(0, Layout.ROAD_TOP - 10.0, w, 10.0), KERB)
	draw_rect(Rect2(0, Layout.ROAD_TOP, w, Layout.SCREEN_HEIGHT - Layout.ROAD_TOP), ROAD)
	var line_y: float = (Layout.ROAD_TOP + Layout.SCREEN_HEIGHT) / 2.0
	for x: int in range(0, int(w), 200):
		draw_rect(Rect2(x + 40, line_y - 6.0, 110.0, 12.0), ROAD_LINE)

func _draw_buildings(w: float) -> void:
	# Seeded, so the street looks the same every time.
	var rng := RandomNumberGenerator.new()
	rng.seed = 5
	var x: float = 0.0
	var last: int = -1
	while x < w:
		var bw: float = rng.randi_range(220, 360)
		var bh: float = rng.randi_range(260, 460)
		# Never the same colour twice in a row.
		var pick: int = (last + rng.randi_range(1, BUILDING_COLOURS.size() - 1)) % BUILDING_COLOURS.size()
		last = pick
		var colour: Color = BUILDING_COLOURS[pick]
		var top: float = Layout.PAVEMENT_TOP - bh
		draw_rect(Rect2(x, top, bw - 8.0, bh), colour)
		# Windows stop above the door.
		for wy: int in range(int(top) + 30, int(Layout.PAVEMENT_TOP) - 150, 80):
			for wx: int in range(int(x) + 28, int(x + bw) - 60, 70):
				draw_rect(Rect2(wx, wy, 36.0, 44.0), WINDOW)
		# A door.
		draw_rect(Rect2(x + bw / 2.0 - 30.0, Layout.PAVEMENT_TOP - 90.0, 60.0, 90.0), colour.darkened(0.45))
		x += bw
