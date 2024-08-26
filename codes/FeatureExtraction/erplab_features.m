%% Analysis with electrode-pooling
% final results save in ResultsMatrix_final
clc;
clear;
close all;

%%  Parameters to change 
% specify which task and ERP to analysis
% experimental condition
task = 'CM';
% ERP to extract
ERP = 'P3b';
%%
% subject groups
group = {'Young','Old'};

% specify experimental conditions
if strcmp(task,'CM')
    conditions = {'EEG_five','EEG_fifteen','EEG_twentyfive','EEG_fifty'};
elseif strcmp(task,'VBM')
    conditions = {'EEG_vernier','EEG_l_soa','EEG_s_soa','EEG_mask'};
else
    conditions = {'EEG_noprecount'};
end

ResultsMatrix_final =[];
for g = 1:length(group)
    %% get data directories
    DataDir         = ['E:\project\EEG_aging\erplabanalysis\',task,'\',group{g}];
    Participants    = dir(fullfile(DataDir, '*.mat*'));
    CurrDir         = cd();
    
    %% open eeglab
    cd(CurrDir)
    
    %% set analysis
    % read cap
    load('channels_locations.mat')
    %% electrodes for analysis
    % pool_l: channel name
    % pool_l_ix: channel num
    % time_ori: time window for extracting ERPs (in ms)
    if strcmp(ERP,'N1')
        % N1
        pool_1 = {'PO7', 'PO8'};
        pool_1_ix = [25, 62];
        time_oi = [100, 300];
    elseif strcmp(ERP,'P3b')
        % P3b
        pool_1 = {'CP1', 'P1', 'Pz', 'CPz', 'Cz', 'CP2', 'P2'};
        pool_1_ix = [19,20,31,32,48,56,57];
        time_oi = [300, 697];
    elseif strcmp(ERP,'N2')
        % N2
        pool_1 = {'F1','FC3','C1','C3','CP1','CPz','Fz','F2','FC4','FCz','Cz','C2','C4','CP2'};
        pool_1_ix = [4,10,12,13,19,32,38,39,45,47,48,49,50,56];
        time_oi = [200, 400];
    end
    
    %% obtained from geterpvalues.m from erplab toolbox
    % where to find peak and latency values
    
    % polpeak    - peak polarity,   1=positive (default), 0=negative
    % sampeak    - number of points in the peak's neighborhood (one-side) (0 default)
    % localoptsrt - writes a NaN when local peak is not found
    % P3b is positive, N1 and N2 are negative
    if strcmp(ERP,'P3b')
        polpeak = 1;
    else
        polpeak = 0;
    end
    sampeak = 0;
    localoptstr = 'NaN';
    
    %% loop starts
    ResultsMatrix = zeros(length(Participants) * length(conditions), 7);
    ii = 1;
    % looping all the participants
    for i = 1:length(Participants)
        
        id_ = Participants(i).name;
        all_data = load(fullfile(DataDir, id_));
        store_2=[];
        store_3=[];
        
        % we don't deal with behavior data in this analysis
        %         behavior = all_data.behavioral_data;
        %         all_beha = [];
        %         if strcmp(task,'VBM')
        %             for b = 1:length(behavior)
        %                 all_beha = [all_beha;[behavior(b).hits,behavior(b).context_no]];
        %             end
        %             % context = [4,1,2,3];
        %             context = [4,1,2,3];
        %
        %         else
        %             for b = 1:length(behavior)
        %                 all_beha = [all_beha;[behavior(b).hits,behavior(b).level]];
        %             end
        %             %context = [5,15,25,50];
        %             context = [25];
        %
        %         end
        for j = 1:length(conditions)
            % get mean of pool of electrodes
            eeg = all_data.(conditions{j});
            
            % we don't need this part
            % [C,ia,ib] = intersect(find(all_beha(:,1) == 1),find(all_beha(:,2) == context(j)));
            % eeg.data = eeg.data(:,:,ib);
            
            times = eeg.times;
            % time interval where to look for the peaks
            index_1 = find(times >= time_oi(1), 1, 'first');
            index_2 = find(times >= time_oi(2), 1, 'first');
            sampllat = [index_1, index_2];
            data_ = squeeze(mean(eeg.data(pool_1_ix, :, :), 1));
            data_ = mean(data_, 2)';
            % remove baseline
            blv    = blvalue2(data_, times, [-300 0]);
            dataux = data_ - blv;
            
            %         'meanbl'           - calculates the relative-to-baseline mean amplitude value between two latencies.
            %         'peakampbl'        - finds the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
            %         'peaklatbl'        - finds latency of the relative-to-baseline peak value between two latencies. See polpeak and sampeak.
            %         'area' or 'areat'  - calculates the (total) area under the curve, between two latencies.
            %         'arean'            - calculates the area under the negative values of the curve, between two latencies.
            
            mean_amplitude = mean(dataux(sampllat(1):sampllat(2)));
            
            negative_area  =  areaerp(dataux, eeg.srate, sampllat, 'negative', 0);
            total_area  =  areaerp(dataux, eeg.srate, sampllat, 'total', 0);
            
            dataux  = dataux(sampllat(1)-sampeak:sampllat(2)+sampeak);  % no filtered
            timex2  = times(sampllat(1)-sampeak:sampllat(2)+sampeak);
            
            % get peak from the function in erplab
            [peak_amplitude, peak_latency] = localpeak(dataux, timex2, 'Neighborhood',sampeak, 'Peakpolarity', polpeak, 'Measure','amplitude',...
                'Peakreplace', localoptstr);
            % store values
            store_ = [NaN, j, mean_amplitude, negative_area, total_area, peak_amplitude, peak_latency];
            ResultsMatrix(ii, :) = store_;
            
            % need only peak_amplitue and peak_latency
            store_2 = [ store_2, peak_amplitude];
            store_3 = [ store_3, peak_latency];
            
            ii = ii + 1;
            disp(ii)
        end
        % save data for each group
        ResultsMatrix2(i,:) = [store_2,store_3];
    end
    % combine young and old data
    % 1-4 columns: peak ERP values, 5-8 columns: peak latency
    ResultsMatrix_final=[ResultsMatrix_final;ResultsMatrix2];
end






