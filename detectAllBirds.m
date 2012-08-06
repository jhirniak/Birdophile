%Main function of the app
function detectAllBirds()
%Load birds profiles
try
    load('birdsProfiles.mat');
catch exception
    createDisplay(700,140);
    text(0.47,0.55,'No birdsProfiles.mat file found','HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',36,'FontName','Myriad Pro','Color',[.9725 .2863 .2863]);
    text(0.47,0.45,'in local directory.','HorizontalAlignment','center','VerticalAlignment','top','FontSize',36,'FontName','Myriad Pro','Color',[.9725 .2863 .2863]);
    return;
end
%Select file with bird recording; accepted files: wav, mat; and read it
[FileName,PathName,~] = uigetfile({'*.wav';'*.mat'},'Choose Recording...');
wavFile = wavread([PathName,FileName]);
%Extract calls
calls = extractCalls(wavFile);
c = length(calls);

if (c < 1) %No calls found in the recording, display notificatino and stop the script
    createDisplay(500,100);
    text(0.5,0,'No calls detected.','HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',36,'FontName','Myriad Pro','Color',[.9725 .2863 .2863]);
    return;
end

%Generate MFCCs struct for all calls
sample(c).mfccs = 0;
for i=1:c
    sample(i).mfccs = getMFCCs(calls(i).call);
end

%Compare sample MFCCs with birds profiles MFCCs
%Matrix format columns - consecutive birds, rows - consecutive calls
%Allocate storage matrix
b = length(birdsProfiles.birds);
A = zeros(c,b);
for i=1:b %bird profile number
    y=0;
    eval(['y = birdsProfiles.' char(birdsProfiles.birds(i)) '.mfccs,']);
    for j=1:c %call sample number
        x = sample(j).mfccs;
        p = [min(size(x,1),size(y,1)) min(size(x,2),size(y,2))];
        similarity = compareMFCCs(x(1:p(1),1:p(2)),y(1:p(1),1:p(2)));
        if(similarity==Inf)
            A(j,i) = 10^3;
        else
            A(j,i) = similarity;
        end
    end
end

%Recognize all birds and display figures for them
for i=1:length(A)
    answer.index = find(A(i,:) == min(A(i,:)));
    answer.code=birdsProfiles.birds(answer.index);
    %Set the display
    createDisplay(600,500);
    %Retrieve bird's picture
    eval(['answer.image = birdsProfiles.' char(answer.code) '.picture;']);
    image(answer.image); axis off;
    %Compute text position
    answer.text.y = max(size(answer.image,1))+2;
    answer.text.x = max(size(answer.image,2))/2;
    answer.text.birdname.latin = '';
    answer.text.birdname.english = '';
    %Obtain text
    eval(['answer.text.birdname.latin = birdsProfiles.' char(answer.code) '.name.latin;']);
    eval(['answer.text.birdname.english = birdsProfiles.' char(answer.code) '.name.english;']);
    %Display text
    text(answer.text.x,answer.text.y,['Bird recognized in call no ' num2str(i)],'HorizontalAlignment','center','VerticalAlignment','bottom','FontSize',18,'FontName','Myriad Pro','BackGroundColor',[0 .251 .4235],'Color',[.9725 .2863 .2863]);
    text(answer.text.x,answer.text.y+2,[char(answer.text.birdname.latin) ' (' char(answer.text.birdname.english) ')'],'HorizontalAlignment','center','VerticalAlignment','top','FontSize',18,'FontName','Myriad Pro','FontAngle','Italic','BackGroundColor',[0 .251 .4235],'Color',[.8471 .8471 .8471]);
end
end