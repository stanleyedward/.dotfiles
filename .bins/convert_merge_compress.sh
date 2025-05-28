#!/bin/bash

# Script to convert PPTX files to PDF, merge them, and compress the result.

# Check if LibreOffice, pdftk, and Ghostscript (gs) are installed
command -v libreoffice >/dev/null 2>&1 || { echo >&2 "LibreOffice is required but not installed. Aborting."; exit 1; }
command -v pdftk >/dev/null 2>&1 || { echo >&2 "pdftk is required but not installed. Aborting."; exit 1; }
command -v gs >/dev/null 2>&1 || { echo >&2 "Ghostscript (gs) is required but not installed. Aborting."; exit 1; }

# Check if an argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path_to_to_merge_to_pdf_folder>"
    exit 1
fi

INPUT_DIR=$1
OUTPUT_DIR="./output_pdf"
TEMP_MERGED_PDF="merged_temp.pdf"
PDF_FILES=()

# Check if the input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' not found."
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

echo "Starting PPTX to PDF conversion and merging process..."
echo "Input Directory: $INPUT_DIR"
echo "Output Directory: $OUTPUT_DIR"

# Loop through numbered files (1.pptx, 2.pptx, ...)
i=1
while true; do
    PPTX_FILE="$INPUT_DIR/$i.pptx"
    PDF_FILE="$INPUT_DIR/$i.pdf"

    # Break the loop if neither PPTX nor PDF exists for the current number
    if [ ! -f "$PPTX_FILE" ] && [ ! -f "$PDF_FILE" ]; then
        echo "No more numbered files (PPTX or PDF) found starting from $i."
        break
    fi

    # Check if the PDF already exists
    if [ -f "$PDF_FILE" ]; then
        echo "File '$PDF_FILE' already exists. Skipping conversion."
        PDF_FILES+=("$PDF_FILE")
    # Check if the PPTX file exists to convert it
    elif [ -f "$PPTX_FILE" ]; then
        echo "Converting '$PPTX_FILE' to '$PDF_FILE'..."
        # Use LibreOffice to convert PPTX to PDF
        libreoffice --headless --convert-to pdf --outdir "$INPUT_DIR" "$PPTX_FILE" >/dev/null 2>&1

        if [ $? -eq 0 ] && [ -f "$PDF_FILE" ]; then
            echo "Conversion successful: '$PDF_FILE' created."
            PDF_FILES+=("$PDF_FILE")
        else
            echo "Error: Conversion failed for '$PPTX_FILE'."
            # Optionally, you might want to exit or handle this error
        fi
    fi

    ((i++))
done

# Check if any PDF files were found or created
if [ ${#PDF_FILES[@]} -eq 0 ]; then
    echo "No PDF files to merge. Exiting."
    exit 0
fi

echo "Found/Created ${#PDF_FILES[@]} PDF files: ${PDF_FILES[*]}"

# Merge the PDF files using pdftk
echo "Merging PDF files..."
pdftk "${PDF_FILES[@]}" cat output "$TEMP_MERGED_PDF"

if [ ! -f "$TEMP_MERGED_PDF" ]; then
    echo "Error: Merging failed. '$TEMP_MERGED_PDF' not created."
    exit 1
fi

echo "Merging successful: '$TEMP_MERGED_PDF' created."

# Generate a unique output filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_FILENAME="merged_compressed_$TIMESTAMP.pdf"
COMPRESSED_PDF="$OUTPUT_DIR/$OUTPUT_FILENAME"

# Compress the merged PDF using Ghostscript
echo "Compressing '$TEMP_MERGED_PDF' to '$COMPRESSED_PDF'..."
gs -sDEVICE=pdfwrite \
   -dCompatibilityLevel=1.4 \
   -dPDFSETTINGS=/ebook \
   -dNOPAUSE \
   -dQUIET \
   -dBATCH \
   -sOutputFile="$COMPRESSED_PDF" \
   "$TEMP_MERGED_PDF"

if [ ! -f "$COMPRESSED_PDF" ]; then
    echo "Error: Compression failed."
    rm "$TEMP_MERGED_PDF" # Clean up temp file even on failure
    exit 1
fi

echo "Compression successful."

# Clean up the temporary merged file
rm "$TEMP_MERGED_PDF"

echo "Process completed successfully. Output file: $COMPRESSED_PDF"
exit 0


# ./convert_merge_compress.sh ./my_presentations
