%% s_rvExamples
%
% Here are some general tips on how to create stimuli and cone encodings
% for analyzing the Rucci-Victor (rv) paper
%
% Wandell, ISETBIO Team, 2016

%%
ieInit;

%% Create a Gabor patch

% If you want to see the default parameters of the harmonic, you can run
% this piece of code
%
%   [~, parms] = imageHarmonic;
%

parms.freq = 10;     % Spatial frequency in cycles per image
parms.contrast = 1;  % Gabor contrast
parms.ph  = 0;       % Phase
parms.ang = 0;       % Angle
parms.row = 128;     % Spatial samples
parms.col = 128;
parms.GaborFlag= 0.2;% Std. Deviation of the Gaussian

gabor = sceneCreate('harmonic',parms);   % Creates the scene
gabor = sceneSet(gabor,'fov',1);         % Field of view
gabor = sceneSet(gabor,'name','gabor');

% Make a blank scene with the same mean field
parms.contrast = 0.001;
blank = sceneCreate('harmonic',parms);
blank = sceneSet(blank,'fov',1);
blank = sceneSet(blank,'name','blank');

% Have a look
ieAddObject(gabor); ieAddObject(blank);
sceneWindow;

%%  Make a human image formation structure

oi = oiCreate('human');
oiG = oiCompute(oi,gabor);
oiB = oiCompute(oi,blank);

ieAddObject(oiG); ieAddObject(oiB);
oiWindow;

%% Make a little cone mosaic

cmosaic = coneMosaic;
cmosaic.setSizeToFOV(0.8);  % Make it a bit smaller than the image

% 1 ms time base
cmosaic.integrationTime = 0.001;

tSamples = 500;   % Let's experiment with 
cmosaic.emGenSequence(tSamples);
cmosaic.compute(oiG);

