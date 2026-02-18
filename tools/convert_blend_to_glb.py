import bpy
import sys

# Get args
argv = sys.argv
if "--" in argv:
    argv = argv[argv.index("--") + 1:] 
    input_path = argv[0]
    output_path = argv[1]
else:
    print("Error: No arguments provided")
    sys.exit(1)

# Open File
bpy.ops.wm.open_mainfile(filepath=input_path)

# Deselect all first
for obj in bpy.data.objects:
    obj.select_set(False)

# Select relevant objects (Armature + Meshes)
found_armature = False
for obj in bpy.data.objects:
    # Explicitly exclude Plane
    if "Plane" in obj.name:
        continue
    
    # Select Armature and Meshes
    if obj.type == 'ARMATURE' or obj.type == 'MESH':
        obj.select_set(True)
        if obj.type == 'ARMATURE':
            bpy.context.view_layer.objects.active = obj
            found_armature = True
            
if not found_armature:
    print("WARNING: Active Armature not found, animations might not export correctly.")

# Export GLB
bpy.ops.export_scene.gltf(
    filepath=output_path,
    export_format='GLB',
    export_yup=True,
    use_selection=True, # ONLY export selected
    export_lights=False,
    export_cameras=False,
    export_materials='EXPORT',
    export_animations=True 
)
print(f"Exported {input_path} to {output_path}")
