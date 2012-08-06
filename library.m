%Generate library file with birds profiles using MFCCs method
%no commands inserted - interactive mode
%commands supported in text file - execute instructions from file
%For command file format see the last lines of this m-file
function loadFile = library(instructionFile)

switch nargin
    %interactive mode
    case 0
        %Select database file to work with
        [FileName,PathName,~] = uiputfile({'*.mat','MATLAB Data File (*.mat)'},'Choose library file to create / update','birdsProfiles.mat');
        %Check if file exist and if yes then append data by loading the
        %file into memory and operating with a new data on it
        loadFile = which([PathName FileName]);
        if(~isempty(loadFile))
            eval(['load ' loadFile]);
        end
        %Initialize struct
        birdsProfiles.birds = {};
        %While loop starts here
        outerLoop = 'y';
        while(outerLoop ~= 'n')
            %Gets info about bird
            bird.code = input('Specify Bird Code: ','s');
            bird.latin = input('Specify Bird Latin Name: ','s');
            bird.english = input('Specify Bird English Name: ','s');
            if(~findStringInStruct(birdsProfiles.birds,bird.code))
                eval(['birdsProfiles.birds=[birdsProfiles.birds ''' bird.code '''];']);
                eval(['birdsProfiles.' bird.code '.samples=0;']);
                eval(['birdsProfiles.' bird.code '.name.latin=''' bird.latin ''';']);
                eval(['birdsProfiles.' bird.code '.name.english=''' bird.english ''';']);
                %Loads and saves picture for the bird
                [IFileName, IPathName,~] = uigetfile('*.bmp;*.jpg;*.jpeg;*.png;*.tiff', ['Select ' bird.english ' picture file...']);
                pic = imread([IPathName IFileName]); %Variable pic is used in eval() in the line below
                eval(['birdsProfiles.' bird.code '.picture=pic;']);
            end
            
            %Inner while loop for one bird starts here
            innerLoop = 'y'; %i = 1;
            while(innerLoop ~= 'n')
                %Asks for recording
                [RFileName,RPathName,RFilterIndex] = uiputfile({'*.wav','Waveform Audio File Format (*.wav)';'*.mat','MATLAB Data File (*.mat)';'*','Pattern maching WAV files by prefix, specify only the prefix'},['Open ' bird.english ' recording...']);
                %if FilderIndex is 3 (use pattern matching), then create
                %pattern matching RFileName expression
                switch (RFilterIndex)
                    %Read wav file
                    case 1
                        files = RFileName;
                        file = wavread([RPathName RFileName]);
                    %Read mat file
                    case 2
                        files = RFileName;
                        file = load([RPathName RFileName]);
                    %Read all files matching the XYZ*.wav pattern
                    case 3
                        files = dir([RFileName '*.wav']);
                end
                %Execute for file by file
                for k=1:length(files)
                    if (RFilterIndex == 3)
                        file = wavread([RPathName files(k).name]);
                    end
                    calls = extractCalls(file);
                    for j=1:length(calls)
                        %eval(['mfccs = getMFCCs(calls.s' num2str(j) ');']);
                        mfccs = getMFCCs(calls(j).call);
                        %average with other inputs
                        fieldExist = eval(['isfield(birdsProfiles.' bird.code ', ''mfccs'')']);
                        if(fieldExist)
                            %eval(['dimensions = min(size(birdsProfiles.' bird.code '.mfccs),size(mfccs));']);
                            %x = zeros(max(size(a,1),size(b,1)),max(size(a,2),size(b,2)));
                            %x(1:size(a,1),1:size(a,2))=a;
                            %x(1:size(b,1),1:size(b,2))=x(1:size(b,1),1:size(b,2))+b;
                            eval(['oldMfccs = birdsProfiles.' bird.code '.mfccs;']);
                            eval(['samples = birdsProfiles.' bird.code '.samples;']);
                            [i1 i2] = size(mfccs);
                            [m1 m2] = size(oldMfccs);
                            newMfccs = zeros(max(i1,m1),max(i2,m2));
                            newMfccs(1:m1,1:m2) = oldMfccs;
                            newMfccs(1:i1,1:i2) = newMfccs(1:i1,1:i2)*samples + mfccs;
                            eval(['samples = birdsProfiles.' bird.code '.samples + 1;']);
                            newMfccs(1:i1,1:i2) = newMfccs(1:i1,1:i2) / (samples+1); %Variable newMfccs is used in eval() in the line below
                            eval(['birdsProfiles.' bird.code '.mfccs=newMfccs;']);
                            eval(['birdsProfiles.' bird.code '.samples=samples+1;']);
                        else
                            eval(['birdsProfiles.' bird.code '.mfccs = mfccs;']);
                            eval(['birdsProfiles.' bird.code '.samples=1;']);
                        end
                    end
                end
                innerLoop = input(['Do you want read one more input for ' bird.english '? [y]/n '],'s');
                %i = i + 1;
            end
            outerLoop = input('Do you want read another bird? [y]/n ','s');
        end
        %eval(['save ' birdsProfiles FileName ' -mat']);
        eval(sprintf('save %s %s -mat',FileName,'birdsProfiles'));
    %commands from file mode
    case 1
        %operate on file
        fid = fopen(instructionFile);
        outputFile = fgetl(fid);
        %initalize
        birdsProfiles.birds = {};
        %Append data
        loadFile = which(outputFile);
        if(~isempty(loadFile))
            eval(['load ' loadFile]);
        end
        next = fgetl(fid);
        while (ischar(next))
            %eval something
            bird.code = next;
            bird.latin = fgetl(fid);
            bird.english = fgetl(fid);
            if(~findStringInStruct(birdsProfiles.birds,bird.code))
                eval(['birdsProfiles.birds=[birdsProfiles.birds ''' bird.code '''];']);
                eval(['birdsProfiles.' bird.code '.samples=0;']);
                eval(['birdsProfiles.' bird.code '.name.latin=''' bird.latin ''';']);
                eval(['birdsProfiles.' bird.code '.name.english=''' bird.english ''';']);
            end
            %Read first line with recording name
            next = fgetl(fid);
            while (ischar(next) && ~isempty(regexpi(next,'.wav'))) %Checks if it is recording
                %gets files from expression
                files = dir(next);
                %Execute for each file
                for k=1:length(files)
                    file = files(k).name;
                    %Read the wav file
                    wavFile = wavread(file);
                    %Extract calls from file
                    calls = extractCalls(wavFile);
                    %Compute for each call
                    for j=1:length(calls)
                        mfccs = getMFCCs(calls(j).call);
                        %average with other inputs
                        fieldExist = eval(['isfield(birdsProfiles.' bird.code ', ''mfccs'');']);
                        if(fieldExist)
                            eval(['oldMfccs = birdsProfiles.' bird.code '.mfccs;']);
                            [i1 i2] = size(mfccs);
                            [m1 m2] = size(oldMfccs);
                            newMfccs = zeros(max(i1,m1),max(i2,m2));
                            newMfccs(1:m1,1:m2) = oldMfccs;
                            newMfccs(1:i1,1:i2) = newMfccs(1:i1,1:i2) + mfccs;
                            eval(['samples = birdsProfiles.' bird.code '.samples + 1;']);
                            newMfccs(1:i1,1:i2) = newMfccs(1:i1,1:i2) / samples; %Variable newMfccs is used in eval() in the line below
                            eval(['birdsProfiles.' bird.code '.mfccs=newMfccs;']);
                            eval(['birdsProfiles.' bird.code '.samples=samples+1;']);
                        else
                            eval(['birdsProfiles.' bird.code '.mfccs = mfccs;']);
                            eval(['birdsProfiles.' bird.code '.samples=1;']);
                        end
                    end
                end
                %Loads next file path
                next = fgetl(fid);
                
            end
        end
        %Save obtained results to defined file
        eval(sprintf('save %s %s -mat',outputFile,'birdsProfiles'));
        fclose(fid);
        disp (['Finish processing to ' outputFile]);
end

end

%---file format---
%Output File
%Bird Code
%Bird Latin Name
%Bird English Name
%Path to record_1
%Path to record_2
%Path to record_3
%Bird Code
%Bird Latin Name
%Bird English Name
%Path to record_1
%Path to record_2
%Path to record_3
%Bird Code
%Bird Latin Name
%Bird English Name
%Path to record_1
%Path to record_2
%Path to record_3
%...
%...
%...