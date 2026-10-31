extends SceneTree
# Straightens a photo of a whole page taken at an angle: the four corners
# of the paper become the corners of a flat picture.
#   Godot --headless --path tools/image-fix --script res://straighten.gd -- \
#       <in> <out.jpg> <width> <height> tlx,tly trx,try brx,bry blx,bly
func corner(s: String) -> Vector2:
	var p := s.split(",")
	return Vector2(float(p[0]), float(p[1]))

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var src := Image.load_from_file(a[0])
	src.convert(Image.FORMAT_RGB8)
	var w := int(a[2])
	var h := int(a[3])
	var tl := corner(a[4]); var tr := corner(a[5]); var br := corner(a[6]); var bl := corner(a[7])
	var out := Image.create(w, h, false, Image.FORMAT_RGB8)
	var limit := Vector2(src.get_width() - 2, src.get_height() - 2)
	for y in h:
		var v := y / float(h - 1)
		var left := tl.lerp(bl, v)
		var right := tr.lerp(br, v)
		for x in w:
			var p := left.lerp(right, x / float(w - 1)).clamp(Vector2.ZERO, limit)
			var i := Vector2i(p)
			var f := p - Vector2(i)
			var top := src.get_pixelv(i).lerp(src.get_pixelv(i + Vector2i.RIGHT), f.x)
			var bot := src.get_pixelv(i + Vector2i.DOWN).lerp(src.get_pixelv(i + Vector2i.ONE), f.x)
			out.set_pixel(x, y, top.lerp(bot, f.y))
	out.save_jpg(a[1], 0.88)
	quit()
