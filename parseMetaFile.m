function metaData = parseMetaFile(filename, screenCoords)
    % deviceType
    metaData = jsondecode(fileread(filename));
    requiredFields = {'screenHeight', 'screenWidth', ...
                      'distanceToScreen'};
    hasRequiredField = isfield(metaData, requiredFields);
    missingFields = ~hasRequiredField;
    assert(all(hasRequiredField), ...
        ['Meta file requires ', strjoin(requiredFields(missingFields), ', '), ' to be set']);
    
    if ~isfield(metaData, 'inputType')
        metaData.inputType = '';
    end
    if ~isfield(metaData, 'backgroundColor')
        metaData.backgroundColor = [0, 0, 0];
    end
    if ~isfield(metaData, 'textColor')
        metaData.textColor = [255, 255, 255];
    end
    if ~isfield(metaData, 'bufferSize')
        metaData.bufferSize = 5;
    end
    if ~isfield(metaData, 'skipSyncTests')
        metaData.skipSyncTests = 0;
    end
    if ~isfield(metaData, 'textSize')
        metaData.textSize = 50;
    end
    if ~isfield(metaData, 'windowSize')
        metaData.windowSize = [];
    end
    if ~isfield(metaData, 'encoding')
        metaData.encoding = 'UTF-8';
    end
    if ~isfield(metaData, 'StimulusDirectory')
        metaData.StimulusDirectory = '';
    end
    
    if ~isfield(metaData, 'inputID')
        if strcmpi(metaData.inputType, 'keyboard')
            metaData.inputID = 1;
        elseif strcmpi(metaData.inputType, 'serial')
            error('Serial port input requires the inputID field. It must contain the path to the serial port device.')
        end
    end

    if ~isfield(metaData, 'BaudRate')
        metaData.BaudRate = [];
    elseif isfield(metaData, 'BaudRate') && ischar(metaData.BaudRate)
        metaData.BaudRate = str2num(metaData.BaudRate);
    end

    if isempty(metaData.screenHeight) && ~isempty(metaData.screenWidth)
        metaData.screenHeight = metaData.screenWidth / screenCoords(3) * screenCoords(4);
    end
    if isempty(metaData.screenWidth) && ~isempty(metaData.screenHeight)
        metaData.screenWidth = metaData.screenHeight / screenCoords(4) * screenCoords(3);
    end

end
