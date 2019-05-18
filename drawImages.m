function drawImages(wPtr, imageMap, fileNames, widths, heights, hOffsets, ...
                    vOffsets, xc, yc)
    for iImage = 1:length(fileNames)
        imageWidth = widths(iImage);
        imageHeight = heights(iImage);
        imageStruct = imageMap(fileNames{iImage});
        if (isnan(imageWidth) || isempty(imageWidth)) && (isnan(imageHeight) || isempty(imageHeight))
            imageWidth = imageStruct.width;
            imageHeight = imageStruct.height;
        elseif (isnan(imageWidth) || isempty(imageWidth)) && ~(isnan(imageHeight) || isempty(imageHeight))
            imageWidth = imageHeight/imageStruct.height*imageStruct.width;
        elseif ~(isnan(imageWidth) || isempty(imageWidth)) && (isnan(imageHeight) || isempty(imageHeight))
            imageHeight = imageWidth/imageStruct.width*imageStruct.height;
        end
        dispRect = [0 0 imageWidth imageHeight];
        finalRect = CenterRectOnPoint(dispRect, xc + hOffsets(iImage), ...
            yc + vOffsets(iImage));
        Screen('DrawTexture', wPtr, imageStruct.texture, ...
            [], finalRect);
    end
end
