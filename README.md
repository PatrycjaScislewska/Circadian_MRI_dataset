# Circadian rhythmicity and reinforcement processing: a dataset of MRI, fMRI, and behavioral measures
The dataset contains structural T1-weighted and functional magnetic resonance brain imaging data, from 37 men (aged 20-30), along with questionnaire-assessed measurements of trait-like eveningness, distinctness, sleep quality, personality type, anxiety levels, sensitivity to punishment and rewards, behavioral inhibition and activation system, attention deficits. In this study fMRI version of Monetary Incentive Delay task (MID) was used. The recruitment criteria excluded individuals with self-reported history of psychiatric or neurological conditions and current medication use. All the brain imaging sessions were performed between 1 PM and 5 PM in order to control the effect of time of day on acquired images. To control the seasonal effect, all scans were performed during 2 weeks in summer. This dataset is particularly valuable for researchers investigating circadian rhythmicity and may contribute to large-scale multicenter meta-analyses exploring structural brain correlates of eveningness and distinctness. Additionally, it can support studies focused on affective processing.

Here we provide scripts used for quality check of behavioral and neurobiological data.
Neuroimaging data quality was evaluated using a set of image quality metrics: 
- Contrast-to-noise ratio (CNR),
- framewise displacement (FD),
- DVARS,
- temporal Signal-to-noise ratio (tSNR).


All described data records are publicly available as OpenNeuro Dataset ds005479 (https://openneuro.org/datasets/ds005479/versions/1.0.3). The dataset includes a README file, dataset description, participant file with all psychometric data, and folders for neuroimaging data. Neuroimaging files are organized according to the Brain Imaging Data (BIDS) Structure, within folders for each participant (sub-XX) and specific subfolders scheme: anat, func, fmap. Subfolder anat contains raw, defaced anatomical T1-weighted MRI scan. Subfolder func contains raw BOLD data and an event file (.tsv file) listing onset times, durations, and types of stimuli. Subfolder fmap contains raw B0 fieldmaps acquired in two phase encoding directions (AP and PA). Additionally, each subfolder includes a .json file with technical details about the corresponding NIfTI files.
