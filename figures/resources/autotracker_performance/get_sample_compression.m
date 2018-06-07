
fDir = autoDir;

% get video file
vidPaths = getHiddenMatDir(fDir,'ext','.m4v');
vidPaths = [vidPaths getHiddenMatDir(fDir,'ext','.mp4')];
fPaths = getHiddenMatDir(fDir,'ext','.mat');

%%
buf = 3;
roi = 31;
nFr = 100;
bitrate = [11, 175, 22, 350, 44, 87, 700];


for i = 1:length(vidPaths)
    
    vid = VideoReader(vidPaths{i});
    sprintf('%i \t out of \t %i',i,length(vidPaths)) 
    
    
    if i==1
        load(fPaths{i},'expmt');
        c=expmt.ROI.corners(roi,:);
        c(1) = c(1) + 60;
        c(2) = c(2) + 20;
        c(4) = c(4) - 41;
        c([1 2]) = round(c([1 2]) - buf);
        c([3 4]) = round(c([3 4]) + buf);
        ref = uint8(zeros(numel(c(2):c(4)),numel(c(1):c(3)),...
                length(fPaths)));
    end
    
    fr = read(vid,nFr);
    ref(:,:,i) = fr(c(2):c(4),c(1):c(3),2);
    delete(vid);
end

[v,p] = sort(bitrate);

figure;
for i = 1:size(ref,3)
    
    subplot(3,3,i);
    imshow(ref(:,:,i));
    title(v(i));
    
end