if strcmp(videoOrientation,'landscape') == 1
    BW = imcrop(frames,[round(mean(x)), 1, dropletVideo.Width, dropletVideo.Height]);
else
    BW = imcrop(frames,[1, round(mean(y)), dropletVideo.Width, dropletVideo.Height]);    
end

BW = im2bw(BW, thresholdValue);
BW = ~BW; % Invert binary matrix BW

BW = padarray(BW,[1 1],1,'pre');	% Pad top of image with white pixels
BW = imfill(BW,'holes');            % Fill holes
BW = BW(2:end,2:end);               % Remove padding

BW = padarray(BW,[1 0],0,'pre');	% Pad side containing jet
BW = imclearborder(BW);         	% Clear objects touching the border
BW = BW(2:end,2:end-1);             % Remove the outline

if totalFrameCounter == 2
    imshow(BW);
end

if totalFrameCounter >= 2
    BW = bwareaopen(BW, minimumDropletSize);    % Remove smaller areas that aren't droplets
end

if rotateVideo == 1
   BW = imrotate(BW,180); 
end

close all;