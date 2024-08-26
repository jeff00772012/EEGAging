%% PCA errors (PCE)
% analysis from Gibson et al. (2022).
% calculating the cosine distance between EEG time series
% final results save in all_data

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

all_data=[];

% loop througth the two age groups
for g = 1:length(group)
    
    % get data names
    d=dir([path,task,'\',group{g},'\*.mat']);
    temp_all=[];
    
    % loop through three sets of electrodes
    for idx = 1:length(ERP_all)
        ERP = ERP_all{idx};
        
        % for identifying the electrodes and time windows
        if strcmp(ERP,'N1')
            chan=[25,62];
            win = 207:307;
        elseif strcmp(ERP,'P3b')
            chan = [19,20,31,32,48,56,57];
            win = 307:512;
        elseif strcmp(ERP,'N2')
            chan = [4,10,12,13,19,32,38,39,45,47,48,49,50,56];
            win = 256:359;
        end
        
        % loop through subjects
        for sub = 1:length(d)
            
            % load data
            indi_data = load([d(sub).folder,'\',d(sub).name]);
            
            % loop through experimental conditions
            for idx_cond = 1:length(conditions)
                
                temp_data = indi_data.(conditions{idx_cond});
                % average the channels
                data = squeeze(mean(temp_data.data(chan,win,:)));
                
                % we don't deal with behavior data in this analysis
                %             behavior = behavioral_data;
                %             all_beha = [];
                %             if strcmp(task2,'VBM')
                %                 for b = 1:length(behavior)
                %                     all_beha = [all_beha;[behavior(b).hits,behavior(b).context_no]];
                %                 end
                %                 context = [4,1,2,3];
                %                 [C,ia,ib] = intersect(find(all_beha(:,1) == 1),find(all_beha(:,2) == context(kk)));
                %                 data = data(:,ib);
                %             elseif strcmp(task2,'CM')
                %                 for b = 1:length(behavior)
                %                     all_beha = [all_beha;[behavior(b).hits,behavior(b).level]];
                %                 end
                %                 context = [5,15,25,50];
                %                 [C,ia,ib] = intersect(find(all_beha(:,1) == 1),find(all_beha(:,2) == context(kk)));
                %                 data = data(:,ib);
                %             end
                
                count = 1;
                cosDis=[];
                
                % calcuate the cosine distance of each pairs of trials
                for ii = 1:size(data,2)
                    for jj = 1:size(data,2)
                        
                        % for not repeated calculate
                        if ii < jj 
                            cosDis(count) = pdist2(data(:,ii)',data(:,jj)','cosine');
                            count = count + 1;
                        end
                        
                    end
                end
                
                % get mean, standard deviation, and skewness of the
                % distribution of the cosine distance
                m_cosDis(sub,idx_cond) = mean(cosDis);
                s_cosDis(sub,idx_cond) = std(cosDis);
                sk_cosDis(sub,idx_cond) = skewness(cosDis);
            end
            sub
        end
        % save data for each of the channel sets
        temp_all = [temp_all,m_cosDis];
        m_cosDis = [];
    end
    % 1-4 columns: N1, 5-8 columns: N2, 9-12 columns: P3b
    all_data = [all_data;temp_all];
end