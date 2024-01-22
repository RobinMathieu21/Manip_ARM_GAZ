# Experiment ARM Gaz



## Introduction

This project contains all the codes used for the post-processing of the data presented in a paper (DOI: ).
It contains several codes that call others, the scripts to be run are :
### Kinematics:
- Run_EMGravity_WHOLE_BOdy_STS_BTS_1_kinematics.m : *First script to be runned to check the kinematic data of Whole-body tasks and recut if necessary*
- Run_EMGravity_WHOLE_BOdy_STS_BTS_1_kinematics_tous.m : *Second script to be runned on data presviously processed by the code above, to compute main kinematics parameters*
- Run_EMGravity_WHOLE_BOdy_STS_BTS_1_kinematicsBRAS.m : *First script to be runned to check the kinematic data of *ARM tasks* and recut if necessary*
- Run_EMGravity_WHOLE_BOdy_STS_BTS_1_kinematicsBRAS_TOUS.m : *Second script to be runned on data presviously processed by the code above, to compute main kinematics parameters*
  
### EMG:
- Run_EMGravity_WHOLE_BOdy_STS_BTS___EMG : *Script to be runned to compute EMG data using files created by the kinematic processing*
- Run_EMGravity_WHOLE_BOdy_STS_BTS___EMG__CALCUL_AIRE : *Script to be runned to compute a specific EMG parameter using files created by the code just above*
  
### Machine learning:



## Software
Matlab

## Versions
**Dernière version stable :** 1.0
**Dernière version :** 1.0

## Authors
* **Robin MATHIEU**
* **Jérémie GAVEAU**
