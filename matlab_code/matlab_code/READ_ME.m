% Basic intro duction of this code.
%
% If you met any question, please contact Yichen Fu: yfu@pppl.gov
%
%
%
% Script and files in this code
%
% There’re three main scripts: 
% 1. ml_preprocess.m: This script will download data from d3d and do all the preprocess we need. It will save the raw data we get from d3d as well as the preprocessed data. You can change the signal list (include or exclude beam torque), number of shots used to train here.
% 2. ensemble_learning.m: This script uses the preprocessed data to train an ensemble algorithm. You can choose how many data to train and how many to test from the whole data set. It will also save the trained algorithm in a compact form.
% 3. make_prediction.m: Here you can load the data for a specific shot and choose a trained algorithm to give a predict on this particular shot. It’ll show the prediction result as a function of time.
% 
% There’re also some other files there:
% 1. data_and_files: this folder contains the shot list and some middle step files.
% 2. load_data.m & preprocess.m: they are functions used in main script.
% 3. instant_ml_100.mat & mvtp_ml_100: Both of them are trained algorithm by using instantaneous data or mvtp(mean, variance, trend and polunomial fit). You can load one of these algorithm in “make_prediction.m” to test its prediction.
% 4. debug.m: you can simply ignore it.
%
%
% 
% Converting to C version
% 
% We have a C version of our code, which can load the trained compact model (for example, instant_ml_100.mat) andmake basic prediction. 
% If you want to use this code in C by PCS system, you need to make the
% following changes:
% 1. Update the seting in EMC/d3d repository
% 1.1 Change “makedefs_models” file, On the line that reads “alg_prediction_ARGS = '{zeros(1,726)}'”, the input number must be set to the number of inputs taken by the compact algorithm trained in matlab.
% 1.2 “alg_prediction.m” also needs to be modified. On the line that reads, “alg = loadCompactModel('signalList2_bag_fullTest.mat')”, ‘signalList2_bag_fullTest.mat’ needs to be renamed to the same name of the compact model moved to the directory.
% 1.3 Once these changes are made, you need to update the repository. This can be done by using the git commands: “git branch <tempBranch>”, “git add *”, “git commit -m “<comment on the new algorithm>””, “git commit origin <tempBranch>”.
% 2. Update "mvtp_master.h". Contact Bob Johnson at johnsonb@fusion.gat.com for help.





