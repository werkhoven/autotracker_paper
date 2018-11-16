%%

fDir = autoDir;
fPaths = recursiveSearch(fDir, 'keyword', 'Optomotor', 'ext', '.mat');

%%
[mu,data,f]=bootstrap_optomotor(expmt,100,'Optomotor');

%%

win_szs = NaN(length(fPaths),1);
traces = cell(length(fPaths),1);
r_traces = cell(length(fPaths),1);
t = cell(length(fPaths),1);
numTrials = cell(length(fPaths),1);
raw_withstimulus_delta_angle = cell(length(fPaths),1);
raw_total_delta_angle = cell(length(fPaths),1);

for i = 1:length(fPaths)
    
    disp(i);
    load(fPaths{i});
    
    % get radius
    r = cellfun(@(cen, center) ...
        sqrt(sum([(cen(:,1)-center(1)).^2 (cen(:,2)-center(2)).^2],2)),...
        squeeze(num2cell(expmt.Centroid.data,[1 2])), num2cell(expmt.ROI.centers,2),...
        'UniformOutput', false);
    r = cellfun(@(r) r./max(r), r, 'UniformOutput', false);
    r = cat(2,r{:});
    
    [da,~,nTrials,~,~, dr] = ...
        extractOptoTraces_legacy(expmt.StimStatus.data, expmt, r);

    %get activity filter
    a=~isnan(da);
    trialnum_thresh = 40;
    sampling =(squeeze(sum(sum(a(:,1:trialnum_thresh,:))))./(size(da,1)*size(da,2)));
    active = nTrials>trialnum_thresh & sampling > 0.01;
    optoplots=squeeze(nanmedian(da(:,:,active),2));
    rplots=squeeze(nanmedian(dr(:,:,active),2));
    win_szs(i) = expmt.parameters.stim_int;
    t{i} = linspace(-win_szs(i),win_szs(i),size(optoplots,1));
    traces{i} = optoplots;
    r_traces{i} = rplots;
    numTrials{i} = nTrials(active);
    raw_withstimulus_delta_angle{i} = expmt.Optomotor.sdist(:,active);
    raw_total_delta_angle{i} = expmt.Optomotor.tdist(:,active);
    
    clear optoplots expmt
    
end


%%

total_nTrials = sum(cellfun(@sum,numTrials));
total_nFlies = sum(cellfun(@numel,numTrials));

[npts, j] = max(cellfun(@numel, t));
tpts = t{j}(:);
da_interp = cellfun(@(tt, tr) interp1(tt(:), tr, tpts(:)),...
    t, traces, 'UniformOutput', false);
da_interp = -1*cat(2,da_interp{:}).*pi./180;
da_sem = SEM_calc(da_interp');
da_mu = nanmean(da_interp,2);
r_interp = cellfun(@(tt, tr) interp1(tt(:), tr, tpts(:)),...
    t, r_traces, 'UniformOutput', false);
r_interp = cat(2,r_interp{:});
r_sem = SEM_calc(r_interp');
r_mu = nanmean(r_interp,2);

%%




%% get raw data formatted for bootstrapping

all_withstim_delta = cell(total_nFlies,1);
all_total_delta = cell(total_nFlies,1);
ct=0;

for i=1:numel(raw_withstimulus_delta_angle)
    tmp1 = raw_withstimulus_delta_angle{i};
    tmp2 = raw_total_delta_angle{i};
    for j = 1:size(tmp1,2)
        ct = ct+1;
        all_withstim_delta{ct} = squeeze(tmp1(1:sum(~isnan(tmp1(:,j))),j));
        all_total_delta{ct} = squeeze(tmp2(1:sum(~isnan(tmp2(:,j))),j));
    end
end


%%



%%

% DELTA ANGLE PLOT
figure; hold on;

% plot raw data patch for delta angle
n = total_nFlies;
vy = [NaN(1,n); da_interp; NaN(1,n)];
vx = [NaN(1,n); repmat(tpts,1,n); NaN(1,n)];
patch('XData',vx,'YData',vy,'LineWidth',0.25,'FaceColor','none',...
    'edgecolor',[0.8 .2 0.8],'edgealpha',0.01);

% plot mean line
plot(tpts, da_mu,'Color',[.6 0.2 .6], 'LineStyle','--','LineWidth', 0.75);
% vy_da = [da_mu'-da_sem fliplr(da_mu'+da_sem)];
% vx = [tpts' fliplr(tpts')];
% da_ph = patch(vx,vy_da,'m','FaceAlpha',0.15,'EdgeColor','none');
% uistack(da_ph,'down');
ylabel('delta angle (rad)')
xlabel('time to stimulus (s)')
legend({'raw traces';'mean'},'Location','Northwest');
ah = gca;
ah.XLim = [-4 4];
ah.YLim = [-5 5];
ph=patch([0 0 2 2 0], ah.YLim([2 1 1 2 2]), [.9 .9 .9]);
uistack(ph, 'bottom');

% RADIUS PLOT
figure; hold on

% plot raw data patch for delta angle
n = total_nFlies;
vy = [NaN(1,n); r_interp; NaN(1,n)];
vx = [NaN(1,n); repmat(tpts,1,n); NaN(1,n)];
patch('XData',vx,'YData',vy,'LineWidth',0.25,'FaceColor','none',...
    'edgecolor',[0.2 .8 0.2],'edgealpha',0.02);

% vy_r = [r_mu'-r_sem fliplr(r_mu'+r_sem)];
plot(tpts, r_mu, 'Color',[0.2 0.6 0.2], 'LineWidth', 0.75,'LineStyle','--');
% r_ph = patch(vx,vy_r,'g','FaceAlpha',0.15,'EdgeColor','none');
% uistack(r_ph,'down');

set(gca,'YLim',[0 1], 'XLim', [-4 4]);
ylabel('normalized radial position')
xlabel('time to stimulus (s)')
legend({'raw traces', 'mean'},'Location','Northwest')
ah = gca;
ph=patch([0 0 2 2 0], ah.YLim([2 1 1 2 2]), [.9 .9 .9]);
uistack(ph, 'bottom');

