extends SceneTree
# Cuts one of Charlie's drawings out of its paper, like a sticker, so it can
# go in the game exactly as he drew it (Gareth, 2026-10-25: "put Charlie's
# drawings in as they are"). Adapted from Project Sam's cutout.gd.
#
# Pen (dark) and crayon (colourful) marks are thickened by GROW pixels so
# gaps in the outline close up; everything the photo's edge can reach
# without crossing that thickened drawing becomes see-through. So paper
# INSIDE the drawing stays, and a thin paper border is left round it. Small
# bits floating away from the drawing are dropped. Then it trims to the
# drawing and scales it to HEIGHT pixels tall.
#
#   Godot --headless --path tools/image-fix --script res://cutout.gd -- \
#       <in.jpg> <out.png> [crop=x,y,w,h] [keep=x,y;...] [erase=x,y;x,y;...] [grow=N] [sat=N] [height=N]
#
# crop= takes one drawing from a page with several (applied first, so
# erase= points are then in the cropped picture's pixels).
#
# erase= paints a polygon (photo pixels) with plain paper first: for the
# tablecloth showing in a corner of the photo.
var HEIGHT := 400
const PAPER := Color(0.97, 0.96, 0.93)
var GROW := 9

func is_ink(c: Color) -> bool:
	# Pen is properly dark; photo shadows are only mid-grey, so they don't
	# count. Crayon is properly colourful: Charlie's photos have bluish
	# paper and bluish shadows (saturation up to about 0.2), which Sam's
	# "s * v > 0.08" counted as crayon, keeping the whole sheet.
	return c.get_luminance() < 0.38 or (c.s > SATURATION and c.v > 0.2)

## "sat=N": how colourful a mark must be to count as crayon.
var SATURATION := 0.25

# Max filter along rows then columns with a running count: O(pixels).
func grow(mask: PackedByteArray, w: int, h: int, r: int) -> PackedByteArray:
	var tmp := PackedByteArray(); tmp.resize(w * h)
	for y in h:
		var count := 0
		for x in range(-r, w + r):
			var add := x + r
			if add < w and mask[y * w + add]: count += 1
			var sub := x - r - 1
			if sub >= 0 and sub < w and mask[y * w + sub]: count -= 1
			if x >= 0 and x < w: tmp[y * w + x] = 1 if count > 0 else 0
	var out := PackedByteArray(); out.resize(w * h)
	for x in w:
		var count := 0
		for y in range(-r, h + r):
			var add := y + r
			if add < h and tmp[add * w + x]: count += 1
			var sub := y - r - 1
			if sub >= 0 and sub < h and tmp[sub * w + x]: count -= 1
			if y >= 0 and y < h: out[y * w + x] = 1 if count > 0 else 0
	return out

# Keep only parts at least 8% the size of the biggest one.
func keep_big_parts(mask: PackedByteArray, w: int, h: int) -> PackedByteArray:
	var label := PackedInt32Array(); label.resize(w * h)
	var sizes: Array[int] = [0]
	for start in w * h:
		if not mask[start] or label[start]:
			continue
		var id := sizes.size()
		var count := 0
		var stack: Array[int] = [start]
		label[start] = id
		while not stack.is_empty():
			var k: int = stack.pop_back()
			count += 1
			var x := k % w
			var y := k / w
			for n in [k - 1 if x > 0 else -1, k + 1 if x < w - 1 else -1, k - w if y > 0 else -1, k + w if y < h - 1 else -1]:
				if n >= 0 and mask[n] and not label[n]:
					label[n] = id
					stack.append(n)
		sizes.append(count)
	var biggest := 0
	for c in sizes: biggest = maxi(biggest, c)
	var out := PackedByteArray(); out.resize(w * h)
	for k in w * h:
		if label[k] and sizes[label[k]] >= biggest * 0.08:
			out[k] = 1
	return out

# Everything OUTSIDE a polygon becomes plain paper: for a small cut-out
# lying on a patterned sofa, trace round the paper with keep=.
func keep_polygon(img: Image, spec: String) -> void:
	var pts := PackedVector2Array()
	for pair in spec.split(";"):
		var xy := pair.split(",")
		pts.append(Vector2(float(xy[0]), float(xy[1])))
	for y in img.get_height():
		for x in img.get_width():
			if not Geometry2D.is_point_in_polygon(Vector2(x, y), pts):
				img.set_pixel(x, y, PAPER)

func erase_polygon(img: Image, spec: String) -> void:
	var pts := PackedVector2Array()
	for pair in spec.split(";"):
		var xy := pair.split(",")
		pts.append(Vector2(float(xy[0]), float(xy[1])))
	for y in img.get_height():
		for x in img.get_width():
			if Geometry2D.is_point_in_polygon(Vector2(x, y), pts):
				img.set_pixel(x, y, PAPER)

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var img := Image.load_from_file(a[0])
	img.convert(Image.FORMAT_RGBA8)
	for extra in a.slice(2):
		if extra.begins_with("crop="):
			# Just one thing from a page with several: x,y,w,h in photo pixels.
			var r := extra.substr(5).split(",")
			img = img.get_region(Rect2i(int(r[0]), int(r[1]), int(r[2]), int(r[3])))
	for extra in a.slice(2):
		if extra.begins_with("height="):
			HEIGHT = int(extra.substr(7))
		elif extra.begins_with("keep="):
			keep_polygon(img, extra.substr(5))
		elif extra.begins_with("erase="):
			erase_polygon(img, extra.substr(6))
		elif extra.begins_with("grow="):
			GROW = int(extra.substr(5))
		elif extra.begins_with("sat="):
			SATURATION = float(extra.substr(4))
	var w := img.get_width()
	var h := img.get_height()
	var ink := PackedByteArray(); ink.resize(w * h)
	for y in h:
		for x in w:
			ink[y * w + x] = 1 if is_ink(img.get_pixel(x, y)) else 0
	var solid := keep_big_parts(grow(ink, w, h, GROW), w, h)
	var outside := PackedByteArray(); outside.resize(w * h)
	var stack: Array[Vector2i] = []
	for x in w:
		stack.append(Vector2i(x, 0)); stack.append(Vector2i(x, h - 1))
	for y in h:
		stack.append(Vector2i(0, y)); stack.append(Vector2i(w - 1, y))
	while not stack.is_empty():
		var p: Vector2i = stack.pop_back()
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
			continue
		var k := p.y * w + p.x
		if outside[k] or solid[k]:
			continue
		outside[k] = 1
		stack.append(p + Vector2i.LEFT); stack.append(p + Vector2i.RIGHT)
		stack.append(p + Vector2i.UP); stack.append(p + Vector2i.DOWN)
	for y in h:
		for x in w:
			if outside[y * w + x]:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
			else:
				# Inside the sticker: clean paper, but blend so even light
				# crayon keeps its colour.
				var c := img.get_pixel(x, y)
				var keep := maxf(smoothstep(0.55, 0.35, c.get_luminance()),
						smoothstep(0.04, 0.12, c.s * c.v))
				img.set_pixel(x, y, PAPER.lerp(c, keep))
	var box := img.get_used_rect()
	var out := img.get_region(box)
	out.resize(int(box.size.x * HEIGHT / float(box.size.y)), HEIGHT, Image.INTERPOLATE_BILINEAR)
	out.save_png(a[1])
	print(a[1].get_file(), " ", out.get_size())
	quit()
