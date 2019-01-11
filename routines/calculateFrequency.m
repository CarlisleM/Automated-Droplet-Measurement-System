% Calculate droplet frequency
for i = 1:length(dropletDistanceBetween)-1
    for v = 1:nnz(dropletDistanceBetween(i,:))
        if dropletDistanceBetween(i+1,v) ~= 0 & mean(nonzeros(dropletTravelDistance(i,:))) ~= 0
            travelTime = (dropletDistanceBetween(i+1,v)/mean(nonzeros(dropletTravelDistance(i,:))))*(timeArray(i,2)-timeArray(i,1));
            if ~isnan(travelTime)
                dropletFrequency(i,v) = 1000/travelTime;
                dropletVelocity(i,v) = (mean(nonzeros(dropletTravelDistance(i,:))))/(timeArray(i,2)-timeArray(i,1));
            else
                dropletVelocity(i,v) = 0;
                dropletFrequency(i,v) = 0;
            end
        else
            dropletVelocity(i,v) = 0;
            dropletFrequency(i,v) = 0;
        end

        if isnan(dropletFrequency) | isinf(dropletFrequency)
           dropletVelocity(i,v) = 0;
           dropletFrequency(i,v) = 0; 
        end    
    end    
end
