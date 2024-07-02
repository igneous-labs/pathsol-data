#!/bin/bash

# Check if all required parameters are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <execution_id> <api_key>"
    exit 1
fi

# Parameters
EXECUTION_ID="$1"
API_KEY="$2"
BASE_URL="https://api.dune.com/api/v1/execution/${EXECUTION_ID}"

# Parameters for data retrieval
OFFSET=0
INCREMENT=25000

# Directory where CSV files will be saved
FILES_DIR="data"

# Make curl request to fetch status JSON and extract total_row_count using jq
total_row_count=$(curl -s -X GET "${BASE_URL}/status" -H "x-dune-api-key:${API_KEY}" | jq -r '.result_metadata.total_row_count')

# Check if total_row_count is retrieved successfully
if [ -z "${total_row_count}" ]; then
    echo "Failed to fetch total_row_count from API."
    exit 1
fi

# Function to download data
download_data() {
    local current_offset="$1"
    local file_name="activity_${current_offset}.csv"
    
    # Check if file already exists
    if [ -f "${FILES_DIR}/${file_name}" ]; then
        echo "File ${file_name} already exists. Skipping download."
    else
        # Make the curl request
        echo "Downloading data with offset ${current_offset}..."
        curl -s -X GET "${BASE_URL}/results/csv?limit=${INCREMENT}&offset=${current_offset}" -H "x-dune-api-key:${API_KEY}" -o "${FILES_DIR}/${file_name}"
        echo "Downloaded ${file_name}."
    fi
}

# Ensure the data directory exists
mkdir -p "${FILES_DIR}"

# Loop through offsets and download data
for (( current_offset=OFFSET; current_offset<total_row_count; current_offset+=INCREMENT )); do
    download_data "${current_offset}"
done

# Output merged file
OUTPUT_FILE="${FILES_DIR}/activity.csv"

# Check if merged file already exists
if [ -f "${OUTPUT_FILE}" ]; then
    echo "Merged file ${OUTPUT_FILE} already exists. Skipping merge."
else
    # Header for the output file
    echo "BLOCK_TIME,USER,AMOUNT" > "${OUTPUT_FILE}"

    # Merge all CSV files into one
    for file in "${FILES_DIR}"/*.csv; do
        if [ -f "$file" ]; then
            # Append data (skipping the header line)
            tail -n +2 "$file" >> "${OUTPUT_FILE}"
        fi
    done

    echo "Merged CSV file saved as ${OUTPUT_FILE}"
fi
