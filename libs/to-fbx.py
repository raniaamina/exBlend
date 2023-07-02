import sys
import bpy

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

# Memuat berkas input
bpy.ops.wm.open_mainfile(filepath=input_file)

# Ekspor ke format FBX
bpy.ops.export_scene.fbx(
    filepath=output_file,
    use_selection=False,
    axis_forward='Y',
    global_scale=1.0
    # axis_forward='Y'
)
