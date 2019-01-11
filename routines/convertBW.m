% Setting up image for calculations
BW = im2bw(frames, thresholdValue);
BW = ~BW; % Invert binary matrix BW
BW = imfill(BW,'holes'); % Fills holes in the image      
BW = imclearborder(BW); % Remove droplets that are on the edge

if totalFrameCounter >= 2
     BW = bwareaopen(BW, minimumDropletSize);    % Remove smaller areas that aren't droplets
end

if rotateVideo == 1
   BW = imrotate(BW,180); 
end
