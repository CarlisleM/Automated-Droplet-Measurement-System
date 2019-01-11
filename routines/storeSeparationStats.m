% Store information for each droplet on the current frame
for v = 1:maxDroplets
    if v <= height(stats)
        dropletRadius(totalFrameCounter,v) = (stats.MajorAxisLength(v)/2)*pixelRatio; % Store droplets radius
        dropletTrackingX(totalFrameCounter,v) = stats.Centroid(v); % Store droplets x coordinate
        dropletTrackingY(totalFrameCounter,v) = stats.Centroid(v+height(stats)); % Store droplets y coordinate
    end
end 
