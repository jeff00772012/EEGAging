%% extract GFP peak
clear all; close all; clc;

%%  Parameters to change 
% which task to analyze
task = 'CM';
% path of the data
path = '\\Sv-09-025\d\Simona\2_EEGAging\1.Data\CM';

% Specify the population 
Group = {'Young','Old'};

for iGroup = 1:size(Group,1)
    % Group directory with the data
    GroupDir = strcat(fullfile(path,char(Group{iGroup})));
    
    % Subject folders, taking into account only prepocess mat file (not txt, not error.mat)
    SubjFolders = dir(fullfile(GroupDir,'*preprocessCMStim.mat'));
    
    % The pool of subjects 
    Subject_pool = {SubjFolders.name}';
    
    for iSubject = 1:size(Subject_pool,1)
        ID(iGroup, iSubject) = extractBefore(Subject_pool(iSubject), "_preprocessCMStim.mat");
        
        % Subject directory
        SubjDir = strcat(GroupDir,'\',char(Subject_pool{iSubject}));
        load(SubjDir);

        %------------------------------------------------------------------------------------
        % toDo EEG: (i) Average trials for each patient, then compute the
        % GFP over all electrodes -> So for each patient I get the GFP over
        % the time frame (TF). (ii) Make matrix with x-axis = TF and y-axis
        % = patient with corresponding GFP values.
        %NB: Time = [-0.1:1/Fs:0.4-1/Fs] Fs = 512 Hz, 100ms = baseline (I have 50 TF before stimulus onset and 205 timeframes afterwards!
        
        % get conditions
        if strcmp(task,'CM')
            Conditions = {EEG_five; EEG_fifteen; EEG_twentyfive; EEG_fifty};
            latencies = [216:257];
        elseif strcmp(task,'VBM')
            Conditions = {EEG_vernier; EEG_l_soa; EEG_s_soa;EEG_mask};
            latencies = [206:300];
        else
            Conditions = {EEG_noprecount};
            latencies = [260:334];
        end
        
        GFPCond = zeros(size(Conditions,1), length(EEG_five.times));
        
        for iCond = 1:size(Conditions,1)
            Data = Conditions{iCond}.data;
            
            % calculate GFP over time frame for the subject
            TrialsAverage = mean(Data,3);
            GFPCond(iCond,:) = std(TrialsAverage,1);
            GFPpeak(iSubject,iCond) = max(GFPCond(iCond, latencies));
        end

    end
    
end






