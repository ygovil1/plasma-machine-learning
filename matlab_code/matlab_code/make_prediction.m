% Name: make_prediction.m
% Author: Yichen Fu
%
% Purpose: Load the data for a signal shot and test it on our algorithm.
% Then test its prediction
%====================================================================

% ========== Basic setup ==========

% Set the shot number that we want to test
shot_num = 171988;
tmax = 10;

% length of a frame; increment of each frame
frame = 0.1; %s
increment = .02; %s

% Get the current directory
current_dir = mfilename('fullpath');  idcs = strfind(current_dir,'/'); 
homedir = current_dir(1:idcs(end));

% % Add path to the directory containing MDSplus functions
% addpath(genpath('/fusion/projects/codes/toksys/builds/current'))

% Only need to be load for once
ml_model = loadCompactModel([homedir, 'mdls/inst_ml_whole.mat']);

% ========== load real time data ==========

% Define MDSPlus list, PTdata list and total list
signalList_ptd = ["ip", "iptdirect", "iptipp", ...
    "EFSWMHD", "EFSBETAN", "EFSBETAT", "EFSBETAP", "EFSLI", "EFSLI3", "EFSQ0", ...
    "EFSQMIN", "EFSVOLUME", "PCVLOOP", "PCVLOOPB", "DSSDENEST"];
signalList_mds = ["q95", "kappa","r0", "tinj"];
signalList = ["ip", "iptdirect", "iptipp", "efswmhd", "efsbetan", ...
    "efsbetat", "efsbetap", "efsli", "efsli3", "efsq0", "efsqmin", ...
    "q95", "efsvolume", "pcvloop", "pcvloopb", "kappa", "r0", "dssdenest", "tinj"];

% % with beam torque
% % Define MDSPlus list, PTdata list and total list
% signalList_ptd = ["ip", "iptdirect", "iptipp", ...
%     "EFSBETAN", "EFSLI", "EFSLI3", "EFSQ0", ...
%     "EFSQMIN", "EFSVOLUME", "PCVLOOP", "PCVLOOPB", "DSSDENEST"];
% signalList_mds = ["q95", "kappa","r0", "tinj"];
% signalList = ["ip", "iptdirect", "iptipp", "efsbetan", ...
%     "efsli", "efsli3", "efsq0", "efsqmin", ...
%     "q95", "efsvolume", "pcvloop", "pcvloopb", "kappa", "r0", "dssdenest","tinj"];
            
raw_data_container = load_data(shot_num, signalList_ptd, signalList_mds, tmax);

% ========== preprocess ==========            
% the first 4 columns are not data, it's [shot_number, start_time, end_time, time_to_disrupt]
processed_frames = preprocess_window(raw_data_container, frame, increment, num2str(shot_num), signalList);
preprocessed_data = processed_frames(:,5:end);
preprocessed_time = processed_frames(:,3);

% ========== machine learning prediction ============

ml_prediction = predict(ml_model, preprocessed_data);

% ========== plot the prediction result ==========

subplot(2,1,1)
plot(preprocessed_time, ml_prediction)
title('ML prediction')

subplot(2,1,2)
plot(raw_data_container('ip_time'), raw_data_container('ip_data'))
title('Ip')
