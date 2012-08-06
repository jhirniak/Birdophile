%compute spectrum from time signal
%Returns power spectrum (|X(f)|^2) in
%matrix SPEC.X(coefficientIndex,frameIndex) .
%No energy normalization is performed.
%The signal energy (sum of power spectrum coefficients)
%is returned in vector SPEC.e(frameIndex)
%parameters:
%fftLength: length of FFT
%winShift: window shift [number of samples]
%s: vector of time samples
function SPEC = getSpectrum (fftLength,winShift,s)
%compute local variables
nofSamples = size(s);
maxFFTIdx = fftLength/2;
%compute time window
win = hamming(fftLength);

%compute matrix X(fftIndex,timeFrameIndex) short term spectra

k = 1;
for m = 1:winShift:nofSamples-fftLength
 
    spec = fft( (win.*s(m:m+fftLength-1)) ,fftLength);
    %use only lower half of fft coefficients
    SPEC.X(:,k) = ( abs( spec(1:maxFFTIdx) ) ).^2;    
    %compute energy
    SPEC.e(k) = sum(SPEC.X(:,k));
    k = k+1;
end %m

end