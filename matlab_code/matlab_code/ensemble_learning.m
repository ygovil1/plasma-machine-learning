% Name: instant_ml.m
% Author: Yichen
%
% Purpose: Use the proprocessed data to train machine learning algorithm,
% then test its prediction result
% ============================================================

% Get current direction and load data & target
current_dir = mfilename('fullpath');  idcs = strfind(current_dir,'/'); 
homedir = current_dir(1:idcs(end));

% load([homedir, 'data_and_files/DataCombined.mat'])
% load([homedir, 'data_and_files/TargetCombined.mat'])

% Set up number of frames for learning and testing
totFrames = 540319;
test = 250000;
train = totFrames-test;

traind = dataNew(1:train,:);
traint = targetNew(1:train);
testd = dataNew(train+1:test+train,:);
testt = targetNew(train+1:test+train);

disp('start')

% begin machine learning!
test_ml_algorithm = fitrensemble(traind,traint,'Method','Bag');


% ========== save the compact algorithm ==========
saveCompactModel(test_ml_algorithm, [homedir,'inst_ml_whole'])

disp('trained and saved')



% ========== check the result on testing set ==========

% make prediction on test data
predictions = predict(test_ml_algorithm,testd);

%to be compared with test target
max = [];
threshes = [];
thresh = 0;
step = .025;

% test the result for each thresh 
while thresh <= 1.0
    threshes = [threshes;thresh];
    fp = 0;
    cp = 0;
    fn = 0;
    cn = 0;
    tp = 0;
    tn = 0;
    ind1 = 1;
    while ind1 <= test
        %should be positive
        testt(ind1);
        if testt(ind1) >= .5
            tp = tp + 1;
            if predictions(ind1) >= thresh
                cp = cp + 1;
            else
                fn = fn + 1;
            end
        end
        %should be negative 
        if testt(ind1) <= .5
            tn = tn + 1;
            if predictions(ind1) >= thresh
                fp = fp + 1;
            else
                cn = cn + 1;
            end
        end
        ind1 = ind1 + 1;
    end
    %disp([cp,cn,fp,fn])
    %for a single threshold
    max = [max; [cp,cn,fp,fn,tp,tn]];
    thresh = thresh + step;
    
end

% ========== plot the result of predicting ==========

% %correct positive false positive plots
% plot(threshes,max(:,3)/max(1,6),threshes,max(:,1)/max(1,5))
% xlabel("threshold")
% title("correct positives and false positives, varying threshold")

%roc plot
corr_pos_perc = max(:,1)/max(1,5);
false_pos_perc = max(:,3)/max(1,6);
plot(false_pos_perc, corr_pos_perc)
title("corrPos's and falsePos's")
xlabel("false pos perc")
ylabel("correct pos perc")
axis([0 0.2 0 1])
