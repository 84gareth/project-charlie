extends SceneTree
# Makes the Home Screen icon: a cut-out drawing of Charlie's, centred on a
# sunny yellow square, 180 x 180 (the size iPads ask for). Charlie chose
# his blue helper (2026-10-25); the iPad rounds the corners itself.
#   Godot --headless --path tools/image-fix --script res://icon.gd -- <cutout.png> <out.png>
const SIZE := 180
const FILL := 0.86   ## how much of the square the drawing fills
const BACKGROUND := Color(1.0, 0.85, 0.3)

func _initialize() -> void:
	var a := OS.get_cmdline_user_args()
	var art := Image.load_from_file(a[0])
	art.convert(Image.FORMAT_RGBA8)
	var s := SIZE * FILL / maxf(art.get_width(), art.get_height())
	art.resize(int(art.get_width() * s), int(art.get_height() * s), Image.INTERPOLATE_LANCZOS)
	var icon := Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	icon.fill(BACKGROUND)
	var at := Vector2i((SIZE - art.get_width()) / 2, (SIZE - art.get_height()) / 2)
	icon.blend_rect(art, Rect2i(Vector2i.ZERO, art.get_size()), at)
	icon.save_png(a[1])
	print(a[1].get_file(), " ", icon.get_size())
	quit()
