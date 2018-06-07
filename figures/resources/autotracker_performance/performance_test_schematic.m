

% get video file
fPath = getHiddenMatDir(fDir,'ext','.mp4');
vid = VideoReader(fPath{1});

%

buf = 3;
roi = 23;
nFr = 100;

c=expmt.ROI.corners(roi,:);
c([1 2]) = round(c([1 2]) - buf);
c([3 4]) = round(c([3 4]) + buf);
ref = expmt.ref.im(c(2):c(4),c(1):c(3));
fr = read(vid,nFr);
fr = fr(:,:,2);
raw = fr(c(2):c(4),c(1):c(3));
imshow(raw);
thresh1 = (ref - raw)>expmt.parameters.track_thresh;
thresh2 = thresh1 | rand(size(thresh1)) < .065;
thresh3 = thresh1 | rand(size(thresh1)) < 0.13;
thresh4 = thresh1 | rand(size(thresh1)) < 0.2;
subplot(2,2,1);
imshow(thresh1);
cen = squeeze(expmt.Centroid.map.Data.raw(roi,:,nFr));
hold on; mh = scatter(cen(1)-c(1)+1, cen(2)-c(2)+1,'r','LineWidth',2);hold off;
mh.SizeData = 100;
subplot(2,2,2); imshow(thresh2);
hold on; mh = scatter(cen(1)-c(1)+1, cen(2)-c(2)+1,'r','LineWidth',2);hold off;
mh.SizeData = 100;
subplot(2,2,3); imshow(thresh3);
hold on; mh = scatter(cen(1)-c(1)+1, cen(2)-c(2)+1,'r','LineWidth',2);hold off;
mh.SizeData = 100;
subplot(2,2,4); imshow(thresh4);
hold on; mh = scatter(cen(1)-c(1)+1, cen(2)-c(2)+1,'r','LineWidth',2);hold off;
mh.SizeData = 100;

%%

c=expmt.ROI.corners(roi,:);
c([1 2]) = round(c([1 2]) - buf);
c([3 4]) = round(c([3 4]) + buf);
mag = 2;
randang = pi/4;
shift = [cos(randang) sin(randang)].*mag;
ref2 = imtranslate(expmt.ref.im,shift,'linear','FillValues',0);
ref1 = expmt.ref.im(c(2):c(4),c(1):c(3));
ref2 = ref2(c(2):c(4),c(1):c(3));
fr = read(vid,nFr);
fr = fr(:,:,2);
raw = fr(c(2):c(4),c(1):c(3));
thresh1 = (ref1 - raw)>expmt.parameters.track_thresh;
thresh2 = (ref2 - raw)>expmt.parameters.track_thresh;
subplot(2,2,1);
imshow(ref1);
cen = squeeze(expmt.Centroid.map.Data.raw(roi,:,nFr));
subplot(2,2,2); imshow(ref2);
subplot(2,2,3); imshow(thresh1);
subplot(2,2,4); imshow(thresh2);
