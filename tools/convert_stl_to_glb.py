# Blender Python script to convert STL to GLB for Godot
# Run with: blender --background --python convert_stl_to_glb.py

import bpy
import os
import sys

# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Paths
stl_path = os.path.join(script_dir, "Apollo 17 - Landing Site.stl")
output_path = os.path.join(script_dir, "assets", "models", "moon_terrain.glb")

print(f"Converting: {stl_path}")
print(f"Output: {output_path}")

# Clear default scene
bpy.ops.wm.read_factory_settings(use_empty=True)

# Import STL
bpy.ops.wm.stl_import(filepath=stl_path)

# Get the imported object
terrain = bpy.context.selected_objects[0]
terrain.name = "MoonTerrain"

# Center the object at origin
bpy.ops.object.origin_set(type='ORIGIN_CENTER_OF_VOLUME', center='MEDIAN')
terrain.location = (0, 0, 0)

# IMPORTANT: Recalculate normals to ensure they point outward (for proper collision)
bpy.ops.object.mode_set(mode='EDIT')
bpy.ops.mesh.select_all(action='SELECT')
bpy.ops.mesh.normals_make_consistent(inside=False)
bpy.ops.object.mode_set(mode='OBJECT')
print("Recalculated normals")

# Scale to reasonable size for Godot (STL might be in millimeters)
# Adjust scale factor based on the actual size
bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)

# Check the dimensions and scale if needed
dims = terrain.dimensions
print(f"Original dimensions: {dims.x:.2f} x {dims.y:.2f} x {dims.z:.2f}")

# If the model is too large (>1000 units), scale it down
max_dim = max(dims)
if max_dim > 500:
    scale_factor = 100 / max_dim  # Target ~100 units across
    terrain.scale = (scale_factor, scale_factor, scale_factor)
    bpy.ops.object.transform_apply(scale=True)
    print(f"Scaled down by factor: {scale_factor:.4f}")

# Decimate if polygon count is too high (for performance)
vert_count = len(terrain.data.vertices)
print(f"Vertex count: {vert_count}")

if vert_count > 100000:
    # Add decimate modifier
    decimate = terrain.modifiers.new(name="Decimate", type='DECIMATE')
    decimate.ratio = 100000 / vert_count  # Target ~100k verts
    bpy.ops.object.modifier_apply(modifier="Decimate")
    print(f"Decimated to: {len(terrain.data.vertices)} vertices")

# Create a simple gray material for the moon
mat = bpy.data.materials.new(name="MoonSurface")
mat.use_nodes = True
nodes = mat.node_tree.nodes
bsdf = nodes.get("Principled BSDF")
if bsdf:
    bsdf.inputs["Base Color"].default_value = (0.4, 0.4, 0.4, 1.0)  # Gray
    bsdf.inputs["Roughness"].default_value = 0.9  # Matte surface

terrain.data.materials.append(mat)

# Export as GLB
bpy.ops.export_scene.gltf(
    filepath=output_path,
    export_format='GLB',
    use_selection=True,
    export_apply=True
)

print(f"Successfully exported to: {output_path}")
