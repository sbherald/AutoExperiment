function flipData = screenFlip(wPtr, DisplayTime, Description, DontClear)
% Function that simplifies using Psychtoolbox Screen('Flip') function with
%   precise timing and collecting timing information for debugging
% Description is optional

% From the Psychtoolbox Wiki:
%
% Flip (optionally) returns a high-precision estimate of the system time
% (in seconds) when the actual flip has happened in the return argument
% 'VBLTimestamp'. An estimate of Stimulus-onset time is returned in
% 'StimulusOnsetTime'. Beampos is the position of the monitor scanning beam
% when the time measurement was taken (useful for correctness tests).
% FlipTimestamp is a timestamp taken at the end of Flip's execution. Use the
% difference between FlipTimestamp and VBLTimestamp to get an estimate of how
% long Flips execution takes. This is useful to get a feeling for the timing
% error if you try to sync script execution to the retrace, e.g., for
% triggering acquisition devices like EEG, fMRI, or for starting playback of a
% sound. "Missed" indicates if the requested presentation deadline for your
% stimulus has been missed. A negative value means that dead- lines have been
% satisfied. Positive values indicate a deadline-miss. The automatic detection
% of deadline-miss is not fool-proof - it can report false positives and also
% false negatives, although it should work fairly well with most experimental
% setups. If you are picky about timing, please use the provided timestamps or
% additional methods to exercise your own tests.

    narginchk(1, 4);
    if nargin == 1
        DisplayTime = GetSecs();
        Description = '';
        DontClear = 0;
    elseif nargin == 2
        Description = '';
        DontClear = 0;
    elseif nargin == 3
        DontClear = 0;
    end

    WaitStartTime = GetSecs();

    [VBLTimestamp, StimulusOnsetTime, FlipTimestamp, Missed, ~] ...
        = Screen('Flip', wPtr, DisplayTime, DontClear);
    
    flipData = struct( ...
        'Desync', {VBLTimestamp - DisplayTime}, ...
        'Description', {Description}, ...
        'WaitStartTime', {WaitStartTime}, ...
        'ExpectedTime', {DisplayTime}, ...
        'FlipStartTime', {VBLTimestamp}, ...
        'FlipEndTime', {FlipTimestamp}, ...
        'StimulusOnsetTimeEstimate', {StimulusOnsetTime}, ...
        'Missed', {Missed} ...
    );

end
