#!/bin/bash

# Define directories
input_dir="/path/to/tSNR/maps/directory"
output_dir="path/to/output/folder"   maps
template="/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz"  # Path to the MNI152 template

# Create output directory if it doesn't exist
mkdir -p $output_dir

echo "Step 1: Aligning tSNR maps to MNI152 space..."
# Align each tSNR map to MNI152
for tsnr_file in ${input_dir}/sub-*/tsnr_map.nii.gz; do
    sub=$(basename $(dirname $tsnr_file))  # Extract subject ID (e.g., sub-01)
    output_file=${output_dir}/${sub}_tsnr_MNI152.nii.gz
    flirt -in $tsnr_file -ref $template -out $output_file -omat ${output_dir}/${sub}_to_MNI152.mat
    echo "Aligned $sub to MNI152 space."
done

echo "Step 2: Merging all aligned tSNR maps into a 4D file..."
# Merge all aligned tSNR maps into a single 4D file
fslmerge -t ${output_dir}/group_tsnr_4D.nii.gz ${output_dir}/sub-*_tsnr_MNI152.nii.gz

echo "Step 3: Computing group-level statistics..."
# Compute mean tSNR map
fslmaths ${output_dir}/group_tsnr_4D.nii.gz -Tmean ${output_dir}/group_mean_tsnr.nii.gz

# Compute standard deviation tSNR map
fslmaths ${output_dir}/group_tsnr_4D.nii.gz -Tstd ${output_dir}/group_std_tsnr.nii.gz

echo "Step 4: Thresholding the mean tSNR map..."
# Threshold the mean tSNR map (optional, tSNR > 30)
fslmaths ${output_dir}/group_mean_tsnr.nii.gz -thr 30 ${output_dir}/group_mean_tsnr_thr30.nii.gz

echo "Processing complete! Results saved in: $output_dir"

# Display results to the user (optional)
echo "Generated files:"
ls -lh ${output_dir}
