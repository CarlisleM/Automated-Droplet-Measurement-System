% Calculate distance between droplet centroids
storedRadius = 0;
storedDroplet = 0;
storedTravelDistance = 0;
extraFrameCount = 0;

if strcmp(videoOrientation,'landscape') == 1
    for i = 1:length(dropletTrackingX)-1
        if ~isnan(mean(nonzeros(dropletTrackingX(i+1,:))))
            for v = 1:maxDroplets-1
                if storedDroplet == 0
                    if dropletTrackingX(i,v+1) - dropletTrackingX(i,v) > 0 & dropletTrackingX(i,v+1) - dropletTrackingX(i,v) ~= dropletTrackingX(i,v)
                        dropletDistanceBetween(i,v) = dropletTrackingX(i,v+1) - dropletTrackingX(i,v); 
                        dropletSeparation(i,v) = dropletTrackingX(i,v+1) - dropletTrackingX(i,v) - dropletRadius(i,v+1) - dropletRadius(i,v); 
                    else
                        dropletDistanceBetween(i,v) = 0;
                        dropletSeparation(i,v) = 0;
                    end
                else
                    if ((storedDroplet+(extraFrameCount*storedTravelDistance))-dropletTrackingX(i+1,v)) > 0
                        dropletDistanceBetween(i,v) = (storedDroplet+(extraFrameCount*storedTravelDistance))-dropletTrackingX(i+1,v);
                        dropletSeparation(i,v) = ((storedDroplet+(extraFrameCount*storedTravelDistance))-dropletTrackingX(i+1,v)) - storedRadius - dropletRadius(i+1,v);
                    end
                    storedRadius = 0;
                    storedDroplet = 0;
                    extraFrameCount = 0;
                    storedTravelDistance = 0;
                end
            end
        else
            if storedDroplet == 0 & storedTravelDistance == 0
                storedTravelDistance = dropletTravelDistance(i-1,1);
                storedDroplet = dropletTrackingX(i,1);
                storedRadius = dropletRadius(i,v);
            else
                dropletDistanceBetween(i,v) = 0;
                dropletSeparation(i,v) = 0;
            end
            
            extraFrameCount = extraFrameCount+1;
        end
    end
else
    for i = 1:length(dropletTrackingY)-1
        if ~isnan(mean(nonzeros(dropletTrackingY(i+1,:))))
            for v = 1:maxDroplets-1
                if storedDroplet == 0
                    if dropletTrackingY(i,v) - dropletTrackingY(i,v+1) > 0 & dropletTrackingY(i,v) - dropletTrackingY(i,v+1) ~= dropletTrackingY(i,v)
                        dropletDistanceBetween(i,v) = dropletTrackingY(i,v) - dropletTrackingY(i,v+1); 
                        dropletSeparation(i,v) = dropletTrackingY(i,v) - dropletTrackingY(i,v+1) - dropletRadius(i,v) - dropletRadius(i,v+1); 
                    else
                        dropletDistanceBetween(i,v) = 0;
                        dropletSeparation(i,v) = 0;
                    end
                else
                    if ((storedDroplet+(extraFrameCount*storedTravelDistance))-dropletTrackingY(i+1,v)) > 0
                        dropletDistanceBetween(i,v) = (storedDroplet+(extraFrameCount*storedTravelDistance))-dropletTrackingY(i+1,v);
                        dropletSeparation(i,v) = ((storedDroplet+(extraFrameCount*storedTravelDistance))-dropletTrackingY(i+1,v)) - storedRadius - dropletRadius(i+1,v); 
                    end
                    storedRadius = 0;
                    storedDroplet = 0;
                    extraFrameCount = 0;
                    storedTravelDistance = 0;
                end
            end
        else
            if storedDroplet == 0 & storedTravelDistance == 0
                storedTravelDistance = dropletTravelDistance(i-1,1);
                storedDroplet = dropletTrackingY(i,1);
                storedRadius = dropletRadius(i,v);
            else
                dropletDistanceBetween(i,v) = 0;
                dropletSeparation(i,v) = 0;
            end
            
            extraFrameCount = extraFrameCount+1;
        end        
    end
end
