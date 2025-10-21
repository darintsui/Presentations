
clear all; close all; clc
cd 'D:\Program Files\EEGLAB\eeglab2021.0'
eeglab
cd 'C:\Users\Darin Tsui\MotorImagery-1'

%% Initialize parameters
LH_ch = cell(1);
RH_ch = cell(1);
FT_ch = cell(1);
TG_ch = cell(1);
LH_chT = cell(1);
RH_chT = cell(1);
FT_chT = cell(1);
TG_chT = cell(1);

% Get PSD after time delay
fs = 250; % 250 Hz sampling rate
% 1 second delay
t_start = round(fs * 1);
% 3 second delay
t_end = round(fs * 3);

ind8 = 17;
ind30 = 61;

LH = cell(1);
RH = cell(1);
FT = cell(1);
TG = cell(1);
LHT = cell(1);
RHT = cell(1);
FTT = cell(1);
TGT = cell(1);

%% Epoch Train Samples

cd BCICIV_2a_gdf
datasets_train = ["A01T.gdf","A02T.gdf","A03T.gdf","A04T.gdf","A05T.gdf","A06T.gdf","A07T.gdf","A08T.gdf","A09T.gdf"];

for i = 1:length(datasets_train)
    
    % Load gdf and epoch data
    [s, h] = sload(sprintf('%s',datasets_train(i)), 0, 'OVERFLOWDETECTION:OFF');
    [start_trial_t, LH_t, RH_t, FT_t, TG_t] = epoch_train(h);
    [LH_ch, RH_ch, FT_ch, TG_ch] = epoch(LH_t, RH_t, FT_t, TG_t, LH_ch, RH_ch, FT_ch, TG_ch, t_start, t_end, start_trial_t, s);
    
    % Compute PSD
    [LH_p, RH_p, FT_p, TG_p] = psd(LH_ch, RH_ch, FT_ch, TG_ch, fs);
    
    % Extract 8-30 Hz, and channels X, Y, and Z
    [LH_bp, RH_bp, FT_bp, TG_bp] = bandpass(LH_p, RH_p, FT_p, TG_p, ind8, ind30, 8, 10, 12);
    
    % Combine all results
    LH(i) = {cat(1, LH_bp{:,1})};
    RH(i) = {cat(1, RH_bp{:,1})};
    FT(i) = {cat(1, FT_bp{:,1})};
    TG(i) = {cat(1, TG_bp{:,1})};
    
end

% Combine results into one matrix
LH_train = {cat(1, LH{:})};
RH_train = {cat(1, RH{:})};
FT_train = {cat(1, FT{:})};
TG_train = {cat(1, TG{:})};

LH_train = LH_train{1};
RH_train = RH_train{1};
FT_train = FT_train{1};
TG_train = TG_train{1};
% % Note: To load gdf files you must download the EEGLAB plugin
% [s, h] = sload('A01T.gdf', 0, 'OVERFLOWDETECTION:OFF');
% [s_test, h_test] = sload('A01E.gdf', 0, 'OVERFLOWDETECTION:OFF');
% test_label = load('A01E.mat')

%% Epoch Test Samples

datasets_test = ["A01E.gdf","A02E.gdf","A03E.gdf","A04E.gdf","A05E.gdf","A06E.gdf","A07E.gdf","A08E.gdf","A09E.gdf"];
datasets_test_label = ["A01E.mat","A02E.mat","A03E.mat","A04E.mat","A05E.mat","A06E.mat","A07E.mat","A08E.mat","A09E.mat"];

for i = 1:length(datasets_test)
    
    % Load gdf and epoch data
    [s, h] = sload(sprintf('%s',datasets_test(i)), 0, 'OVERFLOWDETECTION:OFF');
    test_label = load(sprintf('%s',datasets_test_label(i)));
    [start_trial_tT, LH_tT, RH_tT, FT_tT, TG_tT] = epoch_test(h, test_label);
    [LH_chT, RH_chT, FT_chT, TG_chT] = epoch(LH_tT, RH_tT, FT_tT, TG_tT, LH_chT, RH_chT, FT_chT, TG_chT, t_start, t_end, start_trial_tT, s);
    
    % Compute PSD
    [LH_pT, RH_pT, FT_pT, TG_pT] = psd(LH_chT, RH_chT, FT_chT, TG_chT, fs);
    
    % Extract 8-30 Hz, and channels X, Y, and Z
    [LH_bpT, RH_bpT, FT_bpT, TG_bpT] = bandpass(LH_pT, RH_pT, FT_pT, TG_pT, ind8, ind30, 8, 10, 12);
    
    % Combine all results
    LHT(i) = {cat(1, LH_bpT{:,1})};
    RHT(i) = {cat(1, RH_bpT{:,1})};
    FTT(i) = {cat(1, FT_bpT{:,1})};
    TGT(i) = {cat(1, TG_bpT{:,1})};
    
end

% Combine results into one matrix
LH_test = {cat(1, LHT{:})};
RH_test = {cat(1, RHT{:})};
FT_test = {cat(1, FTT{:})};
TG_test = {cat(1, TGT{:})};

LH_test = LH_test{1};
RH_test = RH_test{1};
FT_test = FT_test{1};
TG_test = TG_test{1};
%% Export as csv

train_X = [LH_train; RH_train; FT_train; TG_train];
train_Y = [ones(1,length(LH_train))'; 2*ones(1,length(RH_train))'; 3*ones(1,length(FT_train))'; 4*ones(1,length(TG_train))'];
test_X = [LH_test; RH_test; FT_test; TG_test];
test_Y = [ones(1,length(LH_test))'; 2*ones(1,length(RH_test))'; 3*ones(1,length(FT_test))'; 4*ones(1,length(TG_test))'];

writematrix(train_X,'../train_X.csv') 
writematrix(train_Y,'../train_Y.csv')
writematrix(test_X,'../test_X.csv') 
writematrix(test_Y,'../test_Y.csv')
cd ..

%% Functions Section

function [start_trial_t, LH_t, RH_t, FT_t, TG_t] = epoch_train(h)

% Train Session
start_trial = find(h.EVENT.TYP == 768);
LH = find(h.EVENT.TYP == 769);
RH = find(h.EVENT.TYP == 770);
FT = find(h.EVENT.TYP == 771);
TG = find(h.EVENT.TYP == 772);

% Translate indices to position in dataframe
start_trial_t = h.EVENT.POS(start_trial);
LH_t = h.EVENT.POS(LH);
RH_t = h.EVENT.POS(RH);
FT_t = h.EVENT.POS(FT);
TG_t = h.EVENT.POS(TG);

end

function [start_trial_tT, LH_tT, RH_tT, FT_tT, TG_tT] = epoch_test(h_test, test_label)

% Test Session
start_trial_T = find(h_test.EVENT.TYP == 768);
unknown_T = find(h_test.EVENT.TYP == 783);
LH_T = find(test_label.classlabel == 1);
RH_T = find(test_label.classlabel == 2);
FT_T = find(test_label.classlabel == 3);
TG_T = find(test_label.classlabel == 4);

% Translate indices to position in dataframe
start_trial_tT = h_test.EVENT.POS(start_trial_T);
unknown_tT = h_test.EVENT.POS(unknown_T);
LH_tT = h_test.EVENT.POS(LH_T);
RH_tT = h_test.EVENT.POS(RH_T);
FT_tT = h_test.EVENT.POS(FT_T);
TG_tT = h_test.EVENT.POS(TG_T);

end

function [LH, RH, FT, TG] = epoch(LH_t, RH_t, FT_t, TG_t, LH_ch, RH_ch, FT_ch, TG_ch, t_start, t_end, start_trial_t, s)

    for i = 1:length(LH_t)

        % Find the index immediately after said trial
        end_LH = min(find(start_trial_t > LH_t(i)));
        end_RH = min(find(start_trial_t > RH_t(i)));
        end_FT = min(find(start_trial_t > FT_t(i)));
        end_TG = min(find(start_trial_t > TG_t(i)));

        % For each trial, expand cell
        LH_ch{end+1} = s(LH_t(i)+t_start:LH_t(i)+t_end,:);
        RH_ch{end+1} = s(RH_t(i)+t_start:RH_t(i)+t_end,:);
        FT_ch{end+1} = s(FT_t(i)+t_start:FT_t(i)+t_end,:);
        TG_ch{end+1} = s(TG_t(i)+t_start:TG_t(i)+t_end,:);

    end
    
    LH = LH_ch;
    RH = RH_ch;
    FT = FT_ch;
    TG = TG_ch;
    
    LH(1) = [];
    RH(1) = [];
    FT(1) = [];
    TG(1) = [];
    
end

function [LH_p, RH_p, FT_p, TG_p] = psd(LH_ch, RH_ch, FT_ch, TG_ch, fs)

    for i = 1:length(LH_ch)

        x = LH_ch{i};
        [Pxx,F] = periodogram(x,[],length(x),fs);
        PSD = 10*log10(Pxx);
        LH_p{i,1} = PSD;
        LH_p{i,2} = F;

        x = RH_ch{i};
        [Pxx,F] = periodogram(x,[],length(x),fs);
        PSD = 10*log10(Pxx);
        RH_p{i,1} = PSD;
        RH_p{i,2} = F;

        x = FT_ch{i};
        [Pxx,F] = periodogram(x,[],length(x),fs);
        PSD = 10*log10(Pxx);
        FT_p{i,1} = PSD;
        FT_p{i,2} = F;

        x = TG_ch{i};
        [Pxx,F] = periodogram(x,[],length(x),fs);
        PSD = 10*log10(Pxx);
        TG_p{i,1} = PSD;
        TG_p{i,2} = F;

    end
    
end

function [LH_bp, RH_bp, FT_bp, TG_bp] = bandpass(LH_p, RH_p, FT_p, TG_p, ind8, ind30, ch1, ch2, ch3)

LH_bp = LH_p;
RH_bp = RH_p;
FT_bp = FT_p;
TG_bp = TG_p;

for i = 1:length(LH_p)
    
    % Concatenate into a 1 x 135 matrix
    LH_bp{i,1} = reshape(LH_p{i,1}(ind8:ind30,[8,10,12]),1,[]);
    RH_bp{i,1} = reshape(RH_p{i,1}(ind8:ind30,[8,10,12]),1,[]);
    FT_bp{i,1} = reshape(FT_p{i,1}(ind8:ind30,[8,10,12]),1,[]);
    TG_bp{i,1} = reshape(TG_p{i,1}(ind8:ind30,[8,10,12]),1,[]);
    
    LH_bp{i,2} = LH_p{i,2}(ind8:ind30);
    RH_bp{i,2} = RH_p{i,2}(ind8:ind30);
    FT_bp{i,2} = FT_p{i,2}(ind8:ind30);
    TG_bp{i,2} = TG_p{i,2}(ind8:ind30);

end
    
end