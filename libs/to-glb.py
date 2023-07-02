import bpy
import sys

# Mendapatkan argumen dari CLI
argv = sys.argv[sys.argv.index("--") + 1:]  # Mengambil argumen setelah "--"

# Parsing argumen
import argparse
parser = argparse.ArgumentParser(description='Blender CLI Export Script')
parser.add_argument('--input', '-i', help='Input file path')
parser.add_argument('--output', '-o', help='Output file path')
args = parser.parse_args(argv)

# Menentukan input dan output file
input_file = args.input
output_file = args.output

# Clear existing objects
bpy.ops.wm.read_factory_settings()

# Read the blend file
bpy.ops.wm.open_mainfile(filepath=input_file)

# Export the scene to glTF 2.0 format
bpy.ops.export_scene.gltf(
    filepath=output_file,
    check_existing=False,
    export_format='GLB',
    # export_draco_mesh_compression=False,
    # export_draco_mesh_quantization_bits=14,
    export_apply=True,
    export_cameras=False,
    # export_selected=False,
    export_extras=False,
    export_yup=True
)
