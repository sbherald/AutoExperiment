function cleanupInput(deviceType, deviceHandle)
    switch lower(deviceType)
        case 'serial'
            IOPort('Close', deviceHandle);
        case 'keyboard'
            KbQueueStop(deviceHandle);
            KbQueueRelease(deviceHandle);
        otherwise
            % nothing
    end
end
