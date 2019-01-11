%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This program allows the user to crop a videos area and save the file %
%                                                                      %
% Written by Carlisle Miller                                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
clc;
clear;
close all;
clear vars;
fclose('all');

% Select video
disp('Select your video(s)');
[FileName,PathName] = uigetfile('MultiSelect', 'on', '*.avi', 'Select video');
[filePath,fileIdentifier,fileExtension] = fileparts(mfilename('fullpath'));
cd(PathName);

% In case only one video is selected
if iscell(FileName) == 1
   lastFile = length(FileName); 
else
    lastFile = 1;
end

for fileCount=1:lastFile
    
    % In case only one video is selected
    if iscell(FileName)==1
        currentFileName=FileName{fileCount};
    else
        currentFileName=FileName;
    end
    
    newFileName = strcat(currentFileName,' Cropped');
    
    % Initialise Reader and Writer
    videoFile = strcat(PathName,currentFileName);
    videoFReader = VideoReader(videoFile);
    videoFWriter = VideoWriter(newFileName,'Uncompressed AVI');
    open(videoFWriter); % Open the video file to write to

    i = 1;
    fprintf('Currently processing %s\n', currentFileName);
    
    while hasFrame(videoFReader)
        fprintf('Frame: %i\n', i);  % Display frame the proces is up to
        frames = readFrame(videoFReader);   % Read current frame

        % Display first frame to allow user to draw the crop area
        if i == 1 && fileCount == 1
            warning('off','images:initSize:adjustingMag');
            imshow(frames);
            cropArea = imrect;
            position = wait(cropArea);
            close all;
        end

        % Crop the current frame
        croppedFrame = imcrop(frames,[position(1) position(2) position(3) position(4)]);
        writeVideo(videoFWriter,croppedFrame)   % Write the current frame to the new video
        i = i+1;
    end
    
end

disp('Finished.');

close(videoFWriter)
