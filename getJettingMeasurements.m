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

videoType = 'Jetting';

rotateVideo = 0;
dropletCount = 0;
pixelRatio = 2.862; % Default value (user can change)
thresholdValue = 0.3; % Default value (user can change)
pixelRatioChoice = 0;
totalFrameCounter = 1;    
thresholdingChoice = 0;

jettingArray = zeros(1,1);
dropletWidth = zeros(1,maxDroplets);
dropletLength = zeros(1,maxDroplets);
dropletVelocity = zeros(1,maxDroplets);
dropletFrequency = zeros(1,maxDroplets-1);
dropletTrackingX = zeros(1,maxDroplets);
dropletTrackingY = zeros(1,maxDroplets);
dropletSeparation = zeros(1,maxDroplets-1);

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

for fileCount=1:lastFile
    % In case only one video is selected
    if iscell(FileName)==1
        currentFileName=FileName{fileCount};
    else
        currentFileName=FileName;
    end
    
    % Create folders and files and set up headers
    warning('off','MATLAB:MKDIR:DirectoryExists');  % Block warning saying directory or text file already exists
    mkdir(filePath, strcat('Results_Jetting_',currentFileName)); % Create a folder to store results
    mkdir(filePath, strcat('Results_Jetting_',currentFileName,'/Frequency'));
    mkdir(filePath, strcat('Results_Jetting_',currentFileName,'/Separation'));
    mkdir(filePath, strcat('Results_Jetting_',currentFileName,'/LengthWidth'));
    mkdir(filePath, strcat('Results_Jetting_',currentFileName,'/JetLengthDiameter'));
    
    % Read video and store information
    videoFile = strcat(PathName,currentFileName);
    dropletVideo = VideoReader(videoFile);
    
    videoDuration = dropletVideo.Duration;    
    videoFrameRate = dropletVideo.FrameRate;
    timePerFrame = videoDuration*100/(videoFrameRate*floor(videoDuration));
    
    if totalFrameCounter == 1
        startOfVideo = dropletVideo.CurrentTime;
        frames = readFrame(dropletVideo);
        DropletChannel = frames;
        
        disp('select 2 points in line with the start of the jet and then press enter');
        figure
        imshow(DropletChannel);
        [x,y] = getpts;
        croppedImage = imcrop(DropletChannel,[1, round(mean(y)), dropletVideo.Width, dropletVideo.Height]);   
    end
        
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
        convertJettingBW;    % Setting up image for calculations

        % Obtain information for each droplet on the current frame
        stats = regionprops('table', BW, 'Area', 'Centroid', 'MajorAxisLength', 'MinorAxisLength', 'BoundingBox'); 
        toDelete = stats.Area < max(stats.Area)*0.3;   % Delete non-droplets
        stats(toDelete,:) = [];
        
        v = 1;
        
        for z = 1:height(stats)
            if ismember(0.5, stats.BoundingBox(z,:)) 
                if strcmp(videoOrientation,'landscape') == 1
                    jettingArray(totalFrameCounter,1) = stats.MajorAxisLength(z)-mean(x);
                else
                    jettingArray(totalFrameCounter,1) = stats.MajorAxisLength(z)-mean(y);
                end
                jettingArray(totalFrameCounter,2) = stats.MinorAxisLength(z);
            else
                dropletTrackingX(totalFrameCounter,v) = stats.Centroid(z); % Store droplets x coordinate
                dropletWidth(totalFrameCounter,v) = stats.MinorAxisLength(z); % Store droplets width
                dropletLength(totalFrameCounter,v) = stats.MajorAxisLength(z); % Store droplets length
                dropletRadius(totalFrameCounter,v) = (stats.MajorAxisLength(z)/2); % Store droplets radius
                dropletTrackingY(totalFrameCounter,v) = stats.Centroid(z+height(stats)); % Store droplets y coordinate
                v = v+1;
            end
        end
        
        % Once 20 frames have been read, determine flow direction and rotate video if needed
        if totalFrameCounter == 20
            determineFlowDirection;
        end
        
        if totalFrameCounter == 1
           initialDropletCount = height(stats);
           for i = 1:height(stats)
                fopen(strcat('Results_Jetting_',currentFileName,'/Frequency',sprintf('/droplet_%i.txt',i),'wt'));
                fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth',sprintf('/droplet_%i.txt',i),'wt'));
                fopen(strcat('Results_Jetting_',currentFileName,'/Separation',sprintf('/droplet_%i-%i.txt',i,i+1),'wt'));
           end
        end
        
        totalFrameCounter = totalFrameCounter+1;
    end
    totalFrameCounter = totalFrameCounter-1;    % Remove extra frame added at the end of the loop
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%
%                       PART X: CALCULATIONS                           %
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%

% Count the number of droplets, create txt files and store results
calculateTravelDistance;            % Store how far each droplet travels each frame
calculateDistanceBetweenDroplets;   % Calculate distance between droplet centroids  
calculateFrequency;
writeJettingFrequencyResults;
writeJettingSeparationResults;
writeJettingLengthWidthResults;

% Get droplet velocity average and standard deviation
avgVelocity = mean(nonzeros(dropletVelocity));
stdevVelocity = std(nonzeros(dropletVelocity));

% Create txt file containing number of droplets, average length and width, and length and width stdev
jettingResultsID = fopen(strcat('Results_Jetting_',currentFileName,'/all_results.txt','wt'));
fprintf(jettingResultsID,'Number of droplets detected: %i\t Average length: %.3f\t Length standard deviation: %.3f\t Average width: %.3f\t Width standard deviation: %.3f\t Average separation: %.3f\t Separation standard deviation: %.3f\t Average frequency: %.3f\t Frequency standard deviation: %.3f\t Max Jet Length: %.3f\t Max Jet Diameter: %.3f\t', dropletCount, avgLength, stdevLength, avgWidth, stdevWidth, avgSeparation, stdevSeparation, avgFrequency, stdevFrequency, max(jettingArray(:,1)), max(jettingArray(:,2)));

disp('Producing droplet text files.');

fclose('all');
toc
