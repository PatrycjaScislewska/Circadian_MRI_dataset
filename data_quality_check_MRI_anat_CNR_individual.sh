#!/bin/bash

# Base directories
raw_data_dir="/path/to/anatomical/data"
output_dir="/path/to/output/folder"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# Loop through all subjects in the BIDS structure
for subj_dir in "$raw_data_dir"/sub-*/anat/sub-*_anat_t1w.anat; do
    # Extract the subject ID
    sub=$(basename $(dirname $(dirname "$subj_dir")))
    echo "Processing $sub..."

    # Define input file paths
    t1w="$subj_dir/T1_biascorr.nii.gz"
    gm_mask="$subj_dir/T1_fast_pve_1.nii.gz"
    wm_mask="$subj_dir/T1_fast_pve_2.nii.gz"
    
    # Check if all required files exist
    if [[ ! -f "$t1w" || ! -f "$gm_mask" || ! -f "$wm_mask" ]]; then
        echo "Missing files for $sub, skipping."
        continue
    fi

    # Create participant-specific output folder
    sub_output_dir="$output_dir/$sub"
    mkdir -p "$sub_output_dir"

    # Compute means and standard deviation using fslstats
    gm_mean=$(fslstats "$t1w" -k "$gm_mask" -M)
    wm_mean=$(fslstats "$t1w" -k "$wm_mask" -M)
    background_std=$(fslstats "$t1w" -k "$wm_mask" -S)

    # Calculate CNR
    cnr=$(echo "($wm_mean - $gm_mean) / $background_std" | bc -l)

    # Save results to a file
    results_file="$sub_output_dir/${sub}_CNR_results.txt"
    echo "Participant: $sub" > "$results_file"
    echo "GM Mean Intensity: $gm_mean" >> "$results_file"
    echo "WM Mean Intensity: $wm_mean" >> "$results_file"
    echo "Background Std Intensity: $background_std" >> "$results_file"
    echo "CNR: $cnr" >> "$results_file"

    echo "Results saved to $results_file"
done

echo "CNR calculation completed for all participants."
