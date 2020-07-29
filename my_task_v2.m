sca;
close all;
clearvars;
PsychDefaultSetup(2);

%screenNumber = max(Screen('Screens'));
screenNumber = 0;
Screen('Preference', 'SkipSyncTests', 0);

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

respCell = cell(1, 7);

%% complete task
%for round = 1:length(respCell)
    % generate random sequence
    seq = zeros(1,4);
    for i = 1:length(seq)
        seq(i) = randi(4);
        while i > 1 && seq(i) == seq(i - 1)
            seq(i) = randi(4);
        end
    end

    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    [xCenter, yCenter] = RectCenter(windowRect);
    ifi = Screen('GetFlipInterval', window);

    top = [0 0 100 100];
    bottom = [0 0 100 100];
    right = [0 0 100 100];
    left = [0 0 100 100];
    colors = [1 0 0; 0 0 1; 0 0.7 0; 0.8 0.8 0];

    vbl = Screen('Flip', window);
    waitframes = 1;

    topPriorityLevel = MaxPriority(window);
    Priority(topPriorityLevel);

    isiTimeSecs = 1;
    isiTimeFrames = round(isiTimeSecs / ifi);

    respMat = zeros(2, length(seq));

    topKey = KbName('UpArrow');
    bottomKey = KbName('DownArrow');
    leftKey = KbName('LeftArrow');
    rightKey = KbName('RightArrow');

    colorPattern = zeros(length(seq), 3);
    for i = 1:length(colorPattern)
        colorPattern(i, :) = colors(seq(i),:);
    end

    topRect = CenterRectOnPointd(top, 960, 270);
    bottomRect = CenterRectOnPointd(bottom, 960, 810);
    leftRect = CenterRectOnPointd(left, 480, 540);
    rightRect = CenterRectOnPointd(right, 1440, 540);
    rects = vertcat(topRect, bottomRect, leftRect, rightRect);
    rectPattern = zeros(length(seq), 4);
    for i = 1:length(rectPattern)
        rectPattern(i, :) = rects(seq(i),:);
    end

    time = 0;
    for trial = 1:length(seq)

        % if trial 1, present start screen and wait for key press
        if trial == 1
            DrawFormattedText(window, 'Memorize the sequence of squares \n\n Press any key to begin', 'center', 'center', white);
            Screen('Flip', window);
            KbStrokeWait;
        end

        for i = 1:isiTimeFrames
            Screen('FillRect', window, colorPattern(trial, :), rectPattern(trial, :));
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end    

    end

    DrawFormattedText(window, 'Enter the sequence you just saw using the arrow keys \n\n Press any key to continue', 'center', 'center', white);
    Screen('Flip', window);
    KbStrokeWait;

    Screen('FillRect', window, colors', rects');
    Screen('Flip', window);

    for i = 1:length(seq)

        respToBeMade = true;

        Screen('FillRect', window, colors', rects');
        vbl = Screen('Flip', window);

        for frame = 1:isiTimeFrames - 50
            Screen('FillRect', window, colors', rects');
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end

        while respToBeMade == true
            Screen('FillRect', window, colors', rects');
            textString = ['Enter key ' num2str(i)];
            DrawFormattedText(window, textString, 'center', 'center', white);
            [keyIsDown, secs, keyCode] = KbCheck;
            if keyCode(topKey)
                response = 1;
                respToBeMade = false;
            elseif keyCode(bottomKey)
                response = 2;
                respToBeMade = false;
            elseif keyCode(leftKey)
                response = 3;
                respToBeMade = false;
            elseif keyCode(rightKey)
                response = 4;
                respToBeMade = false;
            end
            vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        end
        respMat(1, i) = seq(i);
        respMat(2, i) = response;

    end
%end

DrawFormattedText(window, 'Experiment Finished \n\n Press any key to exit', 'center', 'center', white);
Screen('Flip', window);
KbStrokeWait;

sca;
