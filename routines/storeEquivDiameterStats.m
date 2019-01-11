% Store information for each droplet on the current frame
for v = 1:maxDroplets
    if v <= height(stats)
        dropletDiameter(totalFrameCounter,v) = stats.MajorAxisLength(v); % Store droplets diameter
        dropletTrackingX(totalFrameCounter,v) = stats.Centroid(v); % Store droplets x coordinate
        dropletTrackingY(totalFrameCounter,v) = stats.Centroid(v+height(stats)); % Store droplets y coordinate
        if strcmp(dropletShape,'discoid') == 1
            
            disp('new droplet');
            disp('D');
            fprintf('%.3f\n',stats.MajorAxisLength(v));
            disp('h');
            fprintf('%.7f\n',channelHeight);
            disp('2*((1/16)^(1/3))');
            fprintf('%.3f\n',2*((1/16)^(1/3)));
            disp('2*stats.MajorAxisLength(v)^3');
            fprintf('%.3f\n',2*stats.MajorAxisLength(v)^3);
            disp('(stats.MajorAxisLength(v)-channelHeight)^2');
            fprintf('%.3f\n',(stats.MajorAxisLength(v)-channelHeight)^2);
            disp('2*stats.MajorAxisLength(v)+channelHeight');
            fprintf('%.3f\n',2*stats.MajorAxisLength(v)+channelHeight);
            disp('2*((1/16)^(1/3))*[(2*stats.MajorAxisLength(v)^3)-((stats.MajorAxisLength(v)-channelHeight)^2)*(2*stats.MajorAxisLength(v)+channelHeight)]');
            fprintf('%.3f\n',2*((1/16)^(1/3))*[(2*stats.MajorAxisLength(v)^3)-((stats.MajorAxisLength(v)-channelHeight)^2)*(2*stats.MajorAxisLength(v)+channelHeight)]);

            dropletEquivDiameter(totalFrameCounter,v) = 2*((1/16)^(1/3))*[(2*stats.MajorAxisLength(v)^3)-((stats.MajorAxisLength(v)-channelHeight)^2)*(2*stats.MajorAxisLength(v)+channelHeight)];
        else
            dropletEquivDiameter(totalFrameCounter,v) = sqrt((4*stats.Area(v))/pi);
        end
    end
end 