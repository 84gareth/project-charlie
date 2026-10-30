extends SceneTree
# Turns the placeholder SVGs (tools/placeholders/make_placeholders.py) into
# the pictures Charlie's Traitors loads, in the same sizes as Sam's:
#   <id>.svg         -> traitors/assets/characters/<id>.jpg   (on paper)
#   <id>-puppet.svg  -> traitors/assets/puppets/<id>.png      (cut out, 320 tall)
#   shield, dagger   -> traitors/assets/<name>.png
#   fire-pit, flames -> traitors/assets/final/<name>.png
#   Godot --headless --path tools/image-fix --script res://svg_to_png.gd -- <project folder>
const PUPPET_HEIGHT := 320
const ITEMS := {"shield": "", "dagger": "", "fire-pit": "final/", "flame-green": "final/", "flame-red": "final/"}

func render(path: String) -> Image:
	var img := Image.new()
	var err := img.load_svg_from_string(FileAccess.get_file_as_string(path), 1.0)
	if err != OK:
		push_error("could not read " + path)
	return img

func _initialize() -> void:
	var root: String = OS.get_cmdline_user_args()[0]
	var src := root + "/tools/placeholders/svg/"
	var assets := root + "/traitors/assets/"
	var count := 0
	for file in DirAccess.get_files_at(src):
		if not file.ends_with(".svg"):
			continue
		var name := file.get_basename()
		var img := render(src + file)
		if ITEMS.has(name):
			img.save_png(assets + ITEMS[name] + name + ".png")
		elif name.ends_with("-puppet"):
			var box := img.get_used_rect()
			var out := img.get_region(box)
			out.resize(int(box.size.x * PUPPET_HEIGHT / float(box.size.y)), PUPPET_HEIGHT, Image.INTERPOLATE_LANCZOS)
			out.save_png(assets + "puppets/" + name.trim_suffix("-puppet") + ".png")
		else:
			img.convert(Image.FORMAT_RGB8)
			img.save_jpg(assets + "characters/" + name + ".jpg", 0.9)
		count += 1
	print("made ", count, " pictures")
	quit()
