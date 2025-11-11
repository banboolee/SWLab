# Close-loop Optogenetic Stimulation System for Epilepsy Experiments

**Version:** 1.0
**Author:** Li Bingjun
**Email:** libingjun@buaa.edu.cn
**Last Update:** October 2025

## 1. Introduction

This repository contains the MATLAB-based **closed-loop optogenetic stimulation system** developed for mouse epilepsy experiments.  
The system performs **real-time EEG/LFP signal monitoring**, **automatic seizure detection**, and **light stimulation control**.

The graphical interface is implemented in **MATLAB App Designer (.mlapp)**, supported by modular '.m' scripts and parameter '.mat' files.


## 2. System Components

'Zeus_SWLab.mlapp': Main GUI application for control and monitoring.
'zeus_******.mlapp': Submenus GUIs for detection / video recording / stimulation settings.
'KNN-18.mat': A simple example of a pre-trained KNN model for seizure detection.
'feature_extract.m': Feature extraction function for EEG/LFP signals.
'Read_PLX_Header.m'
'read_block_header.m'
'read_data_block.m'
'sort_block_data.m'
'find_block_start.m'
'is_valid_block_header.m': Functions for reading and processing a recording plx file.
'sdgseakpara.m'
'str2onlynum.m': Other utility functions.
'README.md': This file.

## 3. Requirements

- MATLAB R2021a or later
- EEG/LFP data acquisition system (e.g., Zeus Pro)
- Laser & Waveform generator (e.g., SIGLENT SDG2000X)

