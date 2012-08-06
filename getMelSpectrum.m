%computeMelSpectrum (W,winShift,s)
%compute mel spectrum from time signal
%Returns mel spectral coefficients in
%matrix MEL.M(coefficientIndex,frameIndex).
%No energy normalization is performed.
%Signal energy 
%is copied from SPEC.e
%('computeSpectrum') to vector MEL.e(frameIndex).
%parameters:
%W: matrix(channelIndex,FFTIndex) of mel filter coefficients 
%winShift: window shift [number of samples]
%s: vector of time samples
function MEL = getMelSpectrum (W,winShift,s)
% compute local variables
[nofChannels,maxFFTIdx] = size(W);
fftLength = maxFFTIdx * 2;

% compute matrix X(fftIndex,timeFrameIndex) short term spectra
SPEC = getSpectrum(fftLength,winShift,s);

% apply mel filter to spectra

MEL.M = W * SPEC.X;

%copy energy vector
MEL.e = SPEC.e ;

end