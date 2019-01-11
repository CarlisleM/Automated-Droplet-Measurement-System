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

% Change directory to the directory getDropletDeformation.m is located in
if(~isdeployed)
  cd(fileparts(which(mfilename)));
  path('routines',path); % Directory containing the functions used
end

% User selects video and name is stored in 'FileName'
disp('Select your video(s)');
[FileName,PathName] = uigetfile('MultiSelect', 'on', '*.avi', 'Select droplet video'); 
[filePath,fileIdentifier,fileExtension] = fileparts(mfilename('fullpath'));

% Get maximum amount of droplets
try
    maxDroplets = input('\nPlease enter the maximum amount of droplets possible on a frame (If you are unsure of the exact number, enter something higher): ');
    while isempty(maxDroplets)
        maxDroplets = input('\nPlease enter the maximum amount of droplets possible on a frame (If you are unsure of the exact number, enter something higher): ');
    end
catch
    % Repeat statement until valid input 
end

rotateVideo = 0;
dropletCount = 0;
pixelRatio = 2.862; % Default value (user can change)
thresholdValue = 0.48; % Default value (user can change)
pixelRatioChoice = 0;
totalFrameCounter = 1;    
thresholdingChoice = 0;

dropletTrackingX = zeros(1,maxDroplets);
dropletTrackingY = zeros(1,maxDroplets);
dropletDeformation = zeros(10,maxDroplets);

% In case only one video is selected
if iscell(FileName) == 1
   lastFile = length(FileName); 
else
    lastFile = 1;
end

pixelRatioCheck; % Displays the pixel ratio and prompts the user to adjust the ratio

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                   PART 2: LOAD AND READ THE VIDEO                    %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

for fileCount = 1:lastFile
    % In case only one video is selected
    if iscell(FileName) == 1
        currentFileName = FileName{fileCount};
    else
        currentFileName = FileName;
    end
    
    % Create folders and files and set up headers
    warning('off','MATLAB:MKDIR:DirectoryExists');  % Block warning saying directory or text file already exists
    mkdir(filePath, strcat('Results_Deformation_',currentFileName)); % Create a folder to store results
    
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
 
        % Store information for each droplet on the current frame
        storeDeformationStats;
        
        % Once 20 frames have been read, determine flow direction and rotate video if needed
        if totalFrameCounter == 20
            determineFlowDirection;
        end
        
        if totalFrameCounter == 1
           initialDropletCount = height(stats);
           for i = 1:height(stats)
                fopen(strcat('Results_Deformation_',currentFileName,sprintf('/droplet_%i.txt',i),'wt'));
           end
        end
        
        totalFrameCounter = totalFrameCounter+1;
    end
    totalFrameCounter = totalFrameCounter-1;    % Remove extra frame added at the end of the loop
end

calculateTravelDistance;

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                       PART X: CALCULATIONS                           %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Count the number of droplets, create txt files and store results
writeDeformationResults;

fclose('all');
toc
