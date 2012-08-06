%Computes Mel-frequency cepstral coefficients (MFCCs) 
%MFCCs are coefficients that collectively make up an MFC.
%They are derived from a type of cepstral representation of the audio clip
%(a nonlinear "spectrum-of-a-spectrum"). The difference between the cepstrum 
%and the mel-frequency cepstrum is that in the MFC, the frequency bands are
%equally spaced on the mel scale, which approximates the human auditory system's
%response more closely than the linearly-spaced frequency bands used in the normal cepstrum.
%For more see:
%http://en.wikipedia.org/wiki/Mel_Frequency_Cepstral_Coefficients
function mffcs = getMFCCs(rawSample)
%Define parameters
fs=44100;
fftL=256;
wl=30;
noC=13;

%sampling frequency
%standarize frequency of the rawSample
sample.data = rawSample;
sample.length = length(rawSample);
sample.fs = fs;
sample.N=fftL;
%time shift is 10ms
sample.shift = wl*sample.fs/1000;
%number of mel filter channels
sample.channels = noC;

%compute matrix of mel filter coefficients
sample.W = getMelFilterMatrix(sample.fs,sample.N,sample.channels);
%compute mel spectra
sample.MEL = getMelSpectrum(sample.W,sample.shift,sample.data);
sample.nofFrames = size(sample.MEL.M,2);
sample.nofMelChannels = size(sample.MEL.M,1);

%normalize energy of mel spectra
%take log value

epsilon = 10e-5;
for k = 1:sample.nofFrames
    for c = 1:sample.nofMelChannels
        %normalize energy
        %data.MEL.M(c,k) = data.MEL.M(c,k)/data.MEL.e(k);
        %take log energy
        sample.MEL.M(c,k) = loglimit(sample.MEL.M(c,k),epsilon);        
    end
end

mffcs = sample.MEL.M(2:end,:);
end