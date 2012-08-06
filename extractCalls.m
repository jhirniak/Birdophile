%Extracts bird calls from the recording
%Reads data from wav or mat file
%Values of threshold for recognizing bird call (0.2 of the max value) and
%data points for one significant bird call - 6000/combined(6000-10000)
%were choosen basing on experiment and careful observation of many
%different recordings. The current values seem to detect calls very well
%and those omited are most often too short or too noisy to generate proper
%MFCCs values to make a recognition of bird accurate.
function give = extractCalls(data)
%Use one channel (eliminate stereo)
data = data(:,1);

%Eliminate data that is below threshold, which is 0.20 of max peak,
%0.20*max was chosen experminentally and works very nicely
maxes = find(data(:,1) > max(data(:,1))*.2);

%Differenciate to measure the power (change in sound)
distances = [1; diff(maxes)];

%Define the max distance between values to be defined inside one bird tweet
%(one sample)
maxdist = 8*mean(distances);

%Define callbreaks from maxdist, include the beginning of recording
callbreaks = find(distances > maxdist);
callbreaks = [1; callbreaks];

%sound(data(maxes(callbreaks(1)):maxes(callbreaks(2)-1)))
%Point at the beginning of recording
calls = struct([]);
pointer = 1;
for i=1:length(callbreaks)/2    %i=1:amount_of_intervals
    x1 = maxes(callbreaks(i*2-1));  %define the beginning of the tweet (sample interval)
    x2 = maxes(callbreaks(i*2)-1);  %define the end
    if x2 - x1 > 6000   %if tweet (sample) is long enough to be significant evaluate, the values were chosen experimentaly and works well
            %eval(['calls' '.s' num2str(pointer) '=data(x1:x2,1);']); 
            calls(pointer).call = data(x1:x2,1);
            pointer = pointer + 1;
    elseif 2*i+2 < length(callbreaks) %take a trial to integrate with a tweet (sample interval) from close proximity
            x1 = maxes(callbreaks(i*2-1));
            x2 = maxes(callbreaks(i*2)-1);
            x3 = maxes(callbreaks(i*2+1));
            x4 = maxes(callbreaks(i*2+2)-1);
            if (x3 - x2 < 10000) && (x4 - x1 > 6000)
                %eval(['calls' '.s' num2str(pointer) '=data(x1:x4,1);']);
                calls(pointer).call=data(x1:x4,1);
                pointer = pointer + 1;
            end
            i = i + 1; %increment i, to not include the recording from close proximity (already used in the integration trial)
    end
        
end

give = calls;

end