function [texids, texpts, movieduration, fps, imgw, imgh] = bufferVideo(wPtr, moviename, toTime)

% Preload movies
[movie, movieduration, fps, imgw, imgh] = Screen('OpenMovie',wPtr,moviename,4,1.5);
if isnan(toTime) || toTime > movieduration
    toTime = movieduration;
end
if (movieduration > 0) && (movieduration < intmax) && (fps > 0)
    texids = zeros(1, ceil(toTime * fps));
    texpts = zeros(1, ceil(toTime * fps));
end

movietexture=0;
lastpts=-1;
pts=lastpts;
count = 0;

Screen('PlayMovie', movie, 100, 0, 0);

% tloadstart=GetSecs;

% while (movietexture>=0)
while (movietexture>=0) && (pts < toTime)
    [movietexture, pts] = Screen('GetMovieImage',wPtr, movie);
    if (movietexture > 0) && (pts >= lastpts)
        count = count+1;
        texids(count)=movietexture;
        texpts(count)=pts;
        lastpts=pts;
    else
        break;
    end
end

texids = nonzeros(texids);
texpts = texpts(1:length(texids));

movieduration = length(texids)/fps;

% % Debugging
% % Compute movie load & conversion rate in frames per second.
% loadrate = count / (GetSecs - tloadstart);
% % Compute same rate in Megapixels per second:
% loadvolume = loadrate * imgw * imgh / 1024 / 1024;
% fprintf('Movie to texture conversion speed is %f frames per second == %f Megapixels/second.\n', loadrate, loadvolume);

% Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie:
Screen('CloseMovie', movie);

end
