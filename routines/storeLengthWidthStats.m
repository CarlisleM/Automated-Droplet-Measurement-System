% Store information for each droplet on the current frame
for v = 1:maxDroplets
    if v <= height(stats)
        dropletWidth(totalFrameCounter,v) = stats.MinorAxisLength(v)*pixelRatio; % Store droplets width
        dropletLength(totalFrameCounter,v) = stats.MajorAxisLength(v)*pixelRatio; % Store droplets length
        dropletTrackingX(totalFrameCounter,v) = stats.Centroid(v); % Store droplets x coordinate
        dropletTrackingY(totalFrameCounter,v) = stats.Centroid(v+height(stats)); % Store droplets y coordinate
    end
end 