import bpy
import os

# Get directory
script_dir = os.path.dirname(os.path.abspath(__file__))
input_path = os.path.join(script_dir, "assets", "models", "Alien Animal Updated in Blender-2.81a", "Alien-Animal-Blender_2.81a_Packed.blend")
output_path = os.path.join(script_dir, "assets", "models", "alien_animal.glb")

print(f"Processing: {input_path}")

# Clear scene
bpy.ops.wm.read_factory_settings(use_empty=True)

# Open the blend file
bpy.ops.wm.open_mainfile(filepath=input_path)

# Delete any planes/floors
for obj in bpy.data.objects:
    print(f"Found object: {obj.name}, type: {obj.type}")
    # Delete planes and ground objects
    if obj.type == 'MESH' and ('plane' in obj.name.lower() or 'floor' in obj.name.lower() or 'ground' in obj.name.lower()):
        print(f"Deleting: {obj.name}")
        bpy.data.objects.remove(obj, do_unlink=True)

# Also check for any mesh that looks like a floor (large flat)
for obj in bpy.data.objects:
    if obj.type == 'MESH':
        # Check if it's a flat plane-like object
        dims = obj.dimensions
        if dims.x > 5 and dims.y > 5 and dims.z < 0.1:
            print(f"Deleting flat object: {obj.name} (dims: {dims})")
            bpy.data.objects.remove(obj, do_unlink=True)
        elif dims.x > 5 and dims.z > 5 and dims.y < 0.1:
            print(f"Deleting flat object: {obj.name} (dims: {dims})")
            bpy.data.objects.remove(obj, do_unlink=True)

# Export GLB
bpy.ops.export_scene.gltf(
    filepath=output_path,
    export_format='GLB',
    use_selection=False,
    export_draco_mesh_compression_enable=False
)

print(f"Exported model to: {output_path}")
