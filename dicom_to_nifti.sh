# Define the base paths
input_base="/path/to/dicom"
output_base="/path/to/nifti"

# Loop through participants
for i in $(seq -w 01 37); do
    # Define input and output paths for each subject
    input_dir="${input_base}/sub-${i}"
    anat_output_dir="${output_base}/sub-${i}/anat"
    fmap_output_dir="${output_base}/sub-${i}/fmap"
    func_output_dir="${output_base}/sub-${i}/func"

    # Create the output subfolders if they don't exist
    mkdir -p "${anat_output_dir}" "${fmap_output_dir}" "${func_output_dir}"

    # Run the dcm2niix command and rename files to fit BIDS format
    /Applications/MRIcroGL.app/Contents/Resources/dcm2niix -f "sub-${i}_%p" -p n -z y -o "${output_base}/sub-${i}" "${input_dir}"

done
