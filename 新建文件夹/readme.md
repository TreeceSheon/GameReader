cs_mri takes half ehco of the chosen dataset and does reconstruction using methods listed in the functions.
        Note: This is a function that parameters must be passed to in *.pbs script.

merge.m is a script that combines all the seperate results into a *.mat including img_full, img_pc, img_npc and img_zhao.
        Note: 
        This script is meant to be executed after all of these reconstructed results are generated.
        This script should be located at the directory where all these reconstructed results store.

standard.pbs is a executable scirpt in tinaroo.
        Change cd directory if needed
        Change parameters for different echos and slices to reoncstruct.  
