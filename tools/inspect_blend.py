import bpy
import sys

# Get args
argv = sys.argv
argv = argv[argv.index("--") + 1:] 
input_path = argv[0]

bpy.ops.wm.open_mainfile(filepath=input_path)

print("--- OBJECTS IN BLEND FILE ---")
for obj in bpy.data.objects:
    print(f"Name: {obj.name}, Type: {obj.type}")
print("-----------------------------")
