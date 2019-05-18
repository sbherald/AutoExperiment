# AutoExperiment
This README contains an introduction followed by the specifications for the different files used by this program.

## What is AutoExperiment?
At its core, AutoExperiment is not the Matlab code in this repository, but the idea of separating the experimental design from the code and a format to do that. Separating the experimental design from the code has some big advantages in terms of ease of use, portability, and sharing.

Because you are not dealing directly with the code, AutoExperiment tries to give you the variables you might care about in two spreadsheets. Reaction time, key presses, correct/incorrect, actual stimulus onset time, and more are all provided automatically.

The Matlab code here is an implementation using Psychtoolbox of the file specifications given below. However, this format is not tied to any specific programing language or platform. For example, it could be implemented in Python using PsychoPy.

I have been using the code in this repository to run my recent experiments, although the code likely still has bugs. If you come across any bugs, or have any suggestions, you can let me know on the Github issues page. If you’d like to contribute to the project, please feel free to do so.

I plan to keep working on this project to improve the file formats, Matlab code, and maybe expand it to PsychoPy. At the very least, I’ve found it has made creating my own experiments much easier. If you decide to use AutoExperiment or if you just like the ideas behind it, I’d appreciate you letting me know. Having a sense of how many people are using this code will help motivate me to keep making it better.

## Presentation File
The presentation file is a spreadsheet. It should be either a comma separated values (csv) or tab separated values (tsv) file.

The idea behind the presentation file is to provide all of the information needed to run a visual experiment in a structured format. Each row represents a period of time and each column is a piece of information about the stimuli being presented or the behavioral response being recorded.

AutoExperiment cannot perform randomization for you. This is a deliberate decision. By forcing the presentation file to be deterministic, an experiment can be replicated down to the exact ordering of trials. It also prevents the scenario where a random order of trials is generated but the actual order is never saved. If you want to randomize or pseudo-randomize your experiment, you should do it by generating multiple presentation files with the desired aspects of the experiments randomized between the files.

The following columns can be used in a presentation file.

“Stimulus”: The path to the stimulus on your computer. It is relative to either the current working directory. If you set the “StimulusDirectory” variable in the meta file (see below), then the path will be relative to this directory. If you want to have multiple stimuli on the screen simultaneously, then you need to append an underscore and a unique identifier to this column name. For example, “Stimulus_Left.” I can then add another column called “Stimulus_Right.” You can add as many stimulus columns as you need for simultaneous stimulus presentations. You can use the underscore and identifier even if you have just one stimulus. However, you can only use the shortened form “Stimulus” when you have one stimulus. For example, AutoExperiment will not work if you have “Stimulus” and “Stimulus_Right.”

“StimType”: This should be either “Image,” “Video, or “Text.” If you leave it blank, AutoExperiment will try to determine the type of stimulus based on the file extension. If it doesn’t recognize the file extension or it sees no file extension, then it assumes this is a “text” stimulus and will print the text to the screen. If using multiple stimuli, append an underscore and the same identifier you use for the corresponding stimulus name. If I have “Stimulus_Left,” then I would name this column “StimType_Left.”

“StimPosX”: The horizontal position of the stimulus in visual degrees, relative to the center of the screen. Negative values indicate a position to the left of the center and positive values indicate a position to the right of the center. If you have multiple stimuli, use the underscore and identifier name.

“StimPosY”: The vertical position of the stimulus in visual degrees, relative to the center of the screen. Negative values indicate a position above the center and positive values indicate a position below the center. If you have multiple stimuli, use the underscore and identifier name.

“StimSizeW”: The width of the stimulus in visual degrees. If you have multiple stimuli, use the underscore and identifier name.

“StimSizeH”: The height of the stimulus in visual degrees. If you have multiple stimuli, use the underscore and identifier name.

“Duration”: The duration of time in milliseconds that the stimulus should remain on screen.

“ValidButtons”: A list of buttons that AutoExperiment checks for input. If left blank, all buttons will be checked for input. If using a keyboard input, the values should be the name of the button (e.g. “a”, “p”, “space”). You can find the names of the buttons by using KbName() from Psychtoolbox. If using a serial device input, the values should be numbers.

“CorrectButtons”: A list of buttons that AutoExperiment will consider correct if pressed. All other button presses that are “ValidButtons” will be considered incorrect. If these buttons are not also present in “ValidButtons,” then AutoExperiment will add them there for you because it does not make sense to have a correct response be a button that you cannot press.

“ResponseEvent”: A response event is a length of time during which a single response is expected from a subject. It should start at 1. Rows that have the same response event number must be contiguous and will be grouped together in terms of output. The correct and valid buttons can change during the response event. Blank rows are allowed. When the response event is incremented, it must increase by 1. One way to think about a response event is like the trial number.  For example, let’s say you have a same-different task where an image is displayed, followed by another image, and then the participant has to say if the images are the same or different. Every row in this sequence would be marked with the same response event number. Responding too early (before the second image is shown) would have no “CorrectButtons” and thus always be incorrect. Same with responding too late. During the response duration, however, the “CorrectButtons” variable could be set to the correct key and allow the response to be collected for that trial.

“Description”: This is simply a column for whatever text you want. It isn’t used by AutoExperiment. For example, you could write the experimental conditions in this column.

## Meta File
The meta file is a [JSON](https://en.wikipedia.org/wiki/JSON) file used for information that is specific to your hardware setup as well as some more general information like background color.

Only three variables must be specified in every JSON file: the width of the monitor (“screenWidth”), the height of the monitor (“screenHeight”), and the distance from the subject’s eyes to the center of the monitor (“distanceToScreen”). These measurements are critical because they allow the visual degrees of a stimulus to be calculated.

You may use any unit of measurement (e.g. inches, cm, etc.) as long as all three variables have the exact same unit. Here is an example:

```
{
    "screenWidth": 11.28,
    "screenHeight": 7.05,
    "distanceToScreen": 24
}
```

The monitor screen is 11.28 inches wide, 7.05 inches tall, and the participant or user is sitting 24 inches away from the monitor.

Several other types of information can be specified.

```
{
    "inputType": "keyboard",
    "backgroundColor": [0, 0, 0],
    "textColor": [255, 255, 255],
    "bufferSize": 5,
    "skipSyncTests": 0,
    "textSize": 50,
    "windowSize": [],
    "encoding": "UTF-8",
    "StimulusDirectory": "",
    "inputID": 1,
    "BaudRate": []
}
```

“inputType” can be either “keyboard” (for keyboard devices) or “serial” (for serial port devices). If you are using “serial” input, the “inputID” must be be the path to the serial port device on your computer and the “BaudRate” must be set to match your serial input device.

“bufferSize” is only used when you have video stimuli. Because video files can be quite large and difficult to fit into memory, AutoExperiment only loads the start of the video. The “bufferSize” is the number of seconds to load for each video. If the video length is smaller than the “bufferSize,” then AutoExperiment loads the entire video into memory before starting the experiment. If the video length is greater than the “bufferSize,” then AutoExperiment will use what it has in the buffer and then start loading the rest of the video from the file.

“backgroundColor” sets the background color of the monitor that all of the stimuli are drawn on top of.

“textColor” and “textSize” changes the color and size of the text on the screen. AutoExperiment cannot automatically adjust the size of your text to make sure it all fits on the screen or within the stimulus boundaries that you set. You should play around with “textSize” to get an appropriate size for your text. I am currently thinking about moving “textColor” (and maybe “textSize”) to the presentation file in order to allow these variables to be set differently for each stimulus.

“encoding” is the text encoding used for the presentation file.

“StimulusDirectory” is where AutoExperiment will look for your stimuli. It defaults to the current working directory.

“skipSyncTests” will skip the Psychtoolbox sync tests if this variable is set to 1.

“windowSize” is the size of the window used for the experiment. It defaults to fullscreen.

## Output Files
### Response Data
Each row represents a response event. The number of rows equals the number of response events. If you have no response events, a response data file is still generated, but it only has a single row and it is meaningless.

isCorrect: A value of 1 if the response was a “CorrectKey” and a value of 0 if it was not.

reactionTimeTotal: The difference in time between when the button was pressed and the response event began.

reactionTime: This is similar to reactionTimeTotal, but the reference time will be reset if the “CorrectKeys” changed. For example, let’s say you have a trial where a stream of images are being presented. If a subject sees an airplane, they need to press a button within 1 second. Instead of measuring reaction time as being relative to the start of the stream of images, reaction time should be measured as relative to when the airplane came on screen and a correct response became possible.

uncertainty: Any uncertainty in the reaction time values. For example, reading from a serial port only reports a timestamp of when the read was performed and not a timestamp from when the actual button was pressed. Therefore, the button press could have happened anytime between the most recent read and the previous read from the serial device.

buttonValue: The value of the button that was pressed.

### Flip Data
Each row represents the same time period as the corresponding row of the presentation file. The number of rows is equal to the number of rows of the presentation file.

Desync: The difference in time between when a stimulus actually appeared on screen and when it was supposed to appear on screen.

Description: A copy of the Description column from the presentation file. It’s copied here in case you are using the description column for something important like recording the experimental condition.

WaitStartTime: The time at which Psychtoolbox finished drawing all of the stimuli to the offscreen buffer and started waiting for the appropriate time to flip it onto the screen.

ExpectedTime: The time when stimulus should have appeared on the screen.

FlipStartTime: This is a Psychtoolbox variable from the flip method. It is recorded here in case you need it.

FlipEndTime: This is a Psychtoolbox variable from the flip method. It is recorded here in case you need it.

StimulusOnsetTimeEstimate: This is a Psychtoolbox variable from the flip method. It is recorded here in case you need it.

Missed: This is a Psychtoolbox variable from the flip method. It is recorded here in case you need it.