# Define the base path
output_base="/path/to/T1w/data"

# Loop through participants
for i in $(seq -w 01 37); do
    # Define the anat folder path
    anat_dir="${output_base}/sub-${i}/anat"
    
    # Define the input T1w image and the output defaced image path
    t1w_image="${anat_dir}/sub-${i}_T1w.nii.gz"
    defaced_image="${anat_dir}/sub-${i}_T1w_defaced.nii.gz"
    
    # Run the defacing command using pydeface
    if [ -f "${t1w_image}" ]; then
        pydeface "${t1w_image}" --outfile "${defaced_image}"
        echo "Defaced: ${defaced_image}"
    else
        echo "T1w image not found for sub-${i}"
    fi
done
