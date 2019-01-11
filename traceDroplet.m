%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the main m-file that processes the droplet video file        %
%                                                                      %
% Written by Carlisle Miller                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                          PART 1: INITIALISATIONS                     %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

tic
clc;
clear;
close all;
clear vars;
fclose('all');

% Change directory to the directory getDropletArea.m is located in
if(~isdeployed)
  cd(fileparts(which(mfilename)));
  path('routines',path); % Directory containing the functions used
end

rotateVideo = 0;
dropletCount = 0;
channelHeight = 1;
pixelRatio = 2.862; % Default value (user can change)
thresholdValue = 0.3; % Default value (user can change)
pixelRatioChoice = 0;
totalFrameCounter = 1;    
thresholdingChoice = 0;

dropletArea = zeros(1,5);

% User selects video and name is stored in 'FileName'
disp('Select your video(s)');
[FileName,PathName] = uigetfile('MultiSelect', 'on', '*.avi', 'Select droplet video'); 
[filePath,fileIdentifier,fileExtension] = fileparts(mfilename('fullpath'));

% In case only one video is selected
if iscell(FileName) == 1
   lastFile = length(FileName); 
else
    lastFile = 1;
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                   PART 2: LOAD AND READ THE VIDEO                    %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
 
stepValue = 29;
currentStepFrame = 1+stepValue;
initialStep = 1;

for fileCount=1:lastFile
    % In case only one video is selected
    if iscell(FileName)==1
        currentFileName=FileName{fileCount};
    else
        currentFileName=FileName;
    end
    
    % Read video and store information
    videoFile = strcat(PathName,currentFileName);
    dropletVideo = VideoReader(videoFile);
    
    videoDuration = dropletVideo.Duration;    
    videoFrameRate = dropletVideo.FrameRate;
    timePerFrame = videoDuration*100/(videoFrameRate*floor(videoDuration));

    thresholdCheck; % Displays the first frame to the user and prompts the user to adjust the threshold value

    % Determine video orientation
    if dropletVideo.Width > dropletVideo.Height
        videoOrientation = 'landscape';
    else
        videoOrientation = 'portrait';
    end

    % Start of main loop
    while hasFrame(dropletVideo)
        fprintf('Frame: %i\n', totalFrameCounter);

        frames = readFrame(dropletVideo);   % Read current frame
        convertBW;    % Setting up image for calculations

        % Obtain information for each droplet on the current frame
        stats = regionprops('table', BW, 'Area', 'Centroid', 'MajorAxisLength', 'MinorAxisLength'); 
        toDelete = stats.Area < max(stats.Area)*0.75;   % Delete non-droplets
        stats(toDelete,:) = [];
        
       disp(totalFrameCounter);
       disp(currentStepFrame);
       
        if totalFrameCounter == 1
        	img1 = BW;
        elseif totalFrameCounter == currentStepFrame
            if initialStep == 1
                disp('entered 1');
                C = imfuse(img1,BW,'blend','scaling','none');
                currentStepFrame = currentStepFrame+stepValue;
                initialStep = 0;
            else
                disp('entered 2');
                C = imfuse(C,BW,'blend','scaling','none');
                currentStepFrame = currentStepFrame+stepValue;
            end
        else 
            % Nothing
        end

        % Store information for each droplet on the current frame
        storeAllStats;
        calculateAdvRecAngle;

        % Once 20 frames have been read, determine flow direction and rotate video if needed
        if totalFrameCounter == 20
            determineFlowDirection;
        end
        
        if totalFrameCounter == 1
           initialDropletCount = height(stats);
        end
        
        totalFrameCounter = totalFrameCounter+1;
    end
    totalFrameCounter = totalFrameCounter-1;    % Remove extra frame added at the end of the loop
end

imshow(C);

fprintf('Total number of droplets: %i\n',dropletCount);
fclose('all');
toc
