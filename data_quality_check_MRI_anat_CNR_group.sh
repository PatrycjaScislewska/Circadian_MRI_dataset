#!/bin/bash

# Base directory for results
results_dir="path/to/folder/with/CNR/output"
output_csv="$results_dir/CNR_summary.csv"

# Initialize the CSV file with headers
echo "Participant,GM Mean Intensity,WM Mean Intensity,Background Std Intensity,CNR" > "$output_csv"

# Loop through all result files
for result_file in "$results_dir"/sub-*/sub-*_CNR_results.txt; do
    # Extract participant ID from the file path
    participant=$(basename "$result_file" | cut -d'_' -f1)

    # Read the values from the result file
    gm_mean=$(grep "GM Mean Intensity:" "$result_file" | awk '{print $4}')
    wm_mean=$(grep "WM Mean Intensity:" "$result_file" | awk '{print $4}')
    background_std=$(grep "Background Std Intensity:" "$result_file" | awk '{print $4}')
    cnr=$(grep "CNR:" "$result_file" | awk '{print $2}')

    # Append the values to the CSV file
    echo "$participant,$gm_mean,$wm_mean,$background_std,$cnr" >> "$output_csv"
done

echo "Summary CSV created at $output_csv"
