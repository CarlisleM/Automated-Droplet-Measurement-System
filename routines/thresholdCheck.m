if totalFrameCounter == 1
    widthCheck = [];
    lengthCheck = [];
    
    fprintf('\nCurrent threshold value is: %.2f\n', thresholdValue);
    
    % Read the first frame and save the start time to revert back to after threshold check
    startOfVideo = dropletVideo.CurrentTime;
    frames = readFrame(dropletVideo);
    DropletChannel = frames;
    
    try
        convertBW;
        imshow(BW);

        while thresholdingChoice ~= 1  
            thresholdingChoice = input('\nWould you like to change the threshold? 1 for yes, press enter for no: ');
        end

        if thresholdingChoice == 1
            try
                while ~isempty(thresholdingChoice) 
                    thresholdingChoice = input('\nPlease enter the threshold value (between 0 and 1): ');
                    if ~isempty(thresholdingChoice) 
                        thresholdValue = thresholdingChoice;
                    end
                    convertBW;
                    imshow(BW);
                end
            catch
                % Repeat statement until valid input 
            end
        end
    catch
        % Repeat statement until valid input
    end
    
    close all
    
    % Obtain stats to determine pixel ratio and if droplets are discoids
    stats = regionprops('table', BW, 'Area', 'MajorAxisLength', 'MinorAxisLength'); 
    toDelete = stats.Area < max(stats.Area)*0.75;   % Delete non-droplets
    stats(toDelete,:) = [];

    for i = 1:height(stats)
       widthCheck = [widthCheck, stats.MinorAxisLength(i)];
       lengthCheck =  [lengthCheck, stats.MajorAxisLength(i)];
    end
    
    minimumDropletSize = round(max(stats.Area)*0.75);
    
    avgWidthCheck = mean(widthCheck);
    avgLengthCheck = mean(lengthCheck);
    
    if avgLengthCheck-avgWidthCheck > 3 
       dropletShape = 'discoid';
    else
        dropletShape = 'circle';
    end
    
    dropletVideo.CurrentTime = startOfVideo;
end
