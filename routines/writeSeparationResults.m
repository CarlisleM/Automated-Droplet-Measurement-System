% Count number of droplets and write separation results to the corresponding droplet text files
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
                            fopen(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',dropletCount,dropletCount+1)),'wt'); % Create new droplet txt file
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
                    fopen(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',dropletCount,dropletCount+1)),'wt'); % Create new droplet txt file
                end
            end        
        end    
        
        % Determine which droplets are on the current frame
        for j = dropletCount-nnz(dropletTrackingX(i,:))+1:dropletCount
            currentDroplets = [currentDroplets, j];
        end

        % Append droplet separation to appropriate droplet txt file
        for k = 1:length(currentDroplets)-1
            dropletFileID = fopen(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',currentDroplets(length(currentDroplets)-k),currentDroplets(length(currentDroplets)+1-k))),'a');
            try
                if dropletSeparation(i,k) ~= 0
                    fprintf(dropletFileID,'%.3f\t', dropletSeparation(i,k)*pixelRatio);
                end
            catch
                % Index exceeds matrix dimensions
            end
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
                            fopen(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',dropletCount,dropletCount+1)),'wt'); % Create new droplet txt file
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
                    fopen(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',dropletCount,dropletCount+1)),'wt'); % Create new droplet txt file
                end
            end 
        end      

        % Determine which droplets are on the current frame
        for j = dropletCount-nnz(dropletTrackingY(i,:))+1:dropletCount
            currentDroplets = [currentDroplets, j];
        end

        % Append droplet separation to appropriate droplet txt file
        for k = 1:length(currentDroplets)-1
            dropletFileID = fopen(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',currentDroplets(length(currentDroplets)-k),currentDroplets(length(currentDroplets)+1-k))),'a');
            try
                if dropletSeparation(i,k) ~= 0
                    fprintf(dropletFileID,'%.3f\t', dropletSeparation(i,k)*pixelRatio);
                end
            catch
                % Index exceeds matrix dimensions
            end
        end
        
        currentDroplets = [];   % Reset variable  
        fclose('all');  % Close all droplet txt files currently open
    end
end

delete(strcat('Results_Separation_',currentFileName,sprintf('/droplet_%i-%i.txt',dropletCount, dropletCount+1)));	% Remove extra txt file

% Get droplet separation average and standard deviation
avgSeparation = mean(nonzeros(dropletSeparation));
stdevSeparation = std(nonzeros(dropletSeparation));

% Create txt file containing number of droplets, average separation, and separation stdev
separationResultsID = fopen(strcat('Results_Separation_',currentFileName,'/separation_results.txt'),'wt');
fprintf(separationResultsID,'Number of droplets detected: %i\t Average separation: %.3f\t Separation standard deviation: %.3f\t', dropletCount, avgSeparation*pixelRatio, stdevSeparation*pixelRatio);

