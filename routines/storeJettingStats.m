% Store information for each droplet on the current frame
v = 1;

%dropletArea(totalFrameCounter,v) = stats.Area(v); % Store droplets area
dropletTrackingX(totalFrameCounter,v) = stats.Centroid(v); % Store droplets x coordinate
dropletWidth(totalFrameCounter,v) = stats.MinorAxisLength(v); % Store droplets width
dropletLength(totalFrameCounter,v) = stats.MajorAxisLength(v); % Store droplets length
dropletRadius(totalFrameCounter,v) = (stats.MajorAxisLength(v)/2); % Store droplets radius
dropletTrackingY(totalFrameCounter,v) = stats.Centroid(v+height(stats)); % Store droplets y coordinate

v = v+1;