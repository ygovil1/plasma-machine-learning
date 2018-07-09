function processedFrames = preprocess_window(sigContainer, frame, increment, shot_num, signalList)
%PREPROCESS do the prepocess. In this preprocess, we calculate the mean
%trend and varience for a given withdow. Not that if we want to do this, we
%usually choose a relatively large window, like 100ms.
%
% Author: Yichen Fu, Apr 2nd 2018

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
                % Problem: this part can be change by using find(). 
                % Yichen_3_1_2018
				[tempTS, timeIndexStart] = min(abs(sigTime(:)- currTime));
				[tempTF, timeIndexFinal] = min(abs(sigTime(:)- (currTime+frame)));
				
				meanSig_1o1 = meanComputation(sigData(timeIndexStart:timeIndexFinal));
				varSig_1o1 = varComputation(sigData(timeIndexStart:timeIndexFinal));
				trendSig_1o1 = trendComputation(sigData(timeIndexStart:timeIndexFinal), sigTime(timeIndexStart), sigTime(timeIndexFinal));
				
				halfAdd = floor((timeIndexFinal-timeIndexStart) / 2.0);
				
				meanSig_1o2 = meanComputation(sigData(timeIndexStart:timeIndexStart+halfAdd));
				varSig_1o2 = varComputation(sigData(timeIndexStart:timeIndexStart+halfAdd));
				trendSig_1o2 = trendComputation(sigData(timeIndexStart:timeIndexStart+halfAdd), sigTime(timeIndexStart), sigTime(timeIndexStart+halfAdd));
				meanSig_2o2 = meanComputation(sigData(timeIndexStart+halfAdd:timeIndexFinal));
				varSig_2o2 = varComputation(sigData(timeIndexStart+halfAdd:timeIndexFinal));
				trendSig_2o2 = trendComputation(sigData(timeIndexStart+halfAdd:timeIndexFinal), sigTime(timeIndexStart+halfAdd), sigTime(timeIndexFinal));
				
				thirdAdd = floor((timeIndexFinal-timeIndexStart) / 3.0);
				
				meanSig_1o3 = meanComputation(sigData(timeIndexStart:timeIndexStart+thirdAdd));
				varSig_1o3 = varComputation(sigData(timeIndexStart:timeIndexStart+thirdAdd));
				trendSig_1o3 = trendComputation(sigData(timeIndexStart:timeIndexStart+thirdAdd), sigTime(timeIndexStart), sigTime(timeIndexStart+thirdAdd));
				meanSig_2o3 = meanComputation(sigData(timeIndexStart+thirdAdd:timeIndexStart+2.0*thirdAdd));
				varSig_2o3 = varComputation(sigData(timeIndexStart+thirdAdd:timeIndexStart+2.0*thirdAdd));
				trendSig_2o3 = trendComputation(sigData(timeIndexStart+thirdAdd:timeIndexStart+2.0*thirdAdd), sigTime(timeIndexStart+thirdAdd), sigTime(timeIndexStart+2.0*thirdAdd));
				meanSig_3o3 = meanComputation(sigData(timeIndexStart+2.0*thirdAdd:timeIndexFinal));
				varSig_3o3 = varComputation(sigData(timeIndexStart+2.0*thirdAdd:timeIndexFinal));
				trendSig_3o3 = trendComputation(sigData(timeIndexStart+2.0*thirdAdd:timeIndexFinal), sigTime(timeIndexStart+2.0*thirdAdd), sigTime(timeIndexFinal));
				
                % Problem: fifth add might be zero. Need to be double check.
                % Yichen_3_1_2018
				fifthAdd = floor((timeIndexFinal-timeIndexStart) / 5.0);
				
				meanSig_1o5 = meanComputation(sigData(timeIndexStart:timeIndexStart+fifthAdd));
				varSig_1o5 = varComputation(sigData(timeIndexStart:timeIndexStart+fifthAdd));
				trendSig_1o5 = trendComputation(sigData(timeIndexStart:timeIndexStart+fifthAdd), sigTime(timeIndexStart), sigTime(timeIndexStart+fifthAdd));
				meanSig_2o5 = meanComputation(sigData(timeIndexStart+fifthAdd:timeIndexStart+2.0*fifthAdd));
				varSig_2o5 = varComputation(sigData(timeIndexStart+fifthAdd:timeIndexStart+2.0*fifthAdd));
				trendSig_2o5 = trendComputation(sigData(timeIndexStart+fifthAdd:timeIndexStart+2.0*fifthAdd), sigTime(timeIndexStart+fifthAdd), sigTime(timeIndexStart+2.0*fifthAdd));
				meanSig_3o5 = meanComputation(sigData(timeIndexStart+2.0*fifthAdd:timeIndexStart+3.0*fifthAdd));
				varSig_3o5 = varComputation(sigData(timeIndexStart+2.0*fifthAdd:timeIndexStart+3.0*fifthAdd));
				trendSig_3o5 = trendComputation(sigData(timeIndexStart+2.0*fifthAdd:timeIndexStart+3.0*fifthAdd), sigTime(timeIndexStart+2.0*fifthAdd), sigTime(timeIndexStart+3.0*fifthAdd));
				meanSig_4o5 = meanComputation(sigData(timeIndexStart+3.0*fifthAdd:timeIndexStart+4.0*fifthAdd));
				varSig_4o5 = varComputation(sigData(timeIndexStart+3.0*fifthAdd:timeIndexStart+4.0*fifthAdd));
				trendSig_4o5 = trendComputation(sigData(timeIndexStart+3.0*fifthAdd:timeIndexStart+4.0*fifthAdd), sigTime(timeIndexStart+3.0*fifthAdd), sigTime(timeIndexStart+4.0*fifthAdd));
				meanSig_5o5 = meanComputation(sigData(timeIndexStart+4.0*fifthAdd:timeIndexFinal));
				varSig_5o5 = varComputation(sigData(timeIndexStart+4.0*fifthAdd:timeIndexFinal));
				trendSig_5o5 = trendComputation(sigData(timeIndexStart+4.0*fifthAdd:timeIndexFinal), sigTime(timeIndexStart+4.0*fifthAdd), sigTime(timeIndexFinal));
				
				a = shotFrameArray;
				shotFrameArray = cat(2, a, [meanSig_1o1, varSig_1o1, trendSig_1o1, meanSig_1o2, varSig_1o2, trendSig_1o2, meanSig_2o2, varSig_2o2, trendSig_2o2, ...
											meanSig_1o3, varSig_1o3, trendSig_1o3, meanSig_2o3, varSig_2o3, trendSig_2o3, meanSig_3o3, varSig_3o3, trendSig_3o3, ...
											meanSig_1o5, varSig_1o5, trendSig_1o5, meanSig_2o5, varSig_2o5, trendSig_2o5, meanSig_3o5, varSig_3o5, trendSig_3o5, meanSig_4o5, varSig_4o5, trendSig_4o5, meanSig_5o5, varSig_5o5, trendSig_5o5]);
			
			else
				a = shotFrameArray;
				errorArray = ones(1,33)*0.0;
				%disp("size(a), size(errorArray) " + size(a) + " " + size(errorArray))
				shotFrameArray = cat(2, a, errorArray);
			end

            isig = isig + 1;
        end
        processedFrames = cat(1, processedFrames, shotFrameArray);

        currTime = currTime + increment;
    end

end

% ========== define functions  ==========

%functions need to be at the end of the script, for some reason
function meanComp = meanComputation(inputArray)
	meanComp = mean(inputArray);
end

function varComp = varComputation(inputArray)
	varComp = std(inputArray);
end

function trendComp = trendComputation(inputArray, startTime, finalTime)
	trendComp = (inputArray(length(inputArray)) - inputArray(1)) / (finalTime - startTime);
	%if inputArray(length(inputArray)) == NaN || inputArray(1) == NaN
	%	trendComp = 0
	%end
end
