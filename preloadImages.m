function imageMap = preloadImages(stimulusData, wPtr)
    imageMap = containers.Map();
    for nTrial = 1:size(stimulusData.fileName, 1)
        for nStimulus = find([stimulusData.isImage(nTrial, :)])
            imageKey = stimulusData.fileName{nTrial, nStimulus};
            if ~isKey(imageMap, imageKey)
                imageData = struct('texture', NaN, 'width', NaN, 'height', NaN);
                [im, ~, a] = imread(imageKey);
                rgba = cat(3,im,a);
                imageData.texture = Screen('MakeTexture', wPtr, rgba);
                imageData.height = size(im, 1);
                imageData.width = size(im, 2);
                imageMap(imageKey) = imageData;
            end
        end
    end
end
