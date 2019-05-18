function [stimulusData, responseData] = parsePresentationFile( ...
    filename, metaData, screenCoords, encoding)
%PARSEPRESENTATIONFILE Load experimental setup from a spreadsheet file
% 
% stimulusData:
% The columns define the order of stimuli drawn to the screen.
%   Each column is a new stimulus drawn on the screen.
% Each row is a single screen presentation (i.e. Screen.flip()).
% The number of stimuli drawn to the screen is not necessarily
%   consistent across flips. Columns may sometimes be blank.
% 
% responseData:
% Each row is a single screen presentation (i.e. Screen.flip()).
% Each column contains various information about any expected user input

    % TODO: Rename responseData to trialData and add duration to trialData

    narginchk(3,4);
    if nargin == 3
        encoding = 'system';
    end

    DELIM = '_'; % Not an ASCII emoticon. Just our delimiter for fieldnames.

    % Read spreadsheet table and get column header names
    rawdata = readtable(filename, 'Encoding', metaData.encoding, ...
                        'ReadVariableNames', true);
    varNames = rawdata.Properties.VariableNames;

    % Unless we loop through varNames twice, we can't preallocate the variable
    %   sizes. I suppose I could time this to see if two loops with 
    %   pre-allocation is faster than a single loop with no pre-allocation.
    % Let's assume nobody will have more than 50 stimuli.
    stimulusTypes = cell(50,1);
    nStimuli = 0;

    % Loop through variable names to get the total number of stimuli
    %   and groups used.
    % A variable name has a "base name" and an "identifier," seperated
    %   by an underscore.
    % For example, "Stimulus_Left" has a basename of "Stimulus" and an
    %   identifier of "Left."
    % "Stimulus_Right_Green" has a basename of "Stimulus" and an identifier
    %   of "Right_Green.""
    for iVar = 1:length(varNames)
        splitVar = strsplit(varNames{iVar}, DELIM);
        baseVar = splitVar{1};

        if length(splitVar) > 1
            % If the identifier contained any underscores, add them back
            descripVar = strjoin(splitVar(2:end), DELIM);
        else
            % Handle the case if no identifier is provided
            descripVar = '';
        end

        switch baseVar
            case 'Stimulus'
                nStimuli = nStimuli + 1;
                stimulusTypes{nStimuli} = descripVar;
        end
    end

    % Remove empty elements in the cell array. We need a special case if the
    %   cell array is empty.
    if nStimuli == 0
        stimulusTypes = {};
    else
        stimulusTypes = stimulusTypes(1:nStimuli);
    end

    stimulusData = struct();

    fileNames = cell(size(rawdata, 1)+1, length(stimulusTypes));
    fileNames(:) = {''};
    types = cell(size(rawdata, 1)+1, length(stimulusTypes));
    types(:) = {''};
    hOffsets = NaN(size(rawdata, 1)+1, length(stimulusTypes));
    vOffsets = NaN(size(rawdata, 1)+1, length(stimulusTypes));
    widths = NaN(size(rawdata, 1)+1, length(stimulusTypes));
    heights = NaN(size(rawdata, 1)+1, length(stimulusTypes));
    isImage = false(size(rawdata, 1)+1, length(stimulusTypes));
    isVideo = false(size(rawdata, 1)+1, length(stimulusTypes));
    isAudio = false(size(rawdata, 1)+1, length(stimulusTypes));
    isText = false(size(rawdata, 1)+1, length(stimulusTypes));
    durations = NaN(size(rawdata, 1)+1, 1);

    for iStim = 1:length(stimulusTypes)

        % Handle case where no identifier is used
        fieldStimFile = 'Stimulus';
        fieldStimType = 'StimType';
        fieldStimPosX = 'StimPosX';
        fieldStimPosY = 'StimPosY';
        fieldStimSizeW = 'StimSizeW';
        fieldStimSizeH = 'StimSizeH';
        fieldDuration = 'Duration';

        if ~isempty(stimulusTypes{iStim})
            % Field name is the base name plus the identifier
            %   seperated by an underscore
            fieldStimFile = strjoin({fieldStimFile, stimulusTypes{iStim}}, DELIM);
            fieldStimType = strjoin({fieldStimType, stimulusTypes{iStim}}, DELIM);
            fieldStimPosX = strjoin({fieldStimPosX, stimulusTypes{iStim}}, DELIM);
            fieldStimPosY = strjoin({fieldStimPosY, stimulusTypes{iStim}}, DELIM);
            fieldStimSizeW = strjoin( ...
                {fieldStimSizeW, stimulusTypes{iStim}}, DELIM);
            fieldStimSizeH = strjoin( ...
                {fieldStimSizeH, stimulusTypes{iStim}}, DELIM);
        end

        if ~ismember(fieldStimFile, rawdata.Properties.VariableNames)
            error('Stimulus filename must be specified in presentation file');
        end
        if ~ismember(fieldDuration, rawdata.Properties.VariableNames)
            error('Duration must be specified in presentation file');
        end

        % If a variable column doesn't exist for a stimulus, then create an
        %   empty or null array of the appropriate length.
        if ~ismember(fieldStimType, rawdata.Properties.VariableNames)
            % infer based on file extension later
            rawdata.(fieldStimType) = cell(size(rawdata,1),1);
        end
        if ~ismember(fieldStimPosX, rawdata.Properties.VariableNames)
            rawdata.(fieldStimPosX) = NaN(size(rawdata,1),1);
        end
        if ~ismember(fieldStimPosY, rawdata.Properties.VariableNames)
            rawdata.(fieldStimPosY) = NaN(size(rawdata,1),1);
        end
        if ~ismember(fieldStimSizeW, rawdata.Properties.VariableNames)
            rawdata.(fieldStimSizeW) = NaN(size(rawdata,1),1);
        end
        if ~ismember(fieldStimSizeH, rawdata.Properties.VariableNames)
            rawdata.(fieldStimSizeH) = NaN(size(rawdata,1),1);
        end

        % TODO: DO I NEED THIS?
        if ~all(iscell(rawdata.(fieldStimFile))) ...
                || ~all(iscell(rawdata.(fieldStimType))) ...
                || ~all(isnumeric(rawdata.(fieldStimPosX))) ...
                || ~all(isnumeric(rawdata.(fieldStimPosY))) ...
                || ~all(isnumeric(rawdata.(fieldStimSizeW))) ...
                || ~all(isnumeric(rawdata.(fieldStimSizeH))) ...
                || ~all(isnumeric(rawdata.Duration))
            error('Presentation does not have correct formatting');
        end

        fileNames(1:(end-1), iStim) = rawdata.(fieldStimFile);

        durations(1:(end-1)) = rawdata.(fieldDuration);
        durations(isnan(durations)) = Inf;

        types(1:(end-1), iStim) = rawdata.(fieldStimType);
        % If there's no file, there is no file type.
        types(cellfun('isempty', fileNames(:, iStim)), iStim) = {''};
        % If no type exists, determine type from file extension
        emptyTypeCells = cellfun('isempty', types(:, iStim));
        types(emptyTypeCells & cellfun(@(x) endsWith(x, {'png', 'jpg', 'bmp'}), fileNames(:, iStim)), iStim) = {'Image'};
        types(emptyTypeCells & cellfun(@(x) endsWith(x, {'mov', 'mp4', 'mkv'}), fileNames(:, iStim)), iStim) = {'Video'};
        types(emptyTypeCells & cellfun(@(x) endsWith(x, {'mp3', 'opus'}), fileNames(:, iStim)), iStim) = {'Audio'};

        hOffsets(1:(end-1), iStim) = rawdata.(fieldStimPosX);
        % Set NaN values to 0
        hOffsets(isnan(hOffsets(:, iStim)), iStim) = 0;
        % Convert visual degrees to pixels
        hOffsets(:, iStim) = arrayfun(@(x) angleToPixel(x, screenCoords(3), metaData.screenWidth, metaData.distanceToScreen), hOffsets(:, iStim), 'UniformOutput', true);

        vOffsets(1:(end-1), iStim) = rawdata.(fieldStimPosY);
        % Set NaN values to 0
        vOffsets(isnan(vOffsets(:, iStim)), iStim) = 0;
        % Convert visual degrees to pixels
        vOffsets(:, iStim) = arrayfun(@(x) angleToPixel(x, screenCoords(4), metaData.screenHeight, metaData.distanceToScreen), vOffsets(:, iStim), 'UniformOutput', true);

        widths(1:(end-1), iStim) = rawdata.(fieldStimSizeW);
        % NaN values will be dealt with in the main program
        widths(:, iStim) = arrayfun(@(x) angleToPixel(x, screenCoords(3), metaData.screenWidth, metaData.distanceToScreen), widths(:, iStim));

        heights(1:(end-1), iStim) = rawdata.(fieldStimSizeH);
        % NaN values will be dealt with in the main program
        heights(:, iStim) = arrayfun(@(x) angleToPixel(x, screenCoords(4), metaData.screenHeight, metaData.distanceToScreen), heights(:, iStim));

        isImage(cellfun(@(x) strcmpi(x, 'Image'), types(:, iStim)), iStim) = true;
        isVideo(cellfun(@(x) strcmpi(x, 'Video'), types(:, iStim)), iStim) = true;
        isAudio(cellfun(@(x) strcmpi(x, 'Audio'), types(:, iStim)), iStim) = true;
        isText = ~isImage & ~isVideo & ~isAudio;
        isText(cellfun(@(x) strcmpi(x, 'Text'), types(:, iStim)), iStim) = true;

    end

    stimulusData.fileName = fileNames;
    stimulusData.type = types;
    stimulusData.hOffset = hOffsets;
    stimulusData.vOffset = vOffsets;
    stimulusData.width = widths;
    stimulusData.height = heights;
    stimulusData.duration = durations;
    stimulusData.isImage = isImage;
    stimulusData.isVideo = isVideo;
    stimulusData.isAudio = isAudio;
    stimulusData.isText = isText;

    % Response data lie below here.

    responseData = struct( ...
        'responseEvent', cell(size(rawdata, 1), 1), ...
        'correctButtons', NaN, ...
        'validButtons', NaN, ...
        'skipAfterResponse', NaN, ...
        'newEvent', false, ...
        'eventUpdate', false, ...
        'finalEvent', false ...
    );
    if ~ismember('CorrectButtons', rawdata.Properties.VariableNames)
        rawdata.CorrectButtons = cell(size(rawdata, 1), 1);
    end
    if isnumeric(rawdata.CorrectButtons)
        rawdata.CorrectButtons = num2cell(rawdata.CorrectButtons);
    end
    if ~ismember('ValidButtons', rawdata.Properties.VariableNames)
        rawdata.ValidButtons = cell(size(rawdata, 1), 1);
    end
    if isnumeric(rawdata.ValidButtons)
        rawdata.ValidButtons = num2cell(rawdata.ValidButtons);
    end
    if ~ismember('ResponseEvent', rawdata.Properties.VariableNames)
        rawdata.ResponseEvent = ones(size(rawdata, 1), 1);
    end
    if ~isnumeric(rawdata.ResponseEvent)
        rawdata.ResponseEvent = str2double(rawdata.ResponseEvent);
    end
    RE = find(~isnan(rawdata.ResponseEvent));
    if ~isequal(rawdata.ResponseEvent(RE(1)), 1)
        error('ResponseEvent must start at 1');
    end
    responseData(RE(1)).newEvent = true;
    responseData(RE(end)).finalEvent = true;
    for index = 2:length(RE)
        if ~(isequal(rawdata.ResponseEvent(RE(index)), ...
                rawdata.ResponseEvent(RE(index-1))) || ...
                isequal(rawdata.ResponseEvent(RE(index)), ...
                rawdata.ResponseEvent(RE(index-1))+1))
            error('ResponseEvent must increment by 0 or 1');
        end
        if isequal(rawdata.ResponseEvent(RE(index)), ...
                rawdata.ResponseEvent(RE(index-1))) ...
                && ~isequal(rawdata.CorrectButtons(RE(index)), ...
                rawdata.CorrectButtons(RE(index-1)))
            responseData(RE(index)).eventUpdate = true;
        end
        if isequal(rawdata.ResponseEvent(RE(index)), ...
                rawdata.ResponseEvent(RE(index-1))+1)
            responseData(RE(index)).newEvent = true;
            responseData(RE(index-1)).finalEvent = true;
        end
        if isequal(rawdata.ResponseEvent(RE(index)), ...
                rawdata.ResponseEvent(RE(index-1)))
            if isnan(rawdata.Duration(RE(index-1)))
                error('Infinite duration within an ongoing response event');
            end
        end
    end
    % uRE = rawdata.ResponseEvent(~isnan(rawdata.ResponseEvent));
    % if uRE(1) ~= 1
    %     error('ResponseEvent must start at 1');
    % end
    % for index = 2:length(uRE)
    %     if ~(uRE(index)==uRE(index-1) || uRE(index)==(uRE(index-1)+1))
    %         error('ResponseEvent must increment by 0 or 1');
    %     end
    % end
    if ~ismember('SkipAfterResponse', rawdata.Properties.VariableNames)
        rawdata.SkipAfterResponse = false(size(rawdata, 1), 1);
    end
    
    for iTrial = 1:size(rawdata,1)

        % CorrectButtons
        if isempty(rawdata.CorrectButtons{iTrial})
            responseData(iTrial).correctButtons = NaN;
        elseif isnumeric(rawdata.CorrectButtons{iTrial})
            if strcmpi(metaData.inputType, 'keyboard')
                responseData(iTrial).correctButtons = KbName(num2str(rawdata.CorrectButtons{iTrial}));
            elseif strcmpi(metaData.inputType, 'serial')
                responseData(iTrial).correctButtons = rawdata.CorrectButtons{iTrial};
            end
        elseif strcmpi(rawdata.CorrectButtons{iTrial}, 'any')
            responseData(iTrial).correctButtons = NaN;
        elseif strcmpi(rawdata.CorrectButtons{iTrial}, 'none')
            responseData(iTrial).correctButtons = [];
        else
            rawCorrectButtons = strsplit(rawdata.CorrectButtons{iTrial}, ' ');
            correctButtons = NaN(length(rawCorrectButtons),1);
            for iButton = 1:length(rawCorrectButtons)
                if strcmpi(metaData.inputType, 'keyboard')
                    correctButtons(iButton) = KbName(rawCorrectButtons{iButton});
                elseif strcmpi(metaData.inputType, 'serial')
                    correctButtons(iButton) = str2double(rawCorrectButtons{iButton});
                end
            end
            responseData(iTrial).correctButtons = correctButtons;
        end

        % ValidButtons
        if isempty(rawdata.ValidButtons{iTrial})
            responseData(iTrial).validButtons = NaN;
        elseif isnumeric(rawdata.ValidButtons{iTrial})
            responseData(iTrial).validButtons = rawdata.ValidButtons{iTrial};
        elseif strcmpi(rawdata.ValidButtons{iTrial}, 'any')
            responseData(iTrial).validButtons = NaN;
        elseif strcmpi(rawdata.ValidButtons{iTrial}, 'none')
            responseData(iTrial).validButtons = [];
        else
            rawValidButtons = strsplit(rawdata.ValidButtons{iTrial}, ' ');
            validButtons = NaN(length(rawValidButtons),1);
            for iButton = 1:length(rawValidButtons)
                if strcmpi(metaData.inputType, 'keyboard')
                    validButtons(iButton) = KbName(rawValidButtons{iButton});
                elseif strcmpi(metaData.inputType, 'serial')
                    validButtons(iButton) = str2double(rawValidButtons{iButton});
                end
            end
            responseData(iTrial).validButtons = validButtons;
        end

        % If any correctButtons are not present in the validButtons,
        %   then add them.
        % iTrial

        % temp1 = responseData(iTrial).validButtons
        % size(temp1)

        % temp3 = ismember( responseData(iTrial).correctButtons, ...
        % responseData(iTrial).validButtons )
        % size(temp3)

        % temp2 = responseData( ...
        % iTrial ).correctButtons(~temp3)
        % size(temp2)

        % temp3 = responseData( ...
        %     ~temp2 ).correctButtons;

        % responseData(iTrial).validButtons = vertcat(temp1,temp2);

        if isnan(responseData(iTrial).validButtons)
            % nothing
        elseif isnan(responseData(iTrial).correctButtons)
            responseData(iTrial).validButtons = NaN;
        else
            responseData(iTrial).validButtons = ...
                [ responseData(iTrial).validButtons ; ...
                responseData(iTrial).correctButtons( ...
                ~ismember( responseData(iTrial).correctButtons, ...
                responseData(iTrial).validButtons ) ) ];
        end

        % SkipAfterResponse
        validResponses = {'yes', 'y', 'true', 't'};
        if iscellstr(rawdata.SkipAfterResponse(iTrial))
            responseData(iTrial).skipAfterResponse = any(strcmpi( ...
                rawdata.SkipAfterResponse{iTrial}, ...
                validResponses));
        else
            responseData(iTrial).skipAfterResponse = false;
        end
        
        % Response Event
        responseData(iTrial).responseEvent = rawdata.ResponseEvent(iTrial);
        
    end

end
