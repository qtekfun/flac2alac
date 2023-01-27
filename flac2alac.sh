#!/bin/bash

# Usage: ./convert.sh /path/to/flac/folder /path/to/alac/folder

# Comprobar que ffmpeg esta instalado y en caso contrario, instalarlo
if ! command -v ffmpeg &> /dev/null
then
    sudo apt update
    sudo apt install ffmpeg -y
fi

# Comprobar que se han pasado los argumentos correctamente
if [ $# -ne 2 ]
then
    echo "Uso: $0 carpeta_origen carpeta_destino"
    exit 1
fi

# Asignar los argumentos a variables
flac_folder=$1
alac_folder=$2

# Create the destination folder and the logs folder if they don't exist
mkdir -p "$alac_folder"
mkdir -p "$alac_folder/logs"

# Get the current date and time
now=$(date +"%Y-%m-%d_%H-%M")

# Create the log file with the current date and time
log_file="$alac_folder/logs/$now-convert.log"
touch "$log_file"

find "$flac_folder" -type f -iname "*.flac" -exec bash -c '
  flac_file="$1"
  alac_file="$2/$(dirname "${flac_file#$3/}")/$(basename "$flac_file" .flac).m4a"
  if [ ! -f "$alac_file" ]; then
    mkdir -p "$(dirname "$alac_file")"
    ffmpeg -i "$flac_file" -c:a alac -c:v copy -c:s copy -c:d copy "$alac_file" &>> "$4"
    echo "Converted $flac_file to $alac_file"
  else
    echo "$alac_file already exists, skipping..."
  fi
' -- {} "$alac_folder" "$flac_folder" "$log_file" \;

# Find all FLAC files in the source folder and its subfolders
find "$flac_folder" -type f -iname "*.flac" | while read flac_file; do
  # Construct the corresponding ALAC file path
  alac_file="$alac_folder/$(dirname "${flac_file#$flac_folder/}")/$(basename "$flac_file" .flac).m4a"
  # check if the alac file already exists
  if [ ! -f "$alac_file" ]; then
  #  # Create the subfolder if it doesn't exist
    mkdir -p "$(dirname "$alac_file")"
    # Convert the FLAC file to ALAC and save it to the destination path
    ffmpeg -i "$flac_file" -c:a alac -c:v copy -c:s copy -c:d copy "$alac_file" &>> "$log_file"
    # Print a message indicating that the file has been converted
    echo "Converted $flac_file to $alac_file"
  else
    # if alac file already exist, then skip it
    echo "$alac_file already exists, skipping..."
  fi
done


# Convertir los ficheros flac a alac
#find "$origen" -name "*.flac" -exec bash -c 'flac_file="$0"; alac_file="'"$destino"'/$(printf "%q" "${flac_file%.*}.m4a")"; ffmpeg -i "$flac_file" -c:a alac -c:v copy -c:s copy -c:d copy "$alac_file";' {} \;

# Copiar las portadas
#find "$origen" -name "cover.jpg" -exec bash -c 'cover="$0"; dest="'"$destino"'/$(dirname "$(printf "%q" "$cover")")"; if [ ! -d "$dest" ]; then mkdir -p "$dest"; fi; cp "$cover" "$dest/cover.jpg"' {} \;
