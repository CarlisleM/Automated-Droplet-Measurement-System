% Store information for each droplet on the current frame
for v = 1:maxDroplets
    if v <= height(stats)
        dropletArea(totalFrameCounter,v) = stats.Area(v); % Store droplets area
        dropletTrackingX(totalFrameCounter,v) = stats.Centroid(v); % Store droplets x coordinate
        dropletWidth(totalFrameCounter,v) = stats.MinorAxisLength(v); % Store droplets width
        dropletLength(totalFrameCounter,v) = stats.MajorAxisLength(v); % Store droplets length
        dropletDiameter(totalFrameCounter,v) = stats.MajorAxisLength(v); % Store droplets diameter
        dropletRadius(totalFrameCounter,v) = (stats.MajorAxisLength(v)/2); % Store droplets radius
        dropletTrackingY(totalFrameCounter,v) = stats.Centroid(v+height(stats)); % Store droplets y coordinate
        if strcmp(dropletShape,'discoid') == 1
            dropletEquivDiameter(totalFrameCounter,v) = 2*((1/16)^(1/3))*[(2*stats.MajorAxisLength(v)^3)-((stats.MajorAxisLength(v)-channelHeight)^2)*(2*stats.MajorAxisLength(v)+channelHeight)];
        else
            dropletEquivDiameter(totalFrameCounter,v) = sqrt((4*stats.Area(v))/pi);
        end
    end
end 
