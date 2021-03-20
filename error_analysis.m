clear
close all

%% Load Data
baseDir = 'MY\DIR\';
detector = load([baseDir,'trainedDetectionNetwork.mat']);
network = detector.defcnn;

load([baseDir,'aug_dataset.mat']);
def_centers=aug_dataset.def_centers;

load([baseDir,'datastores.mat']);
%% Detected Locations
bbox = [];
detThreshold = linspace(0.2,0.3,7);
evaluation.IoUthreshold = 0.3;
minScore = [];
bbox_centers = zeros(1,4);
num_trainImgs = length(trainDatastore.Files);
error = [];
gTruthbboxSize = 64;
gTruthbbox = [def_centers-gTruthbboxSize/2,ones(size(def_centers))*gTruthbboxSize];

%900 train images, 99 train images
num_samples = 99;
Valoffset = 900;
for t = 1:length(detThreshold)
    overlapRatio = [];
    imgIdx = [];
    k = 1;
    for i = (1+Valoffset):(num_samples+Valoffset)
        testImg = imread([baseDir,'valImgs/defectImg_',num2str(i),'.png']);
        [bbox,score,label] = detect(network,testImg,'Threshold',detThreshold(t));
        detectedImgLabel = testImg;
        maxScore = [];
            [maxScore,maxScoreIdx] = max(score.*(label == categorical({'defect'})));
            if maxScore~=0 
                 overlapRatio(k) = bboxOverlapRatio(gTruthbbox(i,:),bbox(maxScoreIdx,:));
                imgIdx(k) = i;
                k = k+1;
            end
    end

    % Error Analysis
    evaluation.TP(t) = sum(overlapRatio>=evaluation.IoUthreshold);
    evaluation.FP(t) = sum((overlapRatio<evaluation.IoUthreshold));
    evaluation.FN(t) = num_samples-evaluation.TP(t);
end
    evaluation.detThreshold = detThreshold;
    evaluation.precision = evaluation.TP./(evaluation.TP+evaluation.FP);
    evaluation.recall = evaluation.TP./(evaluation.TP+evaluation.FN);
    evaluation.fscore = 2*evaluation.precision.*evaluation.recall./(evaluation.precision+evaluation.recall);

%% Plot Histogram
figure(1);
plot(evaluation.detThreshold*100,evaluation.precision*100,'r-')
hold on
plot(evaluation.detThreshold*100,evaluation.recall*100,'b-')
plot(evaluation.detThreshold*100,evaluation.fscore*100,'g-')
legend('precision','recall','f-score')
xlabel('Detection Threshold (%)')
ylabel('score (%)')

