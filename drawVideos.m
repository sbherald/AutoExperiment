function [timingData] = drawVideos(wPtr, ...
    movieMap, metaData, fileNames, duration, startTime, nextFlip, stimWidth, stimHeight, hOffset, vOffset, xc, yc)

    eventDuration = duration / 1000;

    % If any movies need to be drawn beyond the current buffer, begin
    %   playing back the movie and expanding the buffer
    newBuffer = NaN(length(fileNames), 1);
    for iMovie = 1:length(fileNames)
        movieKey = fileNames{iMovie};
        curMovie = movieMap(movieKey);
        if isnan(stimWidth(iMovie)) || stimWidth(iMovie) == 0
            stimWidth(iMovie) = curMovie.imgw;
        end
        if isnan(stimHeight(iMovie)) || stimHeight(iMovie) == 0
            stimHeight(iMovie) = curMovie.imgh;
        end
        if eventDuration > metaData.bufferSize ...
                && curMovie.movieduration > metaData.bufferSize
            mPtr = Screen('OpenMovie', wPtr, strjoin({pwd(), fileNames{iMovie}}, '/'), 4);
            Screen('SetMovieTimeIndex', mPtr, metaData.bufferSize, 0);
            Screen('PlayMovie', mPtr, 2, 0, 0);
            newBuffer(iMovie) = mPtr;
        end
    end

    movieStartTime = startTime;
    frameIndex = ones(length(fileNames), 1);
    timingLeeway = 2/1000; % 2 ms leeway
    nextMovieFlip = NaN;
    nextFrame = NaN(length(fileNames), 1);
    nextPts = NaN(length(fileNames), 1);
    % fps = NaN;

    % I left off here

    for iMovie = 1:length(fileNames)
        curMovie = movieMap(fileNames{iMovie});
        % If the current frame is past the current buffer, and the movie
        %   duration is less than or equal to the buffer size, then...
        if frameIndex(iMovie) > length(curMovie.timing) ...
            && curMovie.movieduration <= metaData.bufferSize
            dispRect = [0 0 stimWidth(iMovie) stimHeight(iMovie)];
            finalRect = CenterRectOnPoint(dispRect, xc + hOffset(iMovie), ...
                yc + vOffset(iMovie));
            % Remove the image from the screen
            Screen('FillRect', wPtr, metaData.backgroundColor, finalRect);
            fileNames{iMovie} = '';
            continue
        % If the current frame is greater than the buffer,
        %   and the movie is longer than the current buffer, then...
        elseif frameIndex(iMovie) > length(curMovie.timing) ...
                && curMovie.movieduration > metaData.bufferSize
            % Grab the next frame in the movie
            [nextFrame(iMovie), nextPts(iMovie)] = ...
                Screen('GetMovieImage', wPtr, newBuffer(iMovie));
        % If the current frame is within the buffer limits, get the info to draw it.
        else
            nextFrame(iMovie) = curMovie.textures(frameIndex(iMovie));
            nextPts(iMovie) = curMovie.timing(frameIndex(iMovie));
        end

        % fps = curMovie.fps;
        if nextPts(iMovie) < (nextMovieFlip - timingLeeway)
            nextMovieFlip = nextPts(iMovie);
            frameIndex(drawFrame) = frameIndex(drawFrame) - 1;
            drawFrame = zeros(length(fileNames), 1);
            drawFrame(iMovie) = 1;
            frameIndex(iMovie) = frameIndex(iMovie) + 1;
        elseif nextPts(iMovie) >= (nextMovieFlip - timingLeeway) ...
                && nextPts(iMovie) < (nextMovieFlip + timingLeeway)
            drawFrame(iMovie) = 1;
            frameIndex(iMovie) = frameIndex(iMovie) + 1;
        end
    end

    while ~isempty(fileNames)
        nextMovieFlip = Inf;
        drawFrame = zeros(length(fileNames), 1);
        iDelete = zeros(length(fileNames), 1);
        % For each movie, grab the next frame and the next pts
        for iMovie = 1:length(fileNames)
            curMovie = movieMap(fileNames{iMovie});

            if frameIndex(iMovie) > length(curMovie.timing) ...
                    && curMovie.movieduration <= metaData.bufferSize
                dispRect = [0 0 stimWidth(iMovie) stimHeight(iMovie)];
                finalRect = CenterRectOnPoint(dispRect, ...
                    xc + hOffset(iMovie), ...
                    yc + vOffset(iMovie));
                Screen('FillRect', wPtr, metaData.backgroundColor, finalRect);
                iDelete(iMovie) = 1;
                continue
            elseif frameIndex(iMovie) > length(curMovie.timing) ...
                    && curMovie.movieduration > metaData.bufferSize
                [nextFrame(iMovie), nextPts(iMovie)] = ...
                    Screen('GetMovieImage', wPtr, newBuffer(iMovie));
            else
                nextFrame(iMovie) = curMovie.textures(frameIndex(iMovie));
                nextPts(iMovie) = curMovie.timing(frameIndex(iMovie));
            end

            % fps = curMovie.fps;
            if nextPts(iMovie) < (nextMovieFlip - timingLeeway)
                nextMovieFlip = nextPts(iMovie);
                if sum(drawFrame) ~= 0
                    frameIndex(logical(drawFrame)) = frameIndex(logical(drawFrame)) - 1;
                end
                drawFrame = zeros(length(fileNames), 1);
                drawFrame(iMovie) = 1;
                frameIndex(iMovie) = frameIndex(iMovie) + 1;
            elseif nextPts(iMovie) >= (nextMovieFlip - timingLeeway) ...
                    && nextPts(iMovie) < (nextMovieFlip + timingLeeway)
                drawFrame(iMovie) = 1;
                frameIndex(iMovie) = frameIndex(iMovie) + 1;
            end
        end
        
        if sum(iDelete) ~= 0
            fileNames{logical(iDelete)} = '';
            drawFrame(logical(iDelete)) = [];
            frameIndex(logical(iDelete)) = [];
            nextFrame(logical(iDelete)) = [];
            nextPts(logical(iDelete)) = [];
        end

        if (movieStartTime + nextMovieFlip) > ...
                (nextFlip)
            break;
        end

        for iMovie = find(drawFrame==1)
            dispRect = [0 0 stimWidth(iMovie) stimHeight(iMovie)];
            finalRect = CenterRectOnPoint(dispRect, xc + hOffset(iMovie), yc + vOffset(iMovie));
            Screen('DrawTexture', wPtr, ...
                nextFrame(iMovie), [], ...
                finalRect);
        end

        screenFlip(wPtr, movieStartTime + nextMovieFlip, '', 1);

    end

    for mPtr = newBuffer(~isnan(newBuffer))
        Screen('PlayMovie', mPtr, 0);
        Screen('CloseMovie', mPtr);
    end

    timingData = NaN;

end
