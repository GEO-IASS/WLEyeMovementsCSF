%% Create harmonic sequences
%
%  Make the images of harmonics
%  Compute the cone mosaic responses and photocurrent responses
%  Show how to control eye movements
%
%  

%% Init Parameters
ieInit;

%% Create scenes

% To create each oiSequence we need two types of scenes: one with a
% constant image and one with a time-varying presentation of the stimulus.
scene = cell(2, 1);

clear params
params.freq =  10; % spatial frequencies of 1 and 5
params.contrast = 0.9; % contrast of the two frequencies
params.ang  = [0, 0]; % orientations
params.ph  = [0 0]; % phase
params.GaborFlag = 0.25;
scene{1} = sceneCreate('harmonic',params);

scene{1} = sceneSet(scene{1},'name',sprintf('F %d',params.freq));
ieAddObject(scene{1});

% Create scene: background field only, no harmonic
clear params
params.freq =  0; % spatial frequencies of 1 and 5
params.contrast = 0; % contrast of the two frequencies
params.ang  = [0, 0]; % orientations
params.ph  = [0 0]; % phase
scene{2} = sceneCreate('harmonic',params);
scene{2} = sceneSet(scene{2},'name','Uniform');
ieAddObject(scene{2});

imgFov = .5 ;      % image field of view
vDist  = 0.3;          % viewing distance (meter)

% set scene fov
for ii = 1 : length(scene)
    scene{ii} = sceneSet(scene{ii}, 'h fov', imgFov);
    scene{ii} = sceneSet(scene{ii}, 'distance', vDist);
end
sceneWindow

%% Compute human optical image sequences

% Create a typical human lens.  It will be possible to set the parameters
% for future experiments using
%
%   oi = oiCreate('wvf human',pupilMM,zCoefs,wave)
% 
% These are the default.
oi = oiCreate('wvf human');

% Compute optical images from the scene
OIs = cell(length(scene), 1);
for ii = 1 : length(OIs)
    OIs{ii} = oiCompute(oi,scene{ii});
end
% for ii=1:2, vcAddObject(OIs{ii}); end; oiWindow;

%% Build the oiSequence

% We build the stimulus using a time series of weights. We have the mean
% field on for a while, then rise/fall, then mean field.
zTime = 50;   % Mean field beginning and end (ms)
stimWeights = fspecial('gaussian',[1,50],15);
stimWeights = ieScale(stimWeights,0,1);
weights = [zeros(1, zTime), stimWeights, zeros(1, zTime)];

% Temporal samples.  Typically 1 ms, which is set by the parameter in the
% cone mosasic integration time.  That time is locked to the eye movements.
tSamples = length(weights); 
sampleTimes = 0.002*(1:tSamples);  % Time in sec

% vcNewGraphWin; plot(1:tSamples, weights,'o');
% xlabel('Time (ms)');

% The weights define some amount of the constant background and some amount
% of the line on the same constant background
oiHarmonicSeq = oiSequence(OIs{2}, OIs{1}, ...
    sampleTimes, weights, ...
    'composition', 'blend');
oiHarmonicSeq.visualize('format','movie');

%% Set up the photon absorptions from the sequence

cMosaic = coneMosaic;
cMosaic.integrationTime = 0.002;
cMosaic.setSizeToFOV(0.5);
cMosaic.emGenSequence(tSamples);
cMosaic.compute(oiHarmonicSeq);

%% Create the current with and without noise

cMosaic.os.noiseFlag = false;
cMosaic.computeCurrent;
cMosaic.window;

%% These are the impulse response functions

cMosaic.plot('os current filters');

%% Adjust the eye movement parameters

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
