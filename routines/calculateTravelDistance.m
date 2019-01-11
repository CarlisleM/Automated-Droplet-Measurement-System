% Store the distance travelled by each droplet between frames
storedTime = 0;

if strcmp(videoOrientation,'landscape') == 1
    for i = 1:length(dropletTrackingX)-1
        for v = 1:maxDroplets-1
            if nnz(dropletTrackingX(i+1,:)) == nnz(dropletTrackingX(i,:))   % If same size array
                if dropletTrackingX(i+1,v)-dropletTrackingX(i,v) > 0
                    dropletTravelDistance(i,v) = (dropletTrackingX(i+1,v)-dropletTrackingX(i,v));
                    timeArray(i,1) = i*timePerFrame;
                    timeArray(i,2) = (i+1)*timePerFrame;
                end
            elseif nnz(dropletTrackingX(i+1,:)) > nnz(dropletTrackingX(i,:))    % If array size grows
                if dropletTrackingX(i+1,v+1)-dropletTrackingX(i,v) > 0
                    dropletTravelDistance(i,v) = (dropletTrackingX(i+1,v+1)-dropletTrackingX(i,v));     
                    timeArray(i,1) = i*timePerFrame;
                    timeArray(i,2) = (i+1)*timePerFrame;
                end
            else
                if dropletTrackingX(i+1,v)-dropletTrackingX(i,v) > 0
                    dropletTravelDistance(i,v) = (dropletTrackingX(i+1,v)-dropletTrackingX(i,v));
                    timeArray(i,1) = i*timePerFrame;
                    timeArray(i,2) = (i+1)*timePerFrame;
                else
                    dropletTravelDistance(i,v) = 0;
                    if storedTime == 0
                        storedTime = i*timePerFrame;
                    end
                end
            end
        end
    end
else
	for i = 1:length(dropletTrackingY)-1
        for v = 1:maxDroplets-1
            if nnz(dropletTrackingY(i+1,:)) == nnz(dropletTrackingY(i,:))   % If same size array or array shrinks
                if dropletTrackingY(i+1,v)-dropletTrackingY(i,v) > 0
                    dropletTravelDistance(i,v) = (dropletTrackingY(i+1,v)-dropletTrackingY(i,v)); % Store droplets y coordinate  
                    timeArray(i,1) = i*timePerFrame;
                    timeArray(i,2) = (i+1)*timePerFrame;
                end
            elseif nnz(dropletTrackingY(i+1,:)) > nnz(dropletTrackingY(i,:))    % If array size grows
                if storedTime == 0
                    if dropletTrackingY(i+1,v+1)-dropletTrackingY(i,v) > 0
                        dropletTravelDistance(i,v) = (dropletTrackingY(i+1,v+1)-dropletTrackingY(i,v));  
                        timeArray(i,1) = i*timePerFrame;
                        timeArray(i,2) = (i+1)*timePerFrame;
                    end
                else
                    if v == 1
                        dropletTravelDistance(i,v) = (dropletTrackingY(i+1,v+1)-dropletTrackingY(i,v));  
                        timeArray(i,1) = storedTime;
                        timeArray(i,2) = (i+1)*timePerFrame;
                    end
                    storedTime = 0;
                end
            else
                if dropletTrackingY(i+1,v)-dropletTrackingY(i,v) > 0
                    dropletTravelDistance(i,v) = (dropletTrackingY(i+1,v)-dropletTrackingY(i,v));
                    timeArray(i,1) = i*timePerFrame;
                    timeArray(i,2) = (i+1)*timePerFrame;
                else
                    dropletTravelDistance(i,v) = 0;
                    if storedTime == 0
                        storedTime = i*timePerFrame;
                    else
                        timeArray(i,1) = 0;
                        timeArray(i,2) = 0;
                    end
                end           
            end
        end
	end
end

