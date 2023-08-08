function constants = SetConstants

constants = struct;

% Set constants
constants.redAnchor = 50;
constants.greenAnchor = 350;

constants.referenceColourSeconds = 10;
constants.adaptationSeconds = 60;

constants.yellowReferenceBrightness = 160;

redMaxLuminance = 2767.0;
greenMaxLuminance = 665.2;

constants.redAdaptationBrightness = round(255 * (greenMaxLuminance / redMaxLuminance));
constants.greenAdaptationBrightness = 255;

constants.maxTrialSeconds = 20;
constants.nextTrialDelay = 20;

end