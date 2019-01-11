fprintf('\nPixel ratio is calculated using (real length in micrometer)/(length in pixels)\n\nCurrent pixel ratio is: %.4f\n', pixelRatio);
try
    while pixelRatioChoice ~= 1  
        pixelRatioChoice = input('\nWould you like to change the pixel ratio? 1 for yes, press enter for no: ');
    end

    if pixelRatioChoice == 1
        try
            while ~isempty(pixelRatioChoice)
                pixelRatioChoice = input('\nPlease enter the pixel ratio: ');

                if ~isempty(pixelRatioChoice)
                    pixelRatio = pixelRatioChoice; 
                    break;
                end
            end
        catch
            % Repeat statement until valid input 
        end
    end
catch
    % Repeat statement until valid input
end
