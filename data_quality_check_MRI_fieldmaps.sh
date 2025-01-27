#!/bin/bash

# Input and output directories
INPUT_DIR="/path/to/MRI/data"
OUTPUT_DIR="/path/to/output/folder"
CONFIG="b02b0.cnf"

# Ensure output directory exists
mkdir -p $OUTPUT_DIR

# Loop through participant folders
for folder in $INPUT_DIR/sub-*/; do
    SUB_ID=$(basename $folder)
    echo "Processing $SUB_ID..."

    # Input fieldmap files
    AP_EPI="$folder/fmap/${SUB_ID}_dir-AP_epi.nii.gz"
    PA_EPI="$folder/fmap/${SUB_ID}_dir-PA_epi.nii.gz"

    # Check if fieldmap files exist
    if [[ -f $AP_EPI && -f $PA_EPI ]]; then
        # Create participant-specific output directory
        SUB_OUTPUT_DIR="$OUTPUT_DIR/$SUB_ID"
        mkdir -p $SUB_OUTPUT_DIR

        # Combine AP and PA field maps
        fslmerge -t $SUB_OUTPUT_DIR/se_epi_merged $AP_EPI $PA_EPI

        # Create acquisition parameters file
        echo -e "0 -1 0 0.0469802 \n0 1 0 0.0469802" > $SUB_OUTPUT_DIR/datain.txt

        # Run topup
        topup --imain=$SUB_OUTPUT_DIR/se_epi_merged \
              --datain=$SUB_OUTPUT_DIR/datain.txt \
              --config=$CONFIG \
              --fout=$SUB_OUTPUT_DIR/my_fieldmap \
              --iout=$SUB_OUTPUT_DIR/se_epi_unwarped

        # Convert field map to radians and process mean magnitude image
        fslmaths $SUB_OUTPUT_DIR/my_fieldmap -mul 6.28 $SUB_OUTPUT_DIR/my_fieldmap_rads
        fslmaths $SUB_OUTPUT_DIR/se_epi_unwarped -Tmean $SUB_OUTPUT_DIR/my_fieldmap_mag
        bet2 $SUB_OUTPUT_DIR/my_fieldmap_mag $SUB_OUTPUT_DIR/my_fieldmap_mag_brain

        echo "Fieldmap processing completed for $SUB_ID."
    else
        echo "Fieldmap files missing for $SUB_ID. Skipping..."
    fi
done

echo "All processing complete. Outputs saved to $OUTPUT_DIR."
