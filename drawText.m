function drawText(wPtr, fileNames, textWidth, textHeight, hOffsets, vOffsets, xc, yc, ScreenCoords)

    vSpacing = [];
    for iText = 1:length(fileNames)
        if isnan(textWidth(iText)) || textWidth(iText) == 0
            textWidth = ScreenCoords(3);
        end
        if isnan(textHeight(iText)) || textHeight(iText) == 0
            textHeight = ScreenCoords(4);
        end
        dispRect = [0 0 textWidth(iText), textHeight(iText)];
        finalRect = CenterRectOnPoint(dispRect, xc + hOffsets(iText), ...
            yc + vOffsets(iText));
        [nx, ny, textbounds, wordbounds] = DrawFormattedText(wPtr, ...
            fileNames{iText}, 'center', 'center', [], [], [], [], vSpacing, [], finalRect);
    end

end
