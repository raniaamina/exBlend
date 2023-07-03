#!/bin/bash
set -e
# Initial Setup
VERSION="v1.0-devlovers"
LOGDIR="/tmp/exblend"
TIMESTAMP="$(date '+%Y-%m-%d_%H:%M')"
LOGFILE="$LOGDIR/$TIMESTAMP"
OPTFORMATS="obj OBJ FBX fbx GLB glb"
START=$(date +%s.%N)

# Set Args
function usage() {
    echo "$0 $VERSION"
    echo "Penggunaan umum:"
    echo "$0 -i folder-sumber -o folder-hasil"
    echo
    echo "Parameter khusus:"
    echo "  -i    (wajib)     path input yang berisi berkas *.blend"
    echo "  -o    (wajib)     path output untuk menyimpan berkas hasil ekspor"
    echo
    echo "  -fmt  (opsional)  format export (obj, fbx, glb)"
    echo "                    bila parameter tidak ditentukan skrip akan mengekspor"
    echo "                    ke dalam semua format yang tersedia"
    echo "  -h    (khusus)    Menampilkan bantuan"
    echo
    echo "----------"
    echo "contoh penggunaan: "
    echo ""$0 -i my-folder -o hasil -f \"obj fbx\"""
    echo
    echo "perintah di atas akan mengekspor bekas *.blend pada folder my-folder"
    echo "dalam format obj dan fbx lalu menyimpan hasil ekspor pada folder hasil."
    echo
    echo "https://github/raniaamina/exblend"
    echo

    exit
}

function hint() {
    INFO=$1
    echo -e "Gunakan -h atau --help untuk melihat $INFO"
}

if ! command -v blender &>/dev/null; then
    echo -e "[GALAT!] \nPerintah 'blender' tidak ditemukan! \nPastikan Blender telah terpasang dan tersedia dalam lingkungan \$PATH"
    exit 1
else
    if [[ $COLUMNS -gt 50 ]]; then
        echo "terminal sempit"
    else
        echo '
__________________________________________________'
        echo '                                                     
               mmmmm  ""#                      # 
  mmm   m   m  #    #   #     mmm   m mm    mmm# 
 #"  #   #m#   #mmmm"   #    #"  #  #"  #  #" "# 
 #""""   m#m   #    #   #    #""""  #   #  #   # 
 "#mm"  m" "m  #mmmm"   "mm  "#mm"  #   #  "#m## '
    fi
    echo "-------------------------------------------------"
    echo "exBlend menggunakan engine: $(blender --version)"
    echo "-------------------------------------------------"
    echo
fi

function doExport() {
    ext=$(echo $1 | tr '[:upper:]' '[:lower:]')
    # CountTotal=$(ls "$input_dir" | wc -l)
    counter=0


    for fb in "$input_dir"/*.blend; do
        file_name=$(basename -- "$fb")
        file_name="${file_name%.*}"
        counter=$((counter+1))

        if [[ ! -d "$output_dir/$ext" ]]; then 
            mkdir -p "$output_dir/$ext"
        fi
        

        blender -b -P libs/to-$ext.py -- --input "$fb" --output "$output_dir/$ext/$file_name.$ext" > $LOGFILE.log 2>&1

        if [[ -f "$output_dir/$ext/$file_name.$ext" ]]; then
            NOTE="✅"
        else
            NOTE="ℹ️"
        fi

        echo "[$counter/$CountTotal] $NOTE $file_name.$ext "
        
    done
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
    -i | --input)
        input_dir="$2"
        shift
        shift
        ;;
    -o | --output)
        output_dir="$2"
        shift
        shift
        ;;
    -fmt | --format)
        output_fmt="$2"
        shift
        shift
        ;;
    -h | --help)
        usage
        shift
        shift
        ;;
    *)
        echo "Argumen tidak valid: $1"
        usage
        exit 1
        ;;
    esac
done

# Check Args Existance
if [[ -z $input_dir || -z $output_dir ]]; then
    echo
    echo -e "[GALAT!] \nArgumen input dan output harus disediakan."
    hint "Cara Penggunaan."
    echo
    exit 1
fi



if [[ ! -d $input_dir ]]; then
    echo
    echo -e "[GALAT!] \nFolder input tidak ditemukan. Pastikan Anda tidak salah ketik nama folder input!"
    echo
    exit 1
fi



echo "⚙️ Pengecekan Format ..."
CountTotal=$(ls "$input_dir" | wc -l)
if [[ -z $output_fmt ]]; then
    echo "Format output tidak ditentukan, berkas akan diekspor ke OBJ, FBX, dan GLB."
    mkdir -p "$output_dir/obj" "$output_dir/fbx" "$output_dir/glb"
    output_fmt="obj, fbx, dan glb"
    echo "Mengekspor $CountTotal berkas ke OBJ ..."
    doExport obj
    echo "---"
    echo "Mengekspor $CountTotal berkas ke FBX ..."
    doExport fbx
    echo "---"
    echo "Mengekspor $CountTotal berkas ke GLB ..."
    doExport glb
    echo "---"
else
    # Stop proses apabila terdapat format yang tidak tersedia
    for fm in $output_fmt; do
        if [[ ! $(echo $OPTFORMATS | grep $fm) ]]; then
            echo
            echo -e "[GALAT!] \nFormat ekspor $fm tidak tersedia!"
            hint "dukungan format yang tersedia."
            echo
            echo "❌Pengecekan format gagal!"
            exit 1
        fi
    done

    # Lanjut memproses berkas ke dalam format yang tersedia
    echo "✅Pengecekan Format selesai."
    echo

    if [[ ! -d $LOGDIR ]];
        then mkdir -p $LOGDIR
    fi
    
    echo "⚙️ Memproses format yang dipilih ..."
    for fm in $output_fmt; do
        if [[ $(echo $OPTFORMATS | grep $fm) ]]; then
            echo "Memproses ekspor ke format: $fm"
            doExport $fm 
            echo
        fi
        # sadsa 
    done
    if [[ $? -eq 0 ]]; then
        echo "✅ Berkas selesai diproses dan disimpan ke dalam direktori: \'$output_dir\'."
        echo
    else
        echo '[INFO] Berkas selesai diproses namun ada kemungkinan galat pada berkas yang dihasilkan, mohon periksa kembali hasil ekspor.'
    fi
fi



END=$(date +%s.%N)
DIFF=$(echo "$END - $START" | bc)
echo "Kecepatan exBlend pada mesin Anda sekitar: $(echo ${DIFF:0:5})s ($counter berkas dalam format $(echo $output_fmt | tr '[:upper:]' '[:lower:]'))"