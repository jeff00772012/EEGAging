There are two folders, which contains the codes and produced data.
- codes:
EEG_feature:
This folder contains the codes to produce EEG features.
-	erplab10.03 (folder): This folder is the ERP toolbox used to obtain ERPs for our analysis
-	channels_locations.mat: The file contains channel names and numbers for the analysis of ERPs.
-	erplab_feature.m: This is the code to extract ERPs from EEG data.
-	quenching_EEG: This is the code to calculate quenching
-	cosDis_EEG: This is the code to calculate cosine distance
-	pce_EEG: This is the code to calculate PCE

supplementary_analysis:
This folder contains the codes for analysis and plots for supplementary figures 6 and 7
-	FigS6-EPRs: This folder contains the data and code for Fig. S6
	ERP_oneFeature.csv: ERPs for all the subjects and conditions
	GFP.csv: GFPs for all the subjects and conditions
	ERP.ipynb: The Python code for generating Fig. S6
-	FigS7-PCAregression: This folder contains the data and code for Fig. S7
	TasksData_OneF_clean.xlsx: The EEG features of the three tasks
	VBM, CMot, RT _1feature.csv: The EEG features of the three tasks, separated into three files
	VBM, CMot, RT _o_impute.csv: The EEG features of the three tasks for older adults, with imputed missing data
	VBM, CMot, RT _y_impute.csv: The EEG features of the three tasks for young adults, with imputed missing data

1.EEGAgingAnalysis_OneFeature.ipynb:
It is the code for processing the data and analysis

- data:
VBM.csv, CM.csv, RT.csv: Contains all behavioral and EEG data for processing
RawData_1Feature.xlsx: Includes the experimental conditions reported in the main text
