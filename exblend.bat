@echo off
setlocal enabledelayedexpansion
set PATH="C:\Program Files\Blender Foundation\Blender 3.5"

:: Inisialisasi argumen default
set "input_dir="
set "output_dir="

:: Parsing argumen
:parse_args
if "%~1"=="" goto :validate_args

if "%~1"=="-i" (
    set "input_dir=%~2"
    shift
    shift
    goto :parse_args
)

if "%~1"=="-o" (
    set "output_dir=%~2"
    shift
    shift
    goto :parse_args
)

echo Argumen tidak valid: %~1
exit /b 1

:validate_args
:: Memeriksa apakah argumen input dan output telah disediakan
if "%input_dir%"=="" (
    echo Argumen input harus disediakan.
    exit /b 1
)

if "%output_dir%"=="" (
    echo Argumen output harus disediakan.
    exit /b 1
)

:: Membuat direktori output jika belum ada
mkdir "%output_dir%\obj" 2>nul
mkdir "%output_dir%\fbx" 2>nul
mkdir "%output_dir%\glb" 2>nul

:: Loop melalui setiap berkas dalam direktori input
for %%F in ("%input_dir%\*") do (
    :: Memeriksa apakah berkas adalah berkas Blender (.blend)
    if "%%~xF"==".blend" (
        :: Mendapatkan nama berkas tanpa ekstensi
        set "file_name=%%~nF"

        :: Menjalankan perintah ekspor untuk setiap format yang diinginkan
        blender -b -P libs/to-obj.py -- --input "%%F" --output "%output_dir%\obj\!file_name!.obj"
        blender -b -P libs/to-fbx.py -- --input "%%F" --output "%output_dir%\fbx\!file_name!.fbx"
        blender -b -P libs/to-glb.py -- --input "%%F" --output "%output_dir%\glb\!file_name!.glb"

        echo Berhasil mengekspor %%F
    )
)

endlocal
