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
channelHeight = 1;
pixelRatio = 2.862; % Default value (user can change)
thresholdValue = 0.3; % Default value (user can change)
pixelRatioChoice = 0;
totalFrameCounter = 1;    
thresholdingChoice = 0;

dropletArea = zeros(1,maxDroplets);
dropletWidth = zeros(1,maxDroplets);
dropletLength = zeros(1,maxDroplets);
dropletRadius = zeros(1,maxDroplets);
dropletVelocity = zeros(1,maxDroplets);
dropletAdvAngle = zeros(1,maxDroplets);
dropletRecAngle = zeros(1,maxDroplets);
dropletFrequency = zeros(1,maxDroplets-1);
dropletTrackingX = zeros(1,maxDroplets);
dropletTrackingY = zeros(1,maxDroplets);
dropletSeparation = zeros(1,maxDroplets-1);
dropletEquivDiameter = zeros(1,maxDroplets);
dropletTravelDistance = zeros(1,maxDroplets);
dropletDistanceBetween = zeros(1,maxDroplets-1);
timeArray = zeros(1,2);

% In case only one video is selected
if iscell(FileName) == 1
   lastFile = length(FileName); 
else
    lastFile = 1;
end

% Get channel height from user
try
    channelHeight = input('\nPlease enter the channel height: ');
    while isempty(channelHeight)
        channelHeight = input('\nPlease enter the channel height: ');
    end
catch
    % Repeat statement until valid input 
end

pixelRatioCheck; % Displays the pixel ratio and prompts the user to adjust the ratio

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                   PART 2: LOAD AND READ THE VIDEO                    %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

for fileCount=1:lastFile
    totalFrameCounter = 1;
    
    % In case only one video is selected
    if iscell(FileName)==1
        currentFileName=FileName{fileCount};
    else
        currentFileName=FileName;
    end
    
    % Create folders and files and set up headers
    warning('off','MATLAB:MKDIR:DirectoryExists');  % Block warning saying directory or text file already exists
    mkdir(filePath, strcat('Results_Area_',currentFileName)); % Create a folder to store results
    mkdir(filePath, strcat('Results_Frequency_',currentFileName));
    mkdir(filePath, strcat('Results_Separation_',currentFileName));
    mkdir(filePath, strcat('Results_LengthWidth_',currentFileName));
    mkdir(filePath, strcat('Results_AdvRecAngle_',currentFileName));
    mkdir(filePath, strcat('Results_EquivDiameter_',currentFileName));
    
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

        % imshow(BW); % Uncomment this to show every frame as the video processes

        % Store information for each droplet on the current frame
        storeAllStats;
        calculateAdvRecAngle;

        % Once 20 frames have been read, determine flow direction and rotate video if needed
        if totalFrameCounter == 20
            determineFlowDirection;
        end
        
        if totalFrameCounter == 1
           initialDropletCount = height(stats);
           % Resets intial text files for the first frame
           for i = 1:height(stats)
                fopen(strcat('Results_Area_',currentFileName,sprintf('/droplet_%i.txt',i)),'wt');
                fopen(strcat('Results_Frequency_',currentFileName,sprintf('/droplet_%i.txt',i)),'wt');
                fopen(strcat('Results_LengthWidth_',currentFileName,sprintf('/droplet_%i.txt',i)),'wt');
                fopen(strcat('Results_AdvRecAngle_',currentFileName,sprintf('/droplet_%i.txt',i)),'wt');
                fopen(strcat('Results_EquivDiameter_',currentFileName,sprintf('/droplet_%i.txt',i)),'wt');
                fopen(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',i,i+1)),'wt');
           end
        end
        
        
        totalFrameCounter = totalFrameCounter+1;
    end
    totalFrameCounter = totalFrameCounter-1;    % Remove extra frame added at the end of the loop
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                       PART X: CALCULATIONS                           %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

calculateTravelDistance;            % Store how far each droplet travels each frame
calculateDistanceBetweenDroplets;   % Calculate distance between droplet centroids  
calculateFrequency;

% Count the number of droplets, create txt files and store results
writeAreaResults;
writeFrequencyResults;
writeSeparationResults;
writeLengthWidthResults;
writeAdvRecAngleResults;
writeEquivDiameterResults;

% Create txt file containing number of droplets, average length and width, and length and width stdev
allResultsID = fopen('all_results.txt','wt');
fprintf(allResultsID,'Number of droplets detected: %i\t Average Area: %.3f\t Area standard deviation: %.3f\t Average length: %.3f\t Length standard deviation: %.3f\t Average width: %.3f\t Width standard deviation: %.3f\t Average separation: %.3f\t Separation standard deviation: %.3f\t Average frequency: %.3f\t Frequency standard deviation: %.3f\t ', dropletCount, avgArea*pixelRatio, stdevArea*pixelRatio, avgLength*pixelRatio, stdevLength*pixelRatio, avgWidth*pixelRatio, stdevWidth*pixelRatio, avgSeparation*pixelRatio, stdevSeparation*pixelRatio, avgFrequency, stdevFrequency);

fprintf('Total number of droplets: %i\n',dropletCount);
fclose('all');
toc
