
flowDirection = '';
checkDirection = [];

for k = 1:19
    if strcmp(videoOrientation,'landscape') == 1
        if ~isnan(mean(nonzeros(dropletTrackingX(k+1,:) - dropletTrackingX(k,:))))
           checkDirection(k,1) = mean(nonzeros(dropletTrackingX(k+1,:) - dropletTrackingX(k,:)));
        end
    else
        if ~isnan(mean(nonzeros(dropletTrackingY(k+1,:) - dropletTrackingY(k,:))))
           checkDirection(k,1) = mean(nonzeros(dropletTrackingY(k+1,:) - dropletTrackingY(k,:)));
        end
    end
end

checkPositiveNegative = sign(checkDirection);
positives = sum(checkPositiveNegative(:) == 1);
negatives = sum(checkPositiveNegative(:) == -1);

if positives > negatives
    if strcmp(videoOrientation,'landscape') == 1
        flowDirection = 'right';
    else
        flowDirection = 'down';
    end
else
    if strcmp(videoOrientation,'landscape') == 1
        flowDirection = 'left';    
    else
        flowDirection = 'up';
    end
    rotateVideo = 1;
    totalFrameCounter = 0;
    dropletVideo.CurrentTime = startOfVideo;
end
