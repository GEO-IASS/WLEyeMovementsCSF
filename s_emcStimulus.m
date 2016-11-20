%% Create harmonic sequences
%
%  Make the images of harmonics
%  Compute the cone mosaic responses and photocurrent responses
%  Show how to control eye movements
%
%  

%% Init Parameters
ieInit;

%% Here is a new function: oisCreate

% We are going to mix a grating (harmonic) with a uniform background.
% These are the relative weights of the grating and background.
% Set up the timing

% Gaussian onset and offset of the grating
stimWeights = ieScale(fspecial('gaussian',[1,50],15),0,1);
% Padded by zeroes
weights = [zeros(1, 30), stimWeights, zeros(1, 30)];

% This is the field of view of the scene.
sparams.fov = 0.5;

% Initialize the harmonic parameters structure with default
% Change entries that are common to uniform and harmonic
clear params
for ii=2:-1:1
    params(ii) = harmonicP; 
    params(ii).GaborFlag = 0.2;
    params(ii).freq      = 10;
end

% params(1) is for the uniform field
params(1).contrast  = 0.0;  % contrast of the two frequencies

% params(2) is matched and describes the grating
params(2).contrast = 0.4;

% The call to create the retinal image sequence
oisH = oisCreate('harmonic','blend',weights,'hparams',params,'sparams',sparams);

% Have a look, though the code here is not that great yet so the look is
% only approximate.
oisH.visualize;

%% Now, make the cone mosaic and compute absorptions and current

fov = oiGet(oisH.oiFixed,'fov');
tSamples = oisH.length;

cMosaic = coneMosaic;
cMosaic.integrationTime = 0.001;
cMosaic.setSizeToFOV(fov);

% Possibly, we should control the eye movement sequence
cMosaic.emGenSequence(tSamples);

% Compute and then look
cMosaic.compute(oisH);
cMosaic.window;

% Compute and look
cMosaic.os.noiseFlag = true;
cMosaic.computeCurrent;
cMosaic.window;

%% Create the current with and without noise

cMosaic.os.noiseFlag = false;
cMosaic.computeCurrent;
cMosaic.window;

%% How to adjust the eye movement parameters

% Pretty big tremor
em = emCreate;     % Create an eye movement object
em.emFlag = [1 1 1];  % Make sure tremor, draft and saccade are all on
em.tremor.amplitude = 0.02;  % Set the big amplitude
cMosaic.emGenSequence(tSamples,'em',em);  % Generate the sequence

cMosaic.plot('eye movement path');  % How did we do?
set(gca,'xlim',[-15 15],'ylim',[-15 15]);

% Make the tremor much smaller
em = emCreate;
em.emFlag = [1 1 1];
em.tremor.amplitude = 0.005;
cMosaic.emGenSequence(tSamples,'em',em);
cMosaic.plot('eye movement path');
set(gca,'xlim',[-15 15],'ylim',[-15 15]);

%%