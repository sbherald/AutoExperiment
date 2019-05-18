function [newResponseData, eventStart, eventBaseline] = scoreInput(flipData, inputData, rawResponseData, responseData, responseIndex, eventStart, eventBaseline)

    newResponseData = [];
    if responseIndex < 1
        return;
    end

    if inputData(responseIndex).newEvent
        eventStart = flipData(responseIndex).FlipStartTime;
        eventBaseline = flipData(responseIndex).FlipStartTime;
    end
    if inputData(responseIndex).eventUpdate
        eventBaseline = flipData(responseIndex).FlipStartTime;
    end

    % responseTime = rawResponseData(responseIndex).timestamp(1);
    % isCorrect = rawResponseData(responseIndex).isCorrect;
    uncertainty = rawResponseData(responseIndex).uncertainty;
    % buttonValue = rawResponseData(responseIndex).validInputValues(1);

    % There is a correct button: check if it was pressed.
    % There is no correct button: check that none was pressed.
    validInputValues = rawResponseData(responseIndex).validInputValues;
    correctInput = inputData(responseIndex).correctButtons;
    correctButtons = ismember(validInputValues, correctInput);
    % validInputValues
    % correctInput
    % correctButtons
    if any(isnan(correctInput)) && any(validInputValues)
        % Pressed a button and all buttons are correct
        isCorrect = true;
        buttonValue = validInputValues(1);
        responseTime = rawResponseData(responseIndex).timestamp(1);
    elseif any(correctButtons)
        % Correctly pressed a button
        isCorrect = true;
        buttonValues = validInputValues(correctButtons);
        buttonValue = buttonValues(1);
        responseTime = rawResponseData(responseIndex).timestamp(correctButtons);
        responseTime = responseTime(1);
    elseif isempty(correctInput) && isempty(validInputValues)
        % Correctly pressed NO button
        isCorrect = true;
        buttonValue = validInputValues;
        responseTime = []; % rawResponseData(responseIndex).timestamp;
    elseif isempty(validInputValues)
        % Did not press a button when there was a correct button
        isCorrect = false;
        buttonValue = validInputValues;
        responseTime = []; % rawResponseData(responseIndex).timestamp;
    else
        % Pressed a button but it was not the correct button
        isCorrect = false;
        buttonValue = validInputValues(1);
        responseTime = rawResponseData(responseIndex).timestamp(1);
    end

    reactionTime = responseTime - eventBaseline;
    reactionTimeTotal = responseTime - eventStart;

    % if responseTime > eventEnd
    %     isCorrect = false;
    %     reactionTime = NaN;
    %     reactionTimeTotal = NaN;
    %     buttonValue = [];
    % end

    curEvent = inputData(responseIndex).responseEvent;
    % If this is a response event, and if a button was pressed, and if a
    %   response has not been recorded already for this event, then...
    %             && ~isempty(buttonValue) ...
    if isfinite(curEvent) ...
            && isempty(responseData(curEvent).buttonValue)
        newResponseData = struct( ...
            'isCorrect', {isCorrect}, ...
            'reactionTime', {reactionTime}, ...
            'reactionTimeTotal', {reactionTimeTotal}, ...
            'uncertainty', {uncertainty}, ...
            'buttonValue', {buttonValue} ...
        );
    end
end
