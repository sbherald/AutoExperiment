function pixelDistance = angleToPixel(visualAngleDeg, screenPixelSize, ...
                                    distanceAcrossScreen, distanceToScreen)
    if isnan(visualAngleDeg) || isempty(visualAngleDeg)
        pixelDistance = NaN;
    else
        visualAngleRad = visualAngleDeg / 180 * pi;
        pixelDistance = tan(visualAngleRad / 2) * 2 * screenPixelSize ...
                        * distanceToScreen / distanceAcrossScreen;
        pixelDistance = round(pixelDistance, 0);
    end
end
