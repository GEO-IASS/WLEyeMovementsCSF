%% Create harmonic sequences
%
%  Make the images of harmonics
%  Compute the cone mosaic responses and photocurrent responses
%  Show how to control eye movements
%
%  

%% Init Parameters
ieInit;

%% Create display model
% ppi    = 500;          % points per inch
% sensorFov = [.15 .15]; % field of view of retina

% % compute number of pixels in image
% imgSz  = round(tand(imgFov)*vDist*(ppi/dpi2mperdot(1,'m')));
% 
% % compute actual fov of image, should be very close to desired fov
% imgFov = atand(max(imgSz)/ppi/(1/dpi2mperdot(1,'m'))/vDist);
% 
% % Create virtual display
% display = displayCreate('LCD-Apple', 'dpi', ppi);

%% Create scenes

% To create each oiSequence we need two types of scenes: one with a
% constant image and one with a time-varying presentation of the stimulus.
%
% We also want a pair of oiSequences, one for the offset and another with
% no offset.  We estimate the probability of discrimination by comparing
% these two sequences.
%

% Init scene cell array.  The background is constant and used for both of
% the oiSequences.  The two line scenes are added to the background.  One
% of the scenes has an offset and the other is a continuous line
%
% scene{1} - one aligned line
% scene{2} - two line segments with 1 pixel offset
% scene{3} - uniform background
scene = cell(2, 1);

clear params
params.freq =  10; % spatial frequencies of 1 and 5
params.contrast = 0.6; % contrast of the two frequencies
params.ang  = [0, 0]; % orientations
params.ph  = [0 0]; % phase
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

%%
cMosaic = coneMosaic;
cMosaic.integrationTime = 0.002;
cMosaic.setSizeToFOV(1);
cMosaic.emGenSequence(tSamples);
cMosaic.compute(oiHarmonicSeq);
cMosaic.computeCurrent;
cMosaic.window;

%% Adjust the eye movement parameters

% How to adjust
em = emCreate;
em.emFlag = [1 1 1];
em.tremor.amplitude = 0.02;
cMosaic.emGenSequence(tSamples,'em',em);
cMosaic.plot('eye movement path');
set(gca,'xlim',[-15 15],'ylim',[-15 15]);

% How to adjust
em = emCreate;
em.emFlag = [1 1 1];
em.tremor.amplitude = 0.005;
cMosaic.emGenSequence(tSamples,'em',em);
cMosaic.plot('eye movement path');
set(gca,'xlim',[-15 15],'ylim',[-15 15]);
