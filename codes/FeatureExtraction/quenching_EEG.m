%% Quenching
% analysis from Arazi et al. (2017).
% calculating the variance before and after stimulus presentation
% final results save in all_quenching

clear all
%%  Parameters to change 
% which task to analyze
task = 'CM';
% path of the data
path = 'E:\project\EEG_aging\erplabanalysis\';

% get conditions
if strcmp(task,'CM')
    conditions = {'EEG_five','EEG_fifteen','EEG_twentyfive','EEG_fifty'};
elseif strcmp(task,'VBM')
    conditions = {'EEG_vernier','EEG_l_soa','EEG_s_soa','EEG_mask'};
else
    conditions = {'EEG_noprecount'};
end

% Specify the population and the 
% the ERP_all is to separate different channels and time windows
group = {'Young','Old'};
ERP_all={'N1','N2','P3b'};

all_quenching=[];

% loop througth the two age groups
for g = 1:length(group)
    
    % get data names
    d=dir([path,task,'\',group{g},'\*.mat']);
    temp_all = [];
    
    %%
    
    % loop through three sets of electrodes
    for idx = 1:length(ERP_all)
        ERP = ERP_all{idx};
        
        % the time window before stimulus presentation (-300 to 0 ms)
        pre = 1:155;
        
        % for identifying the electrodes and time windows
        % post: time wondow after stimulus presentation
        if strcmp(ERP,'N1')
            chan=[25,62];
            post = 207:307;
        elseif strcmp(ERP,'P3b')
            chan = [19,20,31,32,48,56,57];
            post = 307:512;
        elseif strcmp(ERP,'N2')
            chan = [4,10,12,13,19,32,38,39,45,47,48,49,50,56];
            post = 256:359;
        end
        
        % loop through subjects
        for sub = 1:length(d)
            
            % load data
            all_data = load([d(sub).folder,'\',d(sub).name]);
            
            % loop through experimental conditions
            for idx_cond = 1:length(conditions)
                
                % average the channels 
                data = squeeze(mean(all_data.(conditions{idx_cond}).data(chan,:,:)));
                
                % we don't deal with behavior data in this analysis
                %             behavior = behavioral_data;
                %             all_beha = [];
                %             if strcmp(task2,'VBM')
                %                 for b = 1:length(behavior)
                %                     all_beha = [all_beha;[behavior(b).hits,behavior(b).context_no]];
                %                 end
                %                 context = [4,1,2,3];
                %                 [C,ia,ib] = intersect(find(all_beha(:,1) == 1),find(all_beha(:,2) == context(jj)));
                %                 data = data(:,ib);
                %             elseif strcmp(task2,'CM')
                %                 for b = 1:length(behavior)
                %                     all_beha = [all_beha;[behavior(b).hits,behavior(b).level]];
                %                 end
                %                 context = [5,15,25,50];
                %                 [C,ia,ib] = intersect(find(all_beha(:,1) == 1),find(all_beha(:,2) == context(jj)));
                %                 data = data(:,ib);
                %             end
                
                var_pre=[];
                var_post=[];
                
                %%  Calcuate the mean variance before stimulus presentation
                for ii = 1:length(pre)
                    var_pre(ii) = var(data(ii,:));
                end
                m_var_pre=mean(var_pre);
                
                %%  Calcuate the mean variance after stimulus presentation
                for ii = 1:length(post)
                    var_post(ii) = var(data(post(ii),:));
                end
                m_var_post = mean(var_post);
                %% The difference between the variance of pre and post stimulus presentation - Quenching
                diff_var(sub,idx_cond) = m_var_pre-m_var_post;
                
                % save the variance of pre and post stimulus presentation
                % pre_quenching(sub,idx_cond) = [m_var_pre];
                % post_quenching(sub,idx_cond) = [m_var_post];
                
                
            end
            sub
        end
        % save data for each of the channel sets
        temp_all = [temp_all,diff_var];
        diff_var = [];
        
    end
    % 1-4 columns: N1, 5-8 columns: N2, 9-12 columns: P3b
    all_quenching=[all_quenching;temp_all];
end


