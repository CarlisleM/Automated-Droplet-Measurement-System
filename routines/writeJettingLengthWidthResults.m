% Count number of droplets and write length and width results to the corresponding droplet text files
dropletCount = initialDropletCount;
currentDroplets = [];   % Contains the droplets that are on the current frame
if strcmp(videoOrientation,'landscape') == 1    % Video is in landscape view
    for i=1:totalFrameCounter-1 % Number of frames - 1
        if nnz(dropletTrackingX(i,:)) == nnz(dropletTrackingX(i+1,:)) % If same number of droplets
            dropletDifference = dropletTrackingX(i+1,:) - dropletTrackingX(i,:); % Check difference in x coordinates
            onlyCountOnce = 0;
            for v = 1:maxDroplets
                if dropletDifference(v) < 0 % Same size but new droplet
                    if onlyCountOnce == 0
                        if dropletTrackingX(i+1,v+1) - dropletTrackingX(i,v) > 0 & dropletTrackingX(i+1,v+1) - dropletTrackingX(i,v) < mean(nonzeros(dropletSeparation(i,:)))*1.5
                           % disp('pair meets criteria');
                        else
                            onlyCountOnce = 1;
                            dropletCount = dropletCount+1;  % Increase droplet count
                            fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
                        end
                    end
                end
            end
        else
            if nnz(dropletTrackingX(i,:)) < nnz(dropletTrackingX(i+1,:)) % If array size increases
                if nnz(dropletTrackingX(i-1,:)) == nnz(dropletTrackingX(i+1,:))
                    for v = 1:maxDroplets
                        if dropletTrackingX(i+1,v) - dropletTrackingX(i-1,v) > 0
                            if mean(nonzeros(dropletTravelDistance(i+1,:)))*2.5 - (dropletTrackingX(i+1,v) - dropletTrackingX(i-1,v)) > 0
                                % droplet disappeared and reappeared, dont add to the droplet count
                            end
                        end
                    end
                else
                    dropletCount = dropletCount+1;
                    fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
                end
            end        
        end    

        % Determine which droplets are on the current frame
        for j = dropletCount-nnz(dropletTrackingX(i,:))+1:dropletCount
            currentDroplets = [currentDroplets, j];
        end

        % Append droplet length and width to appropriate droplet txt file
        for k = 1:length(currentDroplets)
            dropletFileID = fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth',sprintf('/droplet_%i.txt',currentDroplets(length(currentDroplets)+1-k))),'a');
            fprintf(dropletFileID,'%.3f\t%.3f\t', dropletLength(i,k)*pixelRatio, dropletWidth(i,k)*pixelRatio);
        end
        
        currentDroplets = [];   % Reset variable  
        fclose('all');  % Close all droplet txt files currently open
    end
else   % Video is in portrait view
    for i=1:totalFrameCounter-1 % Number of frames - 1
        if nnz(dropletTrackingY(i,:)) == nnz(dropletTrackingY(i+1,:)) % If same number of droplets
            dropletDifference = dropletTrackingY(i+1,:) - dropletTrackingY(i,:); % Check difference in x coordinates
            onlyCountOnce = 0;
            % Check the change in each droplet in the array
            for v = 1:maxDroplets
                if dropletDifference(v) < 0 % Same size but new droplet
                    if onlyCountOnce == 0
                        if dropletTrackingY(i+1,v+1) - dropletTrackingY(i,v) > 0 & dropletTrackingY(i+1,v+1) - dropletTrackingY(i,v) < mean(nonzeros(dropletSeparation(i,:)))*1.5
                           % disp('pair meets criteria');
                        else
                            onlyCountOnce = 1;
                            dropletCount = dropletCount+1;  % Increase droplet count
                            fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
                        end
                    end
                end
            end
        else   % Size of array changed
            if nnz(dropletTrackingY(i,:)) < nnz(dropletTrackingY(i+1,:)) % If array size increases
                if nnz(dropletTrackingY(i-1,:)) == nnz(dropletTrackingY(i+1,:))
                    for v = 1:maxDroplets
                        if dropletTrackingY(i+1,v) - dropletTrackingY(i-1,v) > 0
                            if mean(nonzeros(dropletTravelDistance(i+1,:)))*2.5 - (dropletTrackingY(i+1,v) - dropletTrackingY(i-1,v)) > 0
                                % droplet disappeared and reappeared, dont add to the droplet count
                            end
                        end
                    end
                else
                    dropletCount = dropletCount+1;
                    fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
                end
            end 
        end      
        
        % Determine which droplets are on the current frame
        for j = dropletCount-nnz(dropletTrackingY(i,:))+1:dropletCount
            currentDroplets = [currentDroplets, j];
        end

        % Append droplet length and width to appropriate droplet txt file
        for k = 1:length(currentDroplets)
            dropletFileID = fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth',sprintf('/droplet_%i.txt',currentDroplets(length(currentDroplets)+1-k))),'a');
            fprintf(dropletFileID,'%.3f\t%.3f\t', dropletLength(i,k)*pixelRatio, dropletWidth(i,k)*pixelRatio);
        end
        
        currentDroplets = [];   % Reset variable  
        fclose('all');  % Close all droplet txt files currently open
    end
end

% Get droplet width average and standard deviation
avgWidth = mean(nonzeros(dropletWidth));
stdevWidth = std(nonzeros(dropletWidth));

% Get droplet length average and standard deviation
avgLength = mean(nonzeros(dropletLength));
stdevLength = std(nonzeros(dropletLength));

% Create txt file containing number of droplets, average length and width, and length and width stdev
lengthWidthResultsID = fopen(strcat('Results_Jetting_',currentFileName,'/LengthWidth','/length_width_results.txt'),'wt');
fprintf(lengthWidthResultsID,'Number of droplets detected: %i\t Average length: %.3f\t Length standard deviation: %.3f\t Average width: %.3f\t Width standard deviation: %.3f\t', dropletCount*pixelRatio, avgLength*pixelRatio, stdevLength*pixelRatio, avgWidth*pixelRatio, stdevWidth*pixelRatio);

