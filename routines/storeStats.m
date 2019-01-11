% Store droplet centroids
for v = 1:maxDroplets
    if v <= height(stats)
        dropletTrackingX(totalFrameCounter,v) = stats.Centroid(v); % Store droplets x coordinate
        dropletTrackingY(totalFrameCounter,v) = stats.Centroid(v+height(stats)); % Store droplets y coordinate
    end
end 
