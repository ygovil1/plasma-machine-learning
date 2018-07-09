% Name: instant_ml.m
% Authoer: Yichen Fu
%
% Purpose: Load data from d3d and use the data for every instantaneous
% value to train the ml algorithm. Notice that so-called instantaneous
% value is calculate by the mean value of some period of time for each
% signals. It is because for different signals, the time interval might be
% different and obtaining the value of exactly the same time is impossible.
% ============================================================

% ========== Basic setup ==========

% Get the current directory
current_dir = mfilename('fullpath');  idcs = strfind(current_dir,'/'); 
homedir = current_dir(1:idcs(end));

% Add path to the directory containing MDSplus functions
addpath(genpath('/fusion/projects/codes/toksys/builds/current'))

% % Load disruptive and non-disruptive shot list
% load([homedir,'data_and_files/SHOTLIST_DisruptList.mat']);
% load([homedir,'data_and_files/SHOTLIST_nonDisruptList.mat']);

% Load shot list 
load([homedir,'data_and_files/shot_list_dis_whole.mat']);
load([homedir,'data_and_files/shot_list_nondis_whole.mat']);

% % Define MDSPlus list, PTdata list and total list
% signalList_ptd = ["ip", "iptdirect", "iptipp", ...
%     "EFSBETAN", "EFSLI", "EFSLI3", "EFSQ0", ...
%     "EFSQMIN", "EFSVOLUME", "PCVLOOP", "PCVLOOPB", "DSSDENEST"];
% signalList_mds = ["q95", "kappa","r0", "tinj"];
% signalList = ["ip", "iptdirect", "iptipp", "efsbetan", ...
%     "efsli", "efsli3", "efsq0", "efsqmin", ...
%     "q95", "efsvolume", "pcvloop", "pcvloopb", "kappa", "r0", "dssdenest","tinj"];

% Real old one
% signals obtained from getptd
signalList_ptd = ["ip", "iptdirect", "iptipp", "ONSMHDAF", "ONSMHDFF" ...
    "EFSWMHD", "EFSBETAN", "EFSBETAT", "EFSBETAP", "EFSLI", "EFSLI3", "EFSQ0", ...
    "EFSQMIN", "EFSVOLUME", "PCVLOOP", "PCVLOOPB", "DSSDENEST"];
% signals obtained from mdsvalue
signalList_mds = ["q95", "kappa","r0", "chisq", "pinj", "pech", "n1rms"];
% the total signal list, which has been changed into lower case
signalList = ["ip", "iptdirect", "iptipp", ...
    "efswmhd", "efsbetan", "efsbetat", "efsbetap", "efsli", "efsli3", "efsq0", ...
    "efsqmin", "q95", "efsvolume", "pcvloop", "pcvloopb", "kappa", "r0", "dssdenest", ...
    "chisq", "onsmhdaf", "onsmhdff"];

% Define the length of a frame; increment of each frame. The so-called
% instantaneous value is the averaged value within each frame.
frame = .1; %s
increment = 0.02; %s

% define the property of signoid function
sigmoidWidth = .015;
predictionWindow = .250;

% ========== Load disruptive data ==========
% the index of shots
ishot = 1;

% Define the 'large' data container for disruptive shots
shotList = shot_list_dis_whole;
disruptShotContainer = containers.Map;

% Load data for every shots
while ishot <= length(shotList)
    
    shot = shotList(ishot,1);
    
    % tmax: disrupt time
    tmax = shotList(ishot,4);
    
    % tmin: begin time
    tmin = shotList(ishot,2);
    
    if tmin < (tmax - frame)
        signalContainer = load_data_flat_top(shot, signalList_ptd, signalList_mds, tmin, tmax);

        % Put all data from small container to large container
        disruptShotContainer(int2str(shot)) = signalContainer;

        % make the print nicer
        fprintf('Loaded disrupt #%i, shot number: %i\n',ishot, shot)    
    end
    
    ishot = ishot + 1;  
end

fprintf('\n')
save([homedir, 'data_and_files/disruptContainer_whole'],'disruptShotContainer','-v7.3')

% ========== Load non-disruptive data ==========
% the index of shots
ishot = 1;

% Define the 'large' data container for disruptive shots
shotList = shot_list_nondis_whole;
nonDisruptShotContainer = containers.Map;

% Load data for every shots
while ishot <= length(shotList)
    
    shot = shotList(ishot,1);
    
    % tmin and tmax is the shot
    tmax = shotList(ishot,3);
    tmin = shotList(ishot,2);
    
    if tmin < (tmax - frame)
        signalContainer = load_data_flat_top(shot, signalList_ptd, signalList_mds, tmin, tmax);

        % Put all data from small container to large container
        nonDisruptShotContainer(int2str(shot)) = signalContainer;   

        % make the print nicer
        fprintf('Loaded nondisrupt #%i, shot number %i\n',ishot,shot)
    end
    
    ishot = ishot + 1; 
end

save([homedir, 'data_and_files/nonDisruptContainer_whole'],'nonDisruptShotContainer','-v7.3')


% ========== disruptive preprocessing ==========
% get the shot number & number of shots
shotNums = keys(disruptShotContainer);
numShots = length(shotNums);

ishot = 1;
shotFrameDataContainer_dis = containers.Map;

% calculate feature for each shot
while ishot <= length(shotNums)
	shotNum = char(shotNums(ishot));
	fprintf('dis preprocessing, ishot: %i, shotNum: %s\n',ishot, shotNum);
	
    sigContainer = disruptShotContainer(shotNum);
    
    processedFrames = preprocess_window(sigContainer, frame, increment, shotNum, signalList);
    
	shotFrameDataContainer_dis(int2str(str2num(shotNum))) = processedFrames;
	ishot = ishot + 1;
end

% ========== non-disruptive preprocessing ==========
% get the shot number & number of shots
shotNums = keys(nonDisruptShotContainer);
numShots = length(shotNums);

ishot = 1;
shotFrameDataContainer_non = containers.Map;

% calculate feature for each shot
while ishot <= length(shotNums)
	shotNum = char(shotNums(ishot));
	fprintf('non-dis preprocessing, ishot: %i, shotNum: %s\n',ishot, shotNum);
	
    sigContainer = nonDisruptShotContainer(shotNum);
    
    processedFrames = preprocess_window(sigContainer, frame, increment, shotNum, signalList);
    
	shotFrameDataContainer_non(int2str(str2num(shotNum))) = processedFrames;
	ishot = ishot + 1;
end


% ========== disruptive data target preparation ==========

shotKeys = keys(shotFrameDataContainer_dis);

ishot = 1;

data_dis = [];
target_dis = [];

% calculate data target for each shot
while ishot <= length(shotKeys)
    
	shotNum = char(shotKeys(ishot));
	
	%first four columns: shot number, startTime, endTime, timeToDisruption
	
	shotFrames = shotFrameDataContainer_dis(shotNum);
	
	iframe = 1;
	
	tempDatas = [];
	tempTargets = [];
    
    % calculate target for each frame
	while iframe <= length(shotFrames(:,1))
		
		datas = data_dis;
		tempDatas = vertcat(tempDatas, shotFrames(iframe,5:end));
		
		t = shotFrames(iframe,4);
		
		iframe = iframe + 1;
		
		targetValue = 1.0 / (1.0 + exp((t-predictionWindow)/(sigmoidWidth)));
		targets = target_dis;
		tempTargets = vertcat(tempTargets, targetValue);
		
	end
	
	data_dis = vertcat(data_dis,tempDatas);
	target_dis = vertcat(target_dis, tempTargets);
    
    fprintf('dis target, ishot: %i, Shot num: %s\n',ishot, shotNum)
    fprintf('Size of data_dis:   %i * %i\n', size(data_dis))
    fprintf('Size of target_dis: %i * %i\n\n', size(target_dis))
	
	ishot = ishot + 1;
end

fprintf('Total:\n')
fprintf('Size of data_dis:   %i * %i\n', size(data_dis))
fprintf('Size of target_dis: %i * %i\n\n', size(target_dis))

% ========== non-disruptive data target preparation ==========

shotKeys = keys(shotFrameDataContainer_non);
  
ishot = 1;

data_non = [];
target_non = [];

% calculate data target for each shot
while ishot <= length(shotKeys)
    
	shotNum = char(shotKeys(ishot));
	
	shotFrames = shotFrameDataContainer_non(shotNum);
		
	iframe = 1;
	
	splitDatas = [];
	splitTargets = [];
	splitNum = 50;
	currSplit = 1;
	
	while currSplit <= splitNum
		tempDatas = [];
		tempTargets = [];
		while iframe <= length(shotFrames(:,1))
            
			datas = data_non;
			tempDatas = vertcat(tempDatas, shotFrames(iframe,5:end));
			
			t = shotFrames(iframe,4);
			
			iframe = iframe + 1;
			
			targetValue = 0;
			targets = target_non;
			tempTargets = vertcat(tempTargets, targetValue);
			
		end
		
		splitDatas = vertcat(splitDatas, tempDatas);
		splitTargets = vertcat(splitTargets, tempTargets);
		currSplit = currSplit + 1;
	end
	
	data_non = vertcat(data_non,splitDatas);
	target_non = vertcat(target_non, splitTargets);
    
    fprintf('nondis target, ishot: %i, Shot num: %s\n',ishot, shotNum)
    fprintf('Size of allData:   %i * %i\n', size(data_non))
    fprintf('Size of allTarget: %i * %i\n\n', size(target_non))
	
	ishot = ishot + 1;
end

fprintf('Total:\n')
fprintf('Size of data_non:   %i * %i\n', size(data_non))
fprintf('Size of target_non: %i * %i\n\n', size(target_non))


% ========== combine data and target ========

% check whether 2 data set have same length
if length(data_dis(1,:)) == length(data_non(1,:))
    
    % put two data together
    dataTemp = cat(1, data_dis, data_non);
    targetTemp = cat(1, target_dis, target_non);
    
    % randomly shuffle
    ran_list = randperm(length(targetTemp));
    dataNew = dataTemp(ran_list,:);
    targetNew = targetTemp(ran_list);    
   
else
	disp("Sizes of data sets not the same.")
end

fprintf('size of all data: %i * %i, target: %i * %i\n', size(dataNew), size(targetNew))


% ========== save the preprocessing result ==========

save([homedir,'data_and_files/DataCombined_wholeshot_allsig_mvtp'], 'dataNew')
save([homedir,'data_and_files/TargetCombined_wholeshot_allsig_mvtp'], 'targetNew')
