# exBlend - Simple Script to Export Your Blender File to Various Format

This thesis is still in its early stages and will be updated regularly. exBlend is by default a simple script to bulk export *.blend files from a directory into obj, fbx, and glb formats.
Testing and fixing this script is always welcome. 

## Usage
Make sure you have downloaded this script. I assume you already know how to navigate folders in CLI. This example will simulate the folder to be processed to be in the same directory as the exblend.sh or exblend.bat file.

### Linux
```bash
chmod +x exblend.sh
./exblend.sh -i source -o results


# Export single file to obj
blender -b -P libs/to-obj.py -- -i input.blend -o output.obj 

# Export single file to fbx
blender -b -P libs/to-fbx.py -- -i input.blend -o output.fbx 

# Export single file to glb
blender -b -P libs/to-glb.py -- -i input.blend -o output.glb 
```


### Windows
```SHELL

./exblend.bat -i source -o results


# in each sesion of process, you have to run this export path at first step. Make sure to check your blender version, this is example if you use Blender 3.5

set PATH="C:\Program Files\Blender Foundation\Blender 3.5"

# Export single file to obj
blender -b -P libs/to-obj.py -- -i input.blend -o output.obj 

# Export single file to fbx
blender -b -P libs/to-fbx.py -- -i input.blend -o output.fbx 

# Export single file to glb
blender -b -P libs/to-glb.py -- -i input.blend -o output.glb 
```

'source' is directory where your blend files saved, and 'results' is directory to save export result. This script will automatically create result dir if it not exist.


### Update
Now you can user `-fmt` or `--format` to specify export format (obj, fbx, or glb). 

```bash
./exblend.bat -i source -o results -fmt "obj fbx"

```

## Dependecies
- Blender 3.x


## Need Improvement
- [] Export paramerter adjustment
- [] Reclean the output prompt
- [] Supporting other format(?)
- [] providing single binary like AppImage


## Behind This Scripts
exBlend was initiated by Rania Amina with the support of Blender Artist Alfan Abdurrafi. This tool is released under the GPL v3.0 license and is free to use for any purpose as long as it does not conflict with the applicable license terms.

Is this tool useful to you? You can support creators via the following links;
- [Rania Amina](https://saweria.co/raniaamina)
- [Alfin Abdurrafi](https://iconscout.com/contributors/alfin-studio)

## Disclaimers
This tool is provided without any warranty. Make sure you are aware of any risks that may arise as a result of using this tool.