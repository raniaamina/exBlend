param (
    [Alias("i")]
    [string]$input_dir,

    [Alias("o")]
    [string]$output_dir,

    [Alias("fmt")]
    [string]$output_fmt,

    [Alias("h")]
    [switch]$help
)


$env:PATH = "C:\Program Files\Blender Foundation\Blender 3.5"
$env:PATH = "C:\Program Files\Blender Foundation\Blender 3.6"

$VERSION = "v1.0-devlovers"
$LOGDIR = "C:\Temp\exblend"
# $TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HH:mm"
$STOPWATCH = [System.Diagnostics.Stopwatch]::StartNew()
$LOGFILE = Join-Path $LOGDIR "$TIMESTAMP.log"
$OPTFORMATS = "obj", "OBJ", "FBX", "fbx", "GLB", "glb"
$START = [System.Diagnostics.Stopwatch]::StartNew()

function usage {
    Write-Host "$PSCommandPath $VERSION"
    Write-Host "Penggunaan umum:"
    Write-Host "$PSCommandPath -i nama-folder -o output-folder -fmt 'obj, fbx'"
    Write-Host
    Write-Host "Parameter khusus:"
    Write-Host "  -i    (wajib)     path input yang berisi berkas *.blend"
    Write-Host "  -o    (wajib)     path output untuk menyimpan berkas hasil ekspor"
    Write-Host "  -fmt  (opsional)  format export (obj, fbx, glb)"
    Write-Host "                    bila parameter tidak ditentukan skrip akan mengekspor"
    Write-Host "                    ke dalam semua format yang tersedia"
    Write-Host "  -h    (khusus)    Menampilkan bantuan"
    Write-Host
    Write-Host "----------"
    Write-Host "contoh penggunaan: "
    Write-Host "$PSCommandPath -i nama-folder -o output-folder -fmt 'obj, fbx'"
    Write-Host
    Write-Host "perintah di atas akan mengekspor berkas *.blend pada nama-folder"
    Write-Host "dalam format obj dan fbx, lalu menyimpan hasil ekspor pada output-folder."
    Write-Host
    Write-Host "https://github.com/raniaamina/exblend"
    Write-Host
    exit
}

if ($help) {
    usage
    exit 1
}

function hint {
    param (
        [string]$INFO
    )
    Write-Host "Gunakan -h atau --help untuk melihat $INFO"
}

if (-not (Get-Command blender -ErrorAction SilentlyContinue)) {
    Write-Host "[GALAT!]"
    Write-Host "Perintah 'blender' tidak ditemukan!"
    Write-Host "Pastikan Blender telah terpasang dan tersedia dalam lingkungan \$PATH"
    exit 1
}
else {
    if ($Host.UI.RawUI.WindowSize.Width -gt 50) {
        Write-Host ""
    }
    else {
        Write-Host @"
__________________________________________________
                                                    
               mmmmm  ""#                      # 
  mmm   m   m  #    #   #     mmm   m mm    mmm# 
 #"  #   #m#   #mmmm"   #    #"  #  #"  #  #" "# 
 #""""   m#m   #    #   #    #""""  #   #  #   # 
 "#mm"  m" "m  #mmmm"   "mm  "#mm"  #   #  "#m## 
"@
    }
    Write-Host "-------------------------------------------------"
    Write-Host "exBlend menggunakan engine: Blender"
    Write-Host "-------------------------------------------------"
    Write-Host
}

function doExport {
    param (
        [string]$ext
    )
    $ext = $ext.ToLower()
    $counter = 0

    foreach ($fb in (Get-ChildItem -Path $input_dir -Filter "*.blend")) {
        $file_name = [System.IO.Path]::GetFileNameWithoutExtension($fb.Name)
        $counter++
        
        if (-not (Test-Path -Path "$output_dir\$ext")) {
            New-Item -ItemType Directory -Path "$output_dir\$ext" | Out-Null
        }

        blender -b -P libs/to-$ext.py -- --input "$input_dir\$fb" --output "$output_dir\$ext\$file_name.$ext" > $LOGFILE.log 2>&1

        if (Test-Path -Path "$output_dir\$ext\$file_name.$ext") {
            $NOTE = "[OK]"
        }
        else {
            $NOTE = "i"
        }

        Write-Host "[$counter/$CountTotal] $NOTE $file_name.$ext"
        
    }
}

if ([string]::IsNullOrEmpty($input_dir) -or [string]::IsNullOrEmpty($output_dir)) {
    Write-Host
    Write-Host "[GALAT!]"
    Write-Host "Argumen input dan output harus disediakan."
    hint "Cara Penggunaan."
    Write-Host
    exit 1
}




if (-not (Test-Path -Path $input_dir -PathType Container)) {
    Write-Host
    Write-Host "[GALAT!]"
    Write-Host "Folder input tidak ditemukan. Pastikan Anda tidak salah ketik nama folder input!"
    Write-Host
    exit 1
}

Write-Host "> Pengecekan Format ..."
$CountTotal = (Get-ChildItem -Path $input_dir -Filter "*.blend").Count
if ($output_fmt -eq "") {
    Write-Host "Format output tidak ditentukan, berkas akan diekspor ke OBJ, FBX, dan GLB."
    New-Item -ItemType Directory -Path "$output_dir\obj", "$output_dir\fbx", "$output_dir\glb" > $LOGFILE.all.log 2>&1
    # | Out-Null 
    $output_fmt = "obj, fbx, dan glb"
    Write-Host "Mengekspor $CountTotal berkas ke OBJ ..."
    doExport "obj" > $LOGFILE.obj.log 2>&1
    Write-Host "---"
    Write-Host "Mengekspor $CountTotal berkas ke FBX ..."
    doExport "fbx" > $LOGFILE.fbx.log 2>&1
    Write-Host "---"
    Write-Host "Mengekspor $CountTotal berkas ke GLB ..."
    doExport "glb" > $LOGFILE.glb.log 2>&1
    Write-Host "---"
}
else {
    $output_fmt_array = $output_fmt.Split(" ")
    foreach ($fm in $output_fmt_array) {
        $fm = $fm.Trim()
        if ($OPTFORMATS -notcontains $fm) {
            Write-Host
            Write-Host "[GALAT!]"
            Write-Host "Format ekspor $fm tidak tersedia!"
            hint "dukungan format yang tersedia."
            Write-Host
            Write-Host "[X] Pengecekan format gagal!"
            exit 1
        }
    }

    Write-Host "[OK] Pengecekan Format selesai."
    Write-Host

    if (-not (Test-Path -Path $LOGDIR -PathType Container)) {
        New-Item -ItemType Directory -Path $LOGDIR | Out-Null
    }

    Write-Host "> Memproses format yang dipilih ..."
    foreach ($fm in $output_fmt_array) {
        if ($OPTFORMATS -contains $fm) {
            Write-Host "Memproses ekspor ke format: $fm"
            doExport $fm
            Write-Host
        }
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Berkas selesai diproses dan disimpan ke dalam direktori: '$output_dir'."
        Write-Host
    }
    else {
        Write-Host "[INFO] Berkas selesai diproses namun ada kemungkinan galat pada berkas yang dihasilkan, mohon periksa kembali hasil ekspor."
    }
}
$STOPWATCH.Stop()
$END = [System.Diagnostics.Stopwatch]::GetTimestamp()
$DIFF = ($STOPWATCH.Elapsed).TotalSeconds

$fileCount = (Get-ChildItem -Path $input_dir -File).Count
Write-Host "Kecepatan exBlend pada mesin Anda sekitar: $([math]::Round($DIFF, 2))s ($fileCount berkas dalam format $output_fmt)"
