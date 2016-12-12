%% Comments here

%%
ieInit;

%% Initialize parameters

% Gaussian onset and offset of the grating
stimWeights = ieScale(fspecial('gaussian',[1,50],15),0,1);
% Padded by zeroes
weights = [zeros(1, 30), stimWeights, zeros(1, 30)];

% This is the field of view of the scene.
sparams.fov = 0.5;

% Initialize the harmonic parameters structure with default
% Change entries that are common to uniform and harmonic
freq = [2 30 40];
ratios = zeros(3,1);
for a = 1:length(freq)
    clear params
    for ii=2:-1:1
        params(ii) = harmonicP;
        params(ii).GaborFlag = 0.2;
        params(ii).freq      = freq(a);
        params(ii).row = 256;
        params(ii).col = 256;
    end
    
    % params(1) is for the uniform field
    params(1).contrast  = 0.0;  % contrast of the two frequencies
    
    % params(2) is matched and describes the grating
    params(2).contrast = 1;
    
    % The call to create the retinal image sequence
    oisH = oisCreate('harmonic','blend',weights,'testParameters',params,'sceneParameters',sparams);
    
    fov = oiGet(oisH.oiFixed,'fov');
    tSamples = oisH.length;
    
    cMosaic = coneMosaic;
    cMosaic.integrationTime = 0.001;
    cMosaic.setSizeToFOV(fov);
    
    % create em object without movement
    em_noMovement = emCreate;     % Create an eye movement object
    em_noMovement.emFlag = [0 0 0];  % Make sure tremor, draft and saccade are all off
    cMosaic.emGenSequence(tSamples,'em',em_noMovement);  % Generate the sequence
    cMosaic.compute(oisH);
    cMosaic.computeCurrent;
    
    deMeanedMosaic = bsxfun(@minus,cMosaic.current,mean(cMosaic.current,3));
    % deMeanedMosaic = cMosaic.current-mean(cMosaic.current,3);

    padNumFrames = 2^nextpow2(length(cMosaic.current(1,1,:)));
    Spectra_noMovements = abs(fftshift(fft(deMeanedMosaic,padNumFrames,3)));
    avgSpectrum_noMovements = squeeze(sum(sum(Spectra_noMovements)))./93^2;
    
    % create em object with movement
    emF = 3; emA = 3;
    x = round(emA*sin(2*pi*emF*(1:tSamples)/tSamples));
    y = zeros(size(x(:)));
    cMosaic.emPositions = [x(:),y(:)];
    cMosaic.name = 'Horizontal em';
    cMosaic.plot('eye movement path');
    cMosaic.compute(oisH);
    cMosaic.computeCurrent;
    
    deMeanedMosaic = bsxfun(@minus,cMosaic.current,mean(cMosaic.current,3));
    % deMeanedMosaic = cMosaic.current-mean(cMosaic.current,3);
    Spectra_withMovements = abs(fftshift(fft(deMeanedMosaic,padNumFrames,3)));
    avgSpectrum_withMovements = squeeze(sum(sum(Spectra_withMovements)))./93^2;
    
    avgSpectraAmp = sum(sum(Spectra_withMovements./Spectra_noMovements))./93^2;
    figure
    plot(squeeze(avgSpectraAmp(64:128))) % plot positive frequency ratios
    str = sprintf('spatial freq = %d',freq(a));
    title(str);
    ratios(a) = avgSpectraAmp(66);
end

%% Plot results
vcNewGraphWin;
plot(squeeze(sum(sum((Spectra_noMovements)))))


vcNewGraphWin;
plot(squeeze(sum(sum((Spectra_withMovements)))))
ratios

for i = 1:10
    vcNewGraphWin;
    plot(squeeze(Spectra_noMovements(5*i,5*i,:)))
    vcNewGraphWin;
    plot(squeeze(Spectra_withMovements(5*i,5*i,:)))
end
