%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
clc
clear all
rand('state',0);
randn('state',0);
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
addpath 'common'
addpath 'transmitter'
%-------------------------------------------------------------------------%
% load cm1_to_8__32MHz.mat 
% figure
% plot(abs(h1))
% title('LOS Residential (CM1)')
%-------------------------------------------------------------------------%
%-*****************  transceiver configurations  ************************-%
%-------------------------------------------------------------------------%
% dataRateArray = [ 0 1 ];  % 0 for  1 Mb/s  , 1  for 250 kb/s
% Set the global Variables for both Transmitter and Receiver 
global chirpIndex ;     % chirp Sequence Index= 1, 2, 3 or 4
global samplingFreqMhz; % Sampling Frequency in MHz
global carrierFreqGHz;  % Carrier frequency in GHz
global codeWordLengthStd;
global preambleLengthStd;
global Tchirp;
global Tsub;

global TxDACbitNumber;
global chirpSequenceNumBit_Rx;
% 
global TxChirpSequencesLength;
%=========================================================================%
%======================== Simulation parameters script ===================%
%=========================================================================%
simulationParameters
%=========================================================================%
EbNodB = [ startEbNodB : stepEbNodB : stopEbNodB ];

%-------------------------------------------------------------------------%
globalSettings();
frequencyOffsetkHz = offsetPPM *carrierFreqGHz;
phaseRotationPerSample = 2*pi*frequencyOffsetkHz/samplingFreqMhz/1000;

%-------------------------------------------------------------------------%
numDataRatesToSimulate = length(dataRateArray);
numSNRlevelsToSimulate = length(EbNodB);

% pre-allocating just for speed simulation
numPacketErrors=zeros(numDataRatesToSimulate,numSNRlevelsToSimulate);
numSimulatedPackets=zeros(numDataRatesToSimulate,numSNRlevelsToSimulate);
numSyncPassedPackets=zeros(numDataRatesToSimulate,numSNRlevelsToSimulate);
sumFreqOffsetHz=zeros(numDataRatesToSimulate,numSNRlevelsToSimulate);
sumSNR_estimationErrordB_Squared = zeros(numDataRatesToSimulate,numSNRlevelsToSimulate);
sumFreqOffsetHzSquared=zeros(numDataRatesToSimulate,numSNRlevelsToSimulate);
%[CIRmatrix ] = CIRselection( selectedCIRindex );

%profile on
%-------------------------------------------------------------------------%
for numDataRate = 1 : numDataRatesToSimulate
%-------------------------------------------------------------------------%
dataRate = dataRateArray(numDataRate);
%=========================================================================%
if dataRate == 0 
     rate = '1 Mb/s';
     codingRate = 3/4;  % 1 Mb/s code rate of block coding
     codeWordLength = codeWordLengthStd(1);
else
     rate = '250 kb/s';
     codingRate = 6/32;  % 250 kb/s code rate of block coding
     codeWordLength = codeWordLengthStd(2);
end
% Find the number of samples in preamble
numPreambleSamples=preambleLengthStd(dataRate+1)*Tchirp/4;
%-------------------------------------------------------------------------%
tic
%-------------------------------------------------------------------------%
% This function generates the chirp sequence which consists of 4 chirp
% subsequences, accroding to equation (1a) and figure 20c
chirpSequence = chirpSequenceGenerator(chirpIndex, samplingFreqMhz );
% ####################################################################### %
% ----------------- Fixed Point Representation -------------------------- %
% put chirp sequence samples in (TxDACbitNumber)signed bit integer.
chirpSequence_Tx = floor ( chirpSequence * (2^(TxDACbitNumber -1)-1) ) ;
%-------------------------------------------------------------------------%
% ###################### file Input Output ############################## %
            chirpSequenceReal_tofile = real(chirpSequence_Tx(1:end));
            chirpSequenceImag_tofile = imag(chirpSequence_Tx(1:end));
            re = fi(chirpSequenceReal_tofile,1,6,0);
            im = fi(chirpSequenceImag_tofile,1,6,0);
            
            for n = 1 : length(chirpSequenceReal_tofile)
                bin2comreal(n,:) = bin(re(n));
                bin2comimag(n,:) = bin(im(n));
            end
            fid = fopen('chirpSequenceReal_tofile.txt', 'wt' );
            fprintf(fid, '%c%c%c%c%c%c\n',transpose (bin2comreal));
            fclose (fid);
            
            fid = fopen('chirpSequenceImag_tofile.txt', 'wt' );
            fprintf(fid, '%c%c%c%c%c%c\n',transpose (bin2comimag));
            fclose (fid);
% ###################### file Input Output ############################## %
%-------------------------------------------------------------------------%
% chirpSequence_Tx = chirpSequence_Tx / (2^(TxDACbitNumber -1)-1);
% ####################################################################### %

energyPerSubChirp=sum(sum(abs(chirpSequence_Tx).^2))/4;
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%
%-------------------------------------------------------------------------%

% ------------------------------------------------------------------------- %
% --- ADDED CODE: Generate dummy data and call the Tx function ---
% ------------------------------------------------------------------------- %
% 1. Create a dummy payload (e.g., 10 bytes = 80 bits)
dummyPayloadBytes = 10;
incomingStream = randi([0 1], 1, dummyPayloadBytes * 8);

% 2. Call the transmitter function to trigger the .txt file generations
% Note: Change the function name to ChirpSpreadSpectrum_Tx_3 if that is 
% the exact name of your modified function file.
TxchirpSequences = ChirpSpreadSpectrum_Tx(incomingStream, dataRate, chirpSequence);
% ------------------------------------------------------------------------- %


end

%% === DQPSK encoder standalone golden-vector export (added by Salama) ===
% Self-contained: does not depend on, or affect, anything above this line.
% Generates deterministic Xn stimulus cycling through all 4 rotation
% cases, computes the matching Sn golden output using the standard's own
% recurrence (Sn = Xn * Sn-4, S0=S1=S2=S3=exp(j*pi/4)), and exports both
% as 2-bit signed binary vectors for the Verilog testbench to read in
% with $readmemb.

numSymbols_dqpsk = 24;   % two full passes through all 4 rotation cases

XnTable_dqpsk = [ 1+0j, 0+1j, -1+0j, 0-1j ];   % k=0,1,2,3 base cases
Xn_dqpsk = XnTable_dqpsk( mod(0:numSymbols_dqpsk-1, 4) + 1 );

Sn_dqpsk = zeros(1, numSymbols_dqpsk);
Sdelay_dqpsk = exp(1j*pi/4) * ones(1,4);   % [Sn-1 Sn-2 Sn-3 Sn-4]

for n = 1:numSymbols_dqpsk
    Sn4_dqpsk        = Sdelay_dqpsk(4);
    Sn_dqpsk(n)      = Xn_dqpsk(n) * Sn4_dqpsk;
    Sdelay_dqpsk     = [Sn_dqpsk(n) Sdelay_dqpsk(1:3)];
end

Xn_re_dqpsk = fi(real(Xn_dqpsk), 1, 2, 0);
Xn_im_dqpsk = fi(imag(Xn_dqpsk), 1, 2, 0);
Sn_re_dqpsk = fi(real(Sn_dqpsk), 1, 2, 0);
Sn_im_dqpsk = fi(imag(Sn_dqpsk), 1, 2, 0);

fid = fopen('xn_real_tb.txt', 'wt');
for n = 1:numSymbols_dqpsk
    fprintf(fid, '%s\n', bin(Xn_re_dqpsk(n)));
end
fclose(fid);

fid = fopen('xn_imag_tb.txt', 'wt');
for n = 1:numSymbols_dqpsk
    fprintf(fid, '%s\n', bin(Xn_im_dqpsk(n)));
end
fclose(fid);

fid = fopen('sn_real_expected.txt', 'wt');
for n = 1:numSymbols_dqpsk
    fprintf(fid, '%s\n', bin(Sn_re_dqpsk(n)));
end
fclose(fid);

fid = fopen('sn_imag_expected.txt', 'wt');
for n = 1:numSymbols_dqpsk
    fprintf(fid, '%s\n', bin(Sn_im_dqpsk(n)));
end
fclose(fid);
%% === end DQPSK encoder export ===

%% === Universal CSK ROM (m=1) export for Verilog ===
% Self-contained: generates the base m=1 sequence (152 samples containing
% all 4 fundamental subchirps), quantizes them to 6-bit signed fixed-point, 
% and exports them as binary text strings for Verilog $readmemb.
disp('Generating Universal CSK ROM (m=1) for Verilog...');

csk_base_seq = chirpSequenceGenerator(1, samplingFreqMhz);

csk_re_fi = fi(real(csk_base_seq(1:152)), 1, 6, 0);
csk_im_fi = fi(imag(csk_base_seq(1:152)), 1, 6, 0);

fid_rom_i = fopen('csk_rom_i.txt', 'wt');
fid_rom_q = fopen('csk_rom_q.txt', 'wt');

for n = 1:152
    fprintf(fid_rom_i, '%s\n', bin(csk_re_fi(n)));
    fprintf(fid_rom_q, '%s\n', bin(csk_im_fi(n)));
end

fclose(fid_rom_i);
fclose(fid_rom_q);
disp('Successfully generated csk_rom_i.txt and csk_rom_q.txt');
%% === end Universal CSK ROM export ===

%% === dqpsk_csk_multiplier unit-test vectors ===
% Reuses Sn_dqpsk/numSymbols_dqpsk from the "DQPSK encoder standalone
% golden-vector export" block above. i_c/q_c come from chirpSequence_Tx
% (the real fixed-point chirp samples already computed earlier in this
% script) -- NOT from TxchirpSequences, since that's already post-multiply.
MAX_VECTORS = 64;
numVec = min(MAX_VECTORS, numSymbols_dqpsk);

ic_flat = real(chirpSequence_Tx(:));   % already 6-bit-range fixed-point ints
qc_flat = imag(chirpSequence_Tx(:));
numVec  = min(numVec, length(ic_flat));

% round(): Sn_dqpsk's magnitude-1 normalization (exp(j*pi/4) init) means
% these land on +/-0.7071 exactly, not +/-1 -- must round to an integer
% before writing with %d, or fprintf silently switches to %e notation
% and desyncs every $fscanf read after the first one.
s_real_vec = round(real(Sn_dqpsk(1:numVec))).';
s_imag_vec = round(imag(Sn_dqpsk(1:numVec))).';
ic_vec     = ic_flat(1:numVec);
qc_vec     = qc_flat(1:numVec);

css_real_vec = s_real_vec.*ic_vec - s_imag_vec.*qc_vec;  % same formula as
css_imag_vec = s_real_vec.*qc_vec + s_imag_vec.*ic_vec;  % dqpsk_csk_multiplier.v

fid = fopen('s_real_mult_tb.txt','wt');    fprintf(fid,'%d\n', s_real_vec); fclose(fid);
fid = fopen('s_imag_mult_tb.txt','wt');    fprintf(fid,'%d\n', s_imag_vec); fclose(fid);
fid = fopen('ic_mult_tb.txt','wt');        fprintf(fid,'%d\n', ic_vec);     fclose(fid);
fid = fopen('qc_mult_tb.txt','wt');        fprintf(fid,'%d\n', qc_vec);     fclose(fid);
fid = fopen('css_real_expected.txt','wt'); fprintf(fid,'%d\n', css_real_vec); fclose(fid);
fid = fopen('css_imag_expected.txt','wt'); fprintf(fid,'%d\n', css_imag_vec); fclose(fid);

fprintf('mult tb export: %d vectors\n', numVec);
%% === end dqpsk_csk_multiplier unit-test export ===