function processedFrames = preprocess(sigContainer, frame, increment, shot_num, signalList)
%PREPROCESS do the prepocess. In this preprocess, we just use the
%instantaneous value of each signal. To achieve that, we actually calculate
%the mean value of each signal in a very short frame, like 5ms. 
%
% Author: Yichen Fu, Mar 16th 2018

    shotNum = str2num(shot_num);

    ipSignalTime = sigContainer('ip_time');
    beginTime = ipSignalTime(1);
    endTime = ipSignalTime(end);

    currTime = beginTime;

    processedFrames = [];

    % calculate feaeture for each frame
    while (currTime + frame) <= endTime

        isig = 1;
        shotFrameArray = [shotNum, currTime, currTime+frame, endTime - (currTime+frame)];

        % calculate features for each signals
        while isig <= length(signalList)
            sig = signalList(isig);

            sigDataChar = char(string(lower(sig))+"_data");
            sigTimeChar = char(string(lower(sig))+"_time");

            sigData = sigContainer(sigDataChar);
            sigTime = sigContainer(sigTimeChar);


            if ~isempty(sigTime)
                % Problem: this part can be changed by using find(). 
                % Yichen_3_1_2018
                [~, timeIndexStart] = min(abs(sigTime(:)- currTime));
                [~, timeIndexFinal] = min(abs(sigTime(:)- (currTime+frame)));

                meanSig = mean(sigData(timeIndexStart:timeIndexFinal));
                
                a = shotFrameArray;
                shotFrameArray = cat(2, a, meanSig);

            else
                a = shotFrameArray;
                errorArray = ones(1,1)*0.0;
                shotFrameArray = cat(2, a, errorArray);
            end

            isig = isig + 1;
        end
        processedFrames = cat(1, processedFrames, shotFrameArray);

        currTime = currTime + increment;
    end

end