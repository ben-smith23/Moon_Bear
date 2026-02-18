import bpy
import os

# Get directory
script_dir = os.path.dirname(os.path.abspath(__file__))
input_path = os.path.join(script_dir, "assets", "models", "apollo_lunar_module.glb")
output_path = os.path.join(script_dir, "assets", "models", "apollo_lunar_module_decompressed.glb")

print(f"Processing: {input_path}")

# Clear scene
bpy.ops.wm.read_factory_settings(use_empty=True)

# Import GLB (Blender handles Draco automatically)
bpy.ops.import_scene.gltf(filepath=input_path)

# Export GLB (Default settings DO NOT use Draco)
bpy.ops.export_scene.gltf(
    filepath=output_path,
    export_format='GLB',
    use_selection=False,
    export_draco_mesh_compression_enable=False  # Explicitly disable Draco
)

print(f"Exported decompressed model to: {output_path}")
