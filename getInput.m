function rawResponseData = getInput(inputType, deviceHandle, validButtons, ...
                                    untilTime)

    % TODO: Implement "allInputValues" and "allTimestamps"

    buttonValue = [];
    allInputValues = [];
    responseTime = [];
    uncertainty = [];
    allTimestamps = [];

    switch lower(inputType)
    case 'serial'
        % Button1 = 49; Button2 = 50; Button3 = 51; Button4 = 52;
        %   Trigger (Button5) = 53;
        % portData is a vector of the raw values read from the IO port, in
        %   order that those values were received; no timing data is associated
        %   with each individual value
        
        responseReceived = false;
        readTime = -inf;
        pollInterval = 0.005;
        beforeDeadline = true;

        while ~responseReceived && beforeDeadline
            oldReadTime = readTime;
            [portData, readTime, errmsg] = IOPort('Read', deviceHandle);
            uncertainty = readTime - oldReadTime;
            if ~isempty(errmsg)
                disp(errmsg);
            end

            for response = portData
                if any(isnan(validButtons)) || any(ismember(response, validButtons))
                    responseReceived = true;
                    buttonValue = response;
                    responseTime = readTime;
                    break;
                end
            end

            if responseReceived
                % nothing
            elseif GetSecs() < (untilTime - pollInterval)
                WaitSecs(pollInterval);
            else
                beforeDeadline = false;
            end
        end

    case 'keyboard'
        responseTime = NaN;
        beforeDeadline = true;
        pollInterval = 0.005;
        buttonValue = [];

        while beforeDeadline
            [pressed, firstPress, firstRelease, ...
                lastPress, lastRelease] = KbQueueCheck();

            buttonSequence = 1:length(firstPress);
            if isnan(validButtons)
                validButtons = buttonSequence;
            end

            validKeys = firstPress(validButtons);
            validTimesAboveZero = validKeys(validKeys>0);
            validButtonsAboveZero = validButtons(validKeys>0);
            if ~isempty(validTimesAboveZero)
                [responseTime, buttonIndex] = min(validTimesAboveZero);
                buttonValue = validButtonsAboveZero(buttonIndex);
                break;
            end

            if GetSecs() < (untilTime - pollInterval)
                WaitSecs(pollInterval);
            else
                beforeDeadline = false;
            end
        end

        uncertainty = 0;

    otherwise
        % nothing
    end

    rawResponseData = struct( ...
        'validInputValues', {buttonValue}, ...
        'allInputValues', {allInputValues}, ...
        'timestamp', {responseTime}, ...
        'allTimestamps', {allTimestamps}, ...
        'uncertainty', {uncertainty} ...
    );

    end
