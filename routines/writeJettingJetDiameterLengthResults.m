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
                            fopen(strcat('Results_Jetting_',currentFileName,'/JetLengthDiameter',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
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
                    fopen(strcat('Results_Jetting_',currentFileName,'/JetLengthDiameter',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
                end
            end        
        end    

        % Determine which droplets are on the current frame
        for j = dropletCount-nnz(dropletTrackingX(i,:))+1:dropletCount
            currentDroplets = [currentDroplets, j];
        end

        % Append droplet diameter and diameter to appropriate droplet txt file
        for k = 1:length(currentDroplets)
            dropletFileID = fopen(strcat('Results_Jetting_',currentFileName,'/JetLengthDiameter',sprintf('/droplet_%i.txt',currentDroplets(length(currentDroplets)+1-k))),'a');
            fprintf(dropletFileID,'%.3f\t%.3f\t', jetLength(i,k)*pixelRatio, jetDiameter(i,k)*pixelRatio);
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
                            fopen(strcat('Results_Jetting_',currentFileName,'/JetLengthDiameter',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
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
                    fopen(strcat('Results_Jetting_',currentFileName,'JetLengthDiameter',sprintf('/droplet_%i.txt',dropletCount)),'wt'); % Create new droplet txt file
                end
            end 
        end      
        
        % Determine which droplets are on the current frame
        for j = dropletCount-nnz(dropletTrackingY(i,:))+1:dropletCount
            currentDroplets = [currentDroplets, j];
        end

        % Append droplet diameter and diameter to appropriate droplet txt file
        for k = 1:length(currentDroplets)
            dropletFileID = fopen(strcat('Results_Jetting_',currentFileName,'/JetLengthDiameter',sprintf('/droplet_%i.txt',currentDroplets(length(currentDroplets)+1-k))),'a');
            fprintf(dropletFileID,'%.3f\t%.3f\t', jetLength(i,k)*pixelRatio, jetDiameter(i,k)*pixelRatio);
        end
        
        currentDroplets = [];   % Reset variable  
        fclose('all');  % Close all droplet txt files currently open
    end
end

% Get droplet diameter average and standard deviation
avgDiameter = mean(nonzeros(jetDiameter));
stdevDiameter = std(nonzeros(jetDiameter));

% Get droplet diameter average and standard deviation
avgJetLength = mean(nonzeros(jetLength));
stdevJetLength = std(nonzeros(jetLength));

% Create txt file containing number of droplets, average diameter and diameter, and diameter and diameter stdev
lengthDiameterResultsID = fopen(strcat('Results_Jetting_',currentFileName,'/JetLengthDiameter','/length_width_results.txt'),'wt');
fprintf(lengthDiameterResultsID,'Number of droplets detected: %i\t Average diameter: %.3f\t Diameter standard deviation: %.3f\t Average diameter: %.3f\t Diameter standard deviation: %.3f\t', dropletCount*pixelRatio, avgJetLength*pixelRatio, stdevJetLength*pixelRatio, avgJetDiameter*pixelRatio, stdevJetDiameter*pixelRatio);

