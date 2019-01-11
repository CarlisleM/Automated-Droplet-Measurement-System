% Create droplet area, centroid, length, width and radius arrays
for v = 1:maxDroplets
    if v <= height(stats)
        dropletTrackingX(totalFrameCounter,v) = stats.Centroid(v); % Store droplets x coordinate
        dropletTrackingY(totalFrameCounter,v) = stats.Centroid(v+height(stats)); % Store droplets y coordinate
        dropletDeformation(totalFrameCounter,v) = (stats.MajorAxisLength(v)-stats.MinorAxisLength(v))/(stats.MajorAxisLength(v)+stats.MinorAxisLength(v));
    else
        dropletTrackingX(totalFrameCounter,v) = 0;
        dropletTrackingY(totalFrameCounter,v) = 0;
        dropletDeformation(totalFrameCounter,v) = 0;
    end
end