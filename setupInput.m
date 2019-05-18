function handle = setupInput(inputType, inputID, BaudRate)
    % For serial port, default inputID is dir('/dev/tty.USA*')
    % For keyboard, default inputID is 1 (first keyboard index)
    narginchk(2, 3)
    switch lower(inputType)
        case 'serial'
            IOPort('CloseAll'); % Open ports can cause this code to fail.
            handle = IOPort('OpenSerialPort', inputID, ...
                ['BaudRate=' num2str(BaudRate)]);
            IOPort('Flush', handle);
        case 'keyboard'
            keyboardIndices = GetKeyboardIndices();
            handle = keyboardIndices(inputID);
            KbQueueCreate(handle);
            KbQueueStart(handle);
        otherwise
            handle = [];
            % no input
    end
end
