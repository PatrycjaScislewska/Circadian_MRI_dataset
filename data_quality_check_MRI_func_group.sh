#!/bin/bash

# Base directories
OUTPUT_DIR="/path/to/fMRI/preprocessed/data"
GROUP_SUMMARY="$OUTPUT_DIR/group_summary.csv"

# Initialize the group summary file
echo "Subject,Mean FD,Mean DVARS,Percentage DVARS,TSNR Mean,TSNR Std" > $GROUP_SUMMARY

# Loop through all subjects
for SUB_DIR in $OUTPUT_DIR/sub-*/; do
    SUB_ID=$(basename $SUB_DIR)
    echo "Aggregating $SUB_ID..."

    # Extract metrics
    FD_MEAN=$(grep "Mean FD" $SUB_DIR/summary.txt | awk '{print $NF}')
    DVARS_MEAN=$(grep "Mean DVARS (raw)" $SUB_DIR/summary.txt | awk '{print $NF}')
    DVARS_SCALED=$(grep "Mean DVARS (scaled)" $SUB_DIR/summary.txt | awk '{print $NF}')
    TSNR_MEAN=$(fslstats $SUB_DIR/tsnr_map -M)
    TSNR_STD=$(fslstats $SUB_DIR/tsnr_map -S)

    # Append to the group summary
    echo "$SUB_ID,$FD_MEAN,$DVARS_MEAN,$DVARS_SCALED, $TSNR_MEAN,$TSNR_STD" >> $GROUP_SUMMARY
done

echo "Group summary saved to $GROUP_SUMMARY"
