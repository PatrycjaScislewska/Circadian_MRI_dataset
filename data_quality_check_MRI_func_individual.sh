#!/bin/bash

# Base directories
FEAT_OUTPUT_DIR="/path/to/MRI/data"
OUTPUT_DIR="/path/to/output/folder"

# Loop through all subjects (assumes FEAT output folders are named like "sub-XX_task-MID_bold_preprocessing.feat")
for SUBJECT_FEAT in $FEAT_OUTPUT_DIR/sub-*/func/*_task-MID_bold_preprocessing.feat; do
    # Extract subject ID (e.g., sub-01)
    SUB_ID=$(basename $(dirname $(dirname $SUBJECT_FEAT)))
    echo "Processing $SUB_ID"

    # Create subject-specific output directory
    SUB_OUTPUT_DIR="$OUTPUT_DIR/$SUB_ID"
    mkdir -p $SUB_OUTPUT_DIR

    # Paths to preprocessed files
    FUNC_IMG="$SUBJECT_FEAT/filtered_func_data.nii.gz"  # Preprocessed functional data
    MASK_IMG="$SUBJECT_FEAT/mask.nii.gz"               # Preprocessed brain mask
    ANAT_IMG="$SUBJECT_FEAT/reg/highres.nii.gz"        # Registered anatomical image

    # Check if functional and mask images exist
    if [[ -f $FUNC_IMG && -f $MASK_IMG ]]; then
        # Detect motion outliers using FD
        fsl_motion_outliers -i $FUNC_IMG -o $SUB_OUTPUT_DIR/motion_outliers_fd.txt -p $SUB_OUTPUT_DIR/outlier_plot_fd.png --fd -s $SUB_OUTPUT_DIR/fd.txt

        # Detect signal outliers using DVARS
        fsl_motion_outliers -i $FUNC_IMG -o $SUB_OUTPUT_DIR/signal_outliers_dvars.txt -p $SUB_OUTPUT_DIR/outlier_plot_dvars.png --dvars -s $SUB_OUTPUT_DIR/dvars.txt

        # Compute mean signal and TSNR
        fslmaths $FUNC_IMG -Tmean $SUB_OUTPUT_DIR/mean_signal
        fslmaths $FUNC_IMG -Tstd $SUB_OUTPUT_DIR/std_signal
        fslmaths $SUB_OUTPUT_DIR/mean_signal -div $SUB_OUTPUT_DIR/std_signal $SUB_OUTPUT_DIR/tsnr_map

        # Normalize tSNR to mean signal intensity
        MEAN_SIGNAL=$(fslstats $SUB_OUTPUT_DIR/mean_signal -M)
        fslmaths $SUB_OUTPUT_DIR/tsnr_map -div $MEAN_SIGNAL $SUB_OUTPUT_DIR/tsnr_map_scaled

        # Extract range and generate histogram dynamically
        read MIN MAX < <(fslstats $SUB_OUTPUT_DIR/mean_signal -R)
        fslstats $SUB_OUTPUT_DIR/mean_signal -H 10 $MIN $MAX > $SUB_OUTPUT_DIR/signal_histogram.txt
        echo "Min: $MIN, Max: $MAX" > $SUB_OUTPUT_DIR/signal_range.txt

        # Extract global signal
        fslmeants -i $FUNC_IMG -o $SUB_OUTPUT_DIR/global_signal.txt

        # Analyze FD-based outliers using Python
        FD_MEAN=$(python3 -c "import numpy as np; print(np.mean([float(x.strip()) for x in open('$SUB_OUTPUT_DIR/fd.txt') if x.strip()]))")

        # Compute raw DVARS mean
        DVARS_MEAN=$(python3 -c "
import numpy as np
dvars = np.array([float(x.strip()) for x in open('$SUB_OUTPUT_DIR/dvars.txt') if x.strip()])
print(np.mean(dvars))
")

        # Normalize DVARS to mean signal intensity 
        python3 -c "
import numpy as np
mean_signal = $MEAN_SIGNAL
dvars = np.array([float(x.strip()) for x in open('$SUB_OUTPUT_DIR/dvars.txt') if x.strip()])
scaled_dvars = (dvars / mean_signal) * 100  # Normalize to percentage
np.savetxt('$SUB_OUTPUT_DIR/dvars_scaled.txt', scaled_dvars, fmt='%.2f')
" 

        # Analyze normalized DVARS using Python
        SCALED_DVARS_MEAN=$(python3 -c "
import numpy as np
scaled_dvars = np.loadtxt('$SUB_OUTPUT_DIR/dvars_scaled.txt')
print(np.mean(scaled_dvars))
")

        # Save summary to text file
        echo "Mean FD: $FD_MEAN" > $SUB_OUTPUT_DIR/summary.txt
        echo "Mean DVARS (raw): $DVARS_MEAN" >> $SUB_OUTPUT_DIR/summary.txt
        echo "Mean DVARS (scaled): $SCALED_DVARS_MEAN%" >> $SUB_OUTPUT_DIR/summary.txt
        echo "Mean Signal Intensity: $MEAN_SIGNAL" >> $SUB_OUTPUT_DIR/summary.txt
        echo "$SUB_ID: Processed successfully."
    else
        echo "Functional or mask image missing for $SUB_ID. Skipping..."
    fi

done

echo "Quality check completed for all subjects!"
