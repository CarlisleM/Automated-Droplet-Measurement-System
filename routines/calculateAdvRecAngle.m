% Get droplet advancing and receding angles
[B,L,N,A] = bwboundaries(BW);

currentDroplet = 1;

for k = 1:length(B)
    
    findAdvAngle = 0;
    findRecAngle = 0;
    
    yMinimum = min(B{k}(:,1));      % y min
    yMaximum = max(B{k}(:,1));      % y max
    xMinimum = min(B{k}(:,2));      % x min 
    xMaximum = max(B{k}(:,2));      % x max
    
    if strcmp(videoOrientation,'landscape') == 1
        if xMinimum < dropletTrackingX(totalFrameCounter,currentDroplet) & xMaximum > dropletTrackingX(totalFrameCounter,currentDroplet) & yMinimum < dropletTrackingY(totalFrameCounter, currentDroplet) & yMaximum > dropletTrackingY(totalFrameCounter, currentDroplet)
            % Calculations to determine advancing and receding angle point of interests
            symmetryLine = yMaximum-round((yMaximum-yMinimum)/2);  % line of symmetry
            finalValue = symmetryLine+round((symmetryLine-yMinimum)/sqrt(2)); % where minimum is the furtherest parallel line value from symmetry line
            
            % Coordinates of the left most center point of the droplet
            centerStartPoint = find(B{k}(:,1) == symmetryLine & B{k}(:,2) < dropletTrackingX(totalFrameCounter,currentDroplet));
            centerStartPointCoordinates = B{k}(centerStartPoint(1),:);

            % Coordinates of the receding angle point of interest
            recValue = find(B{k}(:,1) == finalValue & B{k}(:,2) < dropletTrackingX(totalFrameCounter,currentDroplet));
            recValueCoordinates = B{k}(recValue(end),:);

            % Coordinates opposite of the receding angle point of interest
            oppositeRecValue = find(B{k}(:,2) == recValueCoordinates(2) & B{k}(:,2) < dropletTrackingX(totalFrameCounter,currentDroplet) & B{k}(:,1) < dropletTrackingY(totalFrameCounter,currentDroplet));
            oppositeRecValueCoordinates = B{k}(oppositeRecValue(1),:);
            
            % Coordinates of the right most center point of the droplet
            centerEndPoint = find(B{k}(:,1) == symmetryLine & B{k}(:,2) > dropletTrackingX(totalFrameCounter,currentDroplet));
            centerEndPointCoordinates = B{k}(centerEndPoint(1),:);

            % Coordinates of the advancing angle point of interest
            advValue = find(B{k}(:,1) == finalValue & B{k}(:,2) > dropletTrackingX(totalFrameCounter,currentDroplet));
            advValueCoordinates = B{k}(advValue(1),:);
            
            % Coordinates opposite of the advancing angle point of interest
            oppositeAdvValue = find(B{k}(:,2) == advValueCoordinates(2) & B{k}(:,2) > dropletTrackingX(totalFrameCounter,currentDroplet) & B{k}(:,1) < dropletTrackingY(totalFrameCounter,currentDroplet));
            oppositeAdvValueCoordinates = B{k}(oppositeAdvValue(1),:);

            % Calculate x0 for the receding angle
            y0 = centerStartPointCoordinates(1);
            x0 = round(centerStartPointCoordinates(2)+((((((recValueCoordinates(1)-oppositeRecValueCoordinates(1))/2)^2)-((centerStartPointCoordinates(2)-oppositeRecValueCoordinates(2))^2))/(2*(centerStartPointCoordinates(2)-oppositeRecValueCoordinates(2))))*-1));

            % Calculate x0 for the advancing angle
            advy0 = centerEndPointCoordinates(1);
            advx0 = round(centerEndPointCoordinates(2)-((((((advValueCoordinates(1)-oppositeAdvValueCoordinates(1))/2)^2)-((centerEndPointCoordinates(2)-oppositeRecValueCoordinates(2))^2))/(2*(centerEndPointCoordinates(2)-oppositeRecValueCoordinates(2))))*-1));
            
            % Calculate advancing and receding angle
            advAngle = atand((advValueCoordinates(1)-y0)/(advValueCoordinates(2)-advx0))+90;
            recAngle = atand((recValueCoordinates(1)-y0)/(x0-recValueCoordinates(2)))+90;  % toa: -tan(opposite/adjacent)+90 degrees due to being perpendicular
            
            currentDroplet = currentDroplet+1;
        end
    else
        if xMinimum < dropletTrackingX(totalFrameCounter,currentDroplet) & xMaximum > dropletTrackingX(totalFrameCounter,currentDroplet) & yMinimum < dropletTrackingY(totalFrameCounter, currentDroplet) & yMaximum > dropletTrackingY(totalFrameCounter, currentDroplet)
            % Calculations to determine advancing and receding angle point of interests
            symmetryLine = xMaximum-round((xMaximum-xMinimum)/2);  % line of symmetry
            finalValue = symmetryLine-round((symmetryLine-xMinimum)/sqrt(2)); % where minimum is the furtherest parallel line value from symmetry line
            
            % Coordinates of the top most center point of the droplet
            centerStartPoint = find(B{k}(:,2) == symmetryLine & B{k}(:,1) < dropletTrackingY(totalFrameCounter,k));
            centerStartPointCoordinates = B{k}(centerStartPoint(1),:);

            % Coordinates of the receding angle point of interest
            recValue = find(B{k}(:,2) == finalValue & B{k}(:,1) < dropletTrackingY(totalFrameCounter,k));
            recValueCoordinates = B{k}(recValue(1),:);

            % Coordinates opposite of the receding angle point of interest
            oppositeRecValue = find(B{k}(:,1) == recValueCoordinates(1) & B{k}(:,1) < dropletTrackingY(totalFrameCounter,k) & B{k}(:,2) > dropletTrackingX(totalFrameCounter,k));
            oppositeRecValueCoordinates = B{k}(oppositeRecValue(1),:);       

            % Coordinates of the bottom most center point of the droplet
            centerEndPoint = find(B{k}(:,2) == symmetryLine & B{k}(:,1) > dropletTrackingY(totalFrameCounter,k));
            centerEndPointCoordinates = B{k}(centerEndPoint(1),:);
            
            % Coordinates of the advancing angle point of interest
            advValue = find(B{k}(:,2) == finalValue & B{k}(:,1) > dropletTrackingY(totalFrameCounter,k));
            advValueCoordinates = B{k}(advValue(1),:);
            
            % Coordinates opposite of the advancing angle point of interest
            oppositeAdvValue = find(B{k}(:,1) == advValueCoordinates(1) & B{k}(:,1) > dropletTrackingY(totalFrameCounter,k) & B{k}(:,2) > dropletTrackingX(totalFrameCounter,k));
            oppositeAdvValueCoordinates = B{k}(oppositeAdvValue(1),:);   

            % Calculate y0 for the receding angle
            x0 = centerStartPointCoordinates(2);
            y0 = round(centerStartPointCoordinates(1)+((((((oppositeRecValueCoordinates(2)-recValueCoordinates(2))/2)^2)-((centerStartPointCoordinates(1)-oppositeRecValueCoordinates(1))^2))*-1)/(2*(centerStartPointCoordinates(1)-oppositeRecValueCoordinates(1)))));
            
            % Calculate x0 for the advancing angle
            advx0 = centerEndPointCoordinates(2);
            advy0 = round(centerEndPointCoordinates(1)-((((((oppositeRecValueCoordinates(2)-recValueCoordinates(2))/2)^2)-((centerEndPointCoordinates(1)-oppositeRecValueCoordinates(1))^2))*-1)/(2*(centerEndPointCoordinates(1)-oppositeRecValueCoordinates(1))))); 
            
            % Calculate advancing and receding angle
            advAngle = atand((advValueCoordinates(1)-y0)/(advValueCoordinates(2)-advx0))+90;
            recAngle = atand((recValueCoordinates(1)-y0)/(x0-recValueCoordinates(2)))+90;  % toa: -tan(opposite/adjacent)+90 degrees due to being perpendicular

            currentDroplet = currentDroplet+1;
        end
    end
    
    dropletAdvAngle(totalFrameCounter,k) = advAngle; % Store droplets advancing angle
    dropletRecAngle(totalFrameCounter,k) = recAngle; % Store droplets receding angle
    
end

