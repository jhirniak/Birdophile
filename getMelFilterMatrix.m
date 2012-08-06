%melFilterMatrix(fs, N, nofChannels):
%compute mel filter coefficients 
%returns: Matrix (channelIndex, FFTIndex) 
%of mel filter coefficients.
%parameters:
%fs: Sampling rate [Hz], eg., 8000
%N: FFT length, eg., 256
%nofChannels: Number of mel channels, eg., 22
function W = getMelFilterMatrix(fs, N, nofChannels)

%compute resolution etc.
df = fs/N; %frequency resolution
Nmax = N/2; %Nyquist frequency index
fmax = fs/2; %Nyquist frequency
melmax = freq2mel(fmax); %maximum mel frequency

%mel frequency increment generating 'nofChannels' filters
melinc = melmax / (nofChannels + 1); 

%vector of center frequencies on mel scale
melcenters = (1:nofChannels) .* melinc;

%vector of center frequencies [Hz]
fcenters = mel2freq(melcenters);

%quantize into FFT indices
indexcenter = round(fcenters ./df);

%compute startfrequency, stopfrequency and bandwidth in indices
indexstart = [1 , indexcenter(1:nofChannels-1)];
indexstop = [indexcenter(2:nofChannels),Nmax];

%compute matrix of triangle-shaped filter coefficients
W = zeros(nofChannels,Nmax);
for c = 1:nofChannels
    %left ramp
    increment = 1.0/(indexcenter(c) - indexstart(c));
    for i = indexstart(c):indexcenter(c)
        W(c,i) = (i - indexstart(c))*increment;
    end %i
    %right ramp
    decrement = 1.0/(indexstop(c) - indexcenter(c));
    for i = indexcenter(c):indexstop(c)
       W(c,i) = 1.0 - ((i - indexcenter(c))*decrement);
    end %i
end %c


%normalize melfilter matrix
for j = 1:nofChannels
    W(j,:) = W(j,:)/ sum(W(j,:)) ;
end

end