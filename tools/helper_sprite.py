"""Render a Meshy GLB of one of Charlie's helpers into a game sprite.

Run headlessly, no need to open Blender:

    /Applications/Blender.app/Contents/MacOS/Blender --background \
        --python tools/helper_sprite.py -- <model.glb> <out.png> [yaw_degrees]

One front-three-quarter view (turned `yaw_degrees` toward the right, 25 by
default) on a transparent background, flat-lit so the colours stay the
cartoon colours Meshy baked from the Gemini picture, with a dark outline to
match the game's other art. The game flips it to face left. Feet sit on
the bottom of the frame so the sprite can stand on the street.
"""
import bpy, sys, math
from mathutils import Vector

SIZE = 512          # output pixels, square
MARGIN = 1.08       # a little room around the model


def args():
    a = sys.argv[sys.argv.index("--") + 1:]
    return a[0], a[1], float(a[2]) if len(a) > 2 else 25.0


def main():
    glb, out, yaw = args()
    bpy.ops.wm.read_factory_settings(use_empty=True)
    bpy.ops.import_scene.gltf(filepath=glb)
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH"]

    # Parent everything to one empty so the whole model turns together.
    pivot = bpy.data.objects.new("pivot", None)
    bpy.context.scene.collection.objects.link(pivot)
    for o in bpy.context.scene.objects:
        if o.parent is None and o is not pivot:
            o.parent = pivot
    pivot.rotation_euler = (0.0, 0.0, math.radians(yaw))
    bpy.context.view_layer.update()

    lo = Vector((1e9, 1e9, 1e9))
    hi = Vector((-1e9, -1e9, -1e9))
    for o in meshes:
        for c in o.bound_box:
            w = o.matrix_world @ Vector(c)
            lo = Vector((min(lo.x, w.x), min(lo.y, w.y), min(lo.z, w.z)))
            hi = Vector((max(hi.x, w.x), max(hi.y, w.y), max(hi.z, w.z)))
    size = hi - lo
    centre_x = (lo.x + hi.x) / 2.0
    span = max(size.x, size.z) * MARGIN

    # Orthographic camera looking at the model's front (from -Y), framed so
    # the feet touch the bottom edge and the model is centred left-right.
    cam_data = bpy.data.cameras.new("cam")
    cam_data.type = "ORTHO"
    cam_data.ortho_scale = span
    cam = bpy.data.objects.new("cam", cam_data)
    bpy.context.scene.collection.objects.link(cam)
    cam.location = (centre_x, lo.y - 10.0, lo.z + span / 2.0 - (span - size.z * MARGIN) / 2.0 - size.z * (MARGIN - 1.0) / 2.0)
    cam.rotation_euler = (math.radians(90.0), 0.0, 0.0)
    bpy.context.scene.camera = cam

    scene = bpy.context.scene
    scene.render.engine = "BLENDER_WORKBENCH"
    shading = scene.display.shading
    shading.light = "FLAT"
    shading.color_type = "TEXTURE"
    shading.show_object_outline = True
    shading.object_outline_color = (0.08, 0.06, 0.12)
    scene.render.film_transparent = True
    scene.render.resolution_x = SIZE
    scene.render.resolution_y = SIZE
    scene.render.image_settings.file_format = "PNG"
    scene.render.image_settings.color_mode = "RGBA"
    scene.view_settings.view_transform = "Standard"
    scene.render.filepath = out
    bpy.ops.render.render(write_still=True)
    print("[helper_sprite] wrote", out, "size", tuple(round(v, 3) for v in size))


main()
