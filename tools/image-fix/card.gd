extends SceneTree
# Makes a character's card picture from their cut-out: centred on plain
# paper, 440 x 700 like the placeholders.
#   Godot --headless --path tools/image-fix --script res://card.gd -- <cutout.png> <out.jpg>
const W := 440
const H := 700
const MARGIN := 24
func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var art := Image.load_from_file(a[0])
	art.convert(Image.FORMAT_RGBA8)
	var s := minf((W - MARGIN * 2.0) / art.get_width(), (H - MARGIN * 2.0) / art.get_height())
	art.resize(int(art.get_width() * s), int(art.get_height() * s), Image.INTERPOLATE_LANCZOS)
	var card := Image.create(W, H, false, Image.FORMAT_RGBA8)
	card.fill(Color("#f7f3ea"))
	card.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), Vector2i((W - art.get_width()) / 2, (H - art.get_height()) / 2))
	card.convert(Image.FORMAT_RGB8)
	card.save_jpg(a[1], 0.9)
	quit()
