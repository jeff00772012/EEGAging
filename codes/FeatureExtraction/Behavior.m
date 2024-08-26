%% extract behavior
clear all; close all; clc;

%%  Parameters to change 
% which task to analyze
task = 'RT';
% path of the data
path = '\\Sv-09-025\d\Simona\2_EEGAging\1.Data\RT';

% Specify the population 
Group = {'Young','Old'};

for iGroup = 1:size(Group,1)
    % Group directory with the data
    GroupDir = strcat(fullfile(path,char(Group{iGroup})));
    
    % Subject folders, taking into account only prepocess mat file (not txt, not error.mat)
    SubjFolders = dir(fullfile(GroupDir,'*preprocessRTStim.mat'));
    
    % The pool of subjects 
    Subject_pool = {SubjFolders.name}';
    
    for iSubject = 1:size(Subject_pool,1)
        ID(iGroup, iSubject) = extractBefore(Subject_pool(iSubject), "_preprocessRTStim.mat");
        
        % Subject directory
        SubjDir = strcat(GroupDir,'\',char(Subject_pool{iSubject}));
        load(SubjDir);
        
        % get conditions
        if strcmp(task,'CM')
            Conditions = {EEG_five; EEG_fifteen; EEG_twentyfive; EEG_fifty};
            conditions_v = [5,15,25,50];
        elseif strcmp(task,'VBM')
            Conditions = {EEG_vernier; EEG_l_soa; EEG_s_soa;EEG_mask};
        else
            Conditions = {EEG_noprecount};
        end
        n_runs = length(behavioral_data);
       
        
        %------------------------------------------------------------------------------------
        % toDo behavioral: (i) Look at performace of patient: average hits
        % (for valid trials!) over condition over the blocks.
        
        Hits = zeros(1,length(Conditions));

        %%
        for iRun = 1:n_runs
            if strcmp(task,'CM') || strcmp(task,'VBM')
                for iTrial = 1:length(behavioral_data(iRun).hits)
                    if behavioral_data(iRun).hits(iTrial) == 1
                        if behavioral_data(iRun).level(iTrial) == conditions_v(1)
                            Hits(1,1) = Hits(1,1) + 1;
                        elseif behavioral_data(iRun).level(iTrial) == conditions_v(2)
                            Hits(1,2) = Hits(1,2) + 1;
                        elseif behavioral_data(iRun).level(iTrial) == conditions_v(3)
                            Hits(1,3) = Hits(1,3) + 1;
                        elseif behavioral_data(iRun).level(iTrial) == conditions_v(4)
                            Hits(1,4) = Hits(1,4) + 1;
                        end
                    end
                end
                
                for idx = 1:length(Conditions)
                    Trials_num(1,idx) = sum(behavioral_data(iRun).level == conditions_v(idx));
                    perf_(iRun,idx) = Hits(1,idx) / Trials_num(1,idx);
                end
                
                Hits = zeros(1,length(Conditions));
            else
                for iTrial = 1:length(behavioral_data(iRun).valid)
                    RT_RT(iTrial) = behavioral_data(iRun).react_ti(iTrial);
                end
                perf_(iRun) = nanmean(RT_RT);
                RT_RT = [];
            end
            
        end
        
        performance_all(iGroup, iSubject,:) = mean(perf_);
        
    end
end





