function [responseData, flipData] = runExperiment(presentationFile, metaFile)

    narginchk(2, 2);
    AssertOpenGL;
    KbName('UnifyKeyNames');

    metaData = parseMetaFile(metaFile);

    % Create Psychtoolbox Screen
    Screen('Preference', 'SkipSyncTests', metaData.skipSyncTests);
    Screen('Preference', 'Verbosity', 2); % 2 low ; 3 default ; 4 high
    wPtr = Screen('OpenWindow', max(Screen('Screens')), [], ...
                  metaData.windowSize);
    Screen('FillRect', wPtr, metaData.backgroundColor);
    Screen('TextSize', wPtr, metaData.textSize);
    Screen('TextColor', wPtr, metaData.textColor);
    Screen('BlendFunction', wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    HideCursor();

    screenCoords = Screen('Rect', wPtr);
    DisplayText = 'Parsing Presentation File...\n\nPlease wait...';
    DrawFormattedText(wPtr, DisplayText, 'center', 'center');
    Screen('Flip', wPtr);
    [stimulusData, inputData] = parsePresentationFile(presentationFile, ...
                                                      metaData, screenCoords);
    [responseData, flipData] = autoExperiment(wPtr, metaData, stimulusData, ...
                                              inputData);

    save('debug.mat');

    writetable(struct2table(flipData), ['flipData_' num2str(round(GetSecs())) '.csv'])
    if length(responseData) == 1
        writetable(struct2table(responseData), ...
            ['responseData_' num2str(round(GetSecs())) '.csv'], 'AsArray', true)
    else
        writetable(struct2table(responseData), ...
            ['responseData_' num2str(round(GetSecs())) '.csv'])
    end

    % Clean up
    ShowCursor();
    Screen('CloseAll');

end
