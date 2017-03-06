%28.5 pixels/cm, so speeds are:
    %Ball: 142.5, 199.5, 256.5, 313.5, 370.5, 427.5
    %Tally: None, 0, 213.75, 427.5, -213.75, -427.5
    %CoR: .1, .5, .9

%Function takes in variables and generates movie
function f = make_collision(ballVel, tallyVis, tallySpeed, CoR)

% Open the screen
Screen('Preference', 'SkipSyncTests', 1)
[windowPtr, rect] = Screen('OpenWindow',0)

% Find the screen dimensions
screenWidth = rect(3); % This is the width of your screen in pixels
screenHeight = rect(4); % This is the height of your screen in pixels

% Specify the sizes of the objects
lineWidth = 3; 
ballRad = screenWidth/50;

% Specify the starting position of the ball [xPosition; yPosition]
%Start at center of screen
ball1PosInit = [screenWidth * (1/2); screenHeight * (1/2)]; 
%Start just off screen
ball2PosInit = [0- ballRad; screenHeight * (1/2)];

% Specify the starting velocity of the ball and tallys
ball1Vel = [0;0]; %Projectile stationary
ball2Vel = [ballVel; 0]; %Provided Motor Speed
tallyVel = [tallySpeed; 0]; %Provided tally Speed
tallyWidth = 100;

frameRate = 30; % Frame rate of 30 Hz (30 frames per second)
dt = 1/frameRate; % Time between frames (Period = 1/Frequency)

% Initialize the ball's position for while loop
ball1Pos = ball1PosInit;

% Initialize time, collision time, and CoR
time = 0;
collide = false;
col_time = 0;

% Initialize a cell array which holds the image array for each frame
imageCell = {};

% Loop to generate the animation until the ball
while ball1Pos(1)+ballRad < screenWidth
    
    % Determine the ball's position at t = time
    ball1Pos = ball1PosInit + ball1Vel  * (col_time + dt);
    
    if ~collide
        ball2Pos = ball2PosInit + ball2Vel  * time;
    else
        ball2Pos = ball2PosInit + ball2Vel  * col_time;
    end
    
    
    %Draw Ball at positions
    tallyOne = mod(tallyVel(1) * time, tallyWidth) ;
    
    %Draw vertical lines
    if tallyVis
        while tallyOne < screenWidth
        Screen('DrawLine',windowPtr, [200 200 200], tallyOne, screenHeight, tallyOne, 0, 2)
        tallyOne = tallyOne + tallyWidth;
        end
    end
 
    %Draw projectile ball
    Screen('FillOval',windowPtr,[0 0 0],[ball1Pos(1)-ballRad,ball1Pos(2)-ballRad,ball1Pos(1)+ballRad,ball1Pos(2)+ballRad])
    Screen('FrameOval',windowPtr,[0 0 0],[ball1Pos(1)-ballRad,ball1Pos(2)-ballRad,ball1Pos(1)+ballRad,ball1Pos(2)+ballRad],lineWidth)
    
    %Draw motor ball
    Screen('FillOval',windowPtr,[0 0 0],[ball2Pos(1)-ballRad,ball2Pos(2)-ballRad,ball2Pos(1)+ballRad,ball2Pos(2)+ballRad])
    Screen('FrameOval',windowPtr,[0 0 0],[ball2Pos(1)-ballRad,ball2Pos(2)-ballRad,ball2Pos(1)+ballRad,ball2Pos(2)+ballRad],lineWidth)
    
    %Collision event occurs
    if ball2Pos(1) >= screenWidth * (1/2) - ballRad*2 && ~collide
        
        %Sandborn final velocity generation:
        %Random sample to find masses, ask James if should be held constant
        
        %va = (ma .* ua + mb .* (ub + e .* (ub - ua)))./(ma + mb);
        ma = 1;
        mb = 1;
        va = ball1Vel(1);
        vb = ball2Vel(1);
        ball1Vel(1) = (ma * va + mb * (vb + CoR * (vb - va)))/(ma + mb);
        ball2Vel(1) = (ma * vb + mb * (va + CoR * (va - vb)))/(ma + mb);
        
        ball2PosInit = ball2Pos;
        collide = true;
    end
        
    
    % Add dt to time so the ball will have a new position in the next frame
    time = time + dt;
    
    %Update time after collide
    if collide
        col_time = col_time + dt;
    end
    %%
    % Flip the screen. This displays everything you've drawn
    Screen('Flip',windowPtr)
    
    % Grab the image array (matrix) and save it into an element of a cell
    % array, which will be used to write the frames to a video after the
    % loop
    imageCell{end+1} = Screen('GetImage', windowPtr);

end

%%
% Close window once the animation is finished; this tells the screen to go
% back to displaying your desktop or whatever; "windowPtr" is the window
% parameter that was specified when opening the screen
Screen(windowPtr,'Close')

% Create a video object and specify the frame rate

if tallyVis
    trialName = strcat( 'V',num2str(ballVel), '_T',num2str(tallySpeed),'_e', num2str(CoR), '.mp4');
end
if ~tallyVis
    trialName = strcat( 'V',num2str(ballVel), '_TNone', '_e', num2str(CoR),'.mp4');
end

vidObj = VideoWriter(trialName, 'MPEG-4');
vidObj.FrameRate = frameRate;
open(vidObj);

% Go through each element in the cell array (imageCell) and feed that in as
% the image for the video object (this is a little weird but you can just 
% copy and paste this code, you don't really need to understand it.
for i = 1:length(imageCell)
    writeVideo(vidObj,imageCell{i});
end
close(vidObj);
end

