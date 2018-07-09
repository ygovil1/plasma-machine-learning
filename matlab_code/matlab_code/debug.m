shot_num_debug = 160938;

rawdatacontainer = nonDisruptShotContainer(char(num2str(shot_num_debug)));

len = length(signalList);


for i = 1:1
    sig_debug = char(signalList(i) + "_data");
    time_debug = char(signalList(i) + "_time");
    
    figure(i)
    plot(rawdatacontainer(time_debug),rawdatacontainer(sig_debug))
    title(signalList(i))
%     xlim([0,8])
end