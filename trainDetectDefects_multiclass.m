clear
close all
g = gpuDevice;
reset(g)
rng(333)
baseDir = 'MY\DIR\';
%% Prepare Bounding Boxes
load([baseDir,'aug_dataset.mat'])
def_centers=aug_dataset.def_centers;
CPos = aug_dataset.CPos;
imgSize =244;
magnify = 4;
shift = 2;
boxSize = 16*magnify;
defectBox = [floor(def_centers-boxSize/2+shift),zeros(size(def_centers))+boxSize+1];
defect = num2cell(defectBox,2);

gshift = 0;
gBoxSize = 16*magnify;
graphene = cell(size(defectBox,1),1);
for p = 1:size(graphene,1)
    CidxNew=1;
    grapheneBoxTemp = [];
    for Cidx = 1:size(CPos(:,:,p),1)
        grapheneBoxTempC = [floor(CPos(Cidx,:,p)-gBoxSize/2+gshift),zeros(size(CPos(Cidx,:,p)))+gBoxSize+1];
        if min(grapheneBoxTempC(1:2),[],'all')>=1 && max(grapheneBoxTempC(1:2)+grapheneBoxTempC(3),[],'all')<=imgSize
            grapheneBoxTemp(CidxNew,:) = grapheneBoxTempC;
            CidxNew=CidxNew+1;
        end
    end
graphene{p} = grapheneBoxTemp;
end

%% Prepare Datastores
load([baseDir,'datastores.mat'])
num_train = length(trainDatastore.Files);
num_val = length(valDatastore.Files);
trainLabelTable = table(graphene(1:num_train),defect(1:num_train),'VariableNames',{'graphene','defect'});
valLabelTable = table(graphene(num_train+1:num_train+num_val),defect(num_train+1:num_train+num_val),'VariableNames',{'graphene','defect'});
trainBlds = boxLabelDatastore(trainLabelTable);
valBlds = boxLabelDatastore(valLabelTable);
trainDs = combine(trainDatastore,trainBlds);
valDs = combine(valDatastore,valBlds);

%% Display Training Example
exampleIdx =1;
exampleImg = imread([baseDir,'\trainImgs\defectImg_',num2str(exampleIdx),'.png']);
imgSize = size(exampleImg,1);
labeledExampleImg = insertObjectAnnotation(exampleImg,'rectangle',defect{exampleIdx},'defect','Color','red');
labeledExampleImg = insertObjectAnnotation(labeledExampleImg,'rectangle',graphene{exampleIdx},'graphene','Color','blue');

figure(1)
montage({exampleImg,labeledExampleImg})
title('Training Set Example')
%% Create Network
inputImageSize = [size(exampleImg,1),size(exampleImg,2),3];
numClasses = 2;
numAnchors = 1;
[anchorBoxes,meanIoU] =  estimateAnchorBoxes(trainBlds,numAnchors);
net = vgg16();%resnet50;
featureLayer = 'relu5_3';%'activation_40_relu';
lgraph = fasterRCNNLayers(inputImageSize,numClasses,anchorBoxes,net,featureLayer);
%% Train Settings
tempdir =[baseDir,'checkpoints'];
options = trainingOptions('sgdm', ...
    'InitialLearnRate', 1e-3, ...
    'MiniBatchSize',3,...
    'MaxEpochs', 5, ...
    'CheckpointPath', tempdir,...
    'L2Regularization',1E-4,...
    'ValidationData',valDs);%
%% Train Network
[defcnn, info] = trainFasterRCNNObjectDetector(trainDs, lgraph , options,...%);%,...
   'NegativeOverlapRange',[0 0.15], ...
   'PositiveOverlapRange',[0.85 1],...
   'NumRegionsToSample',128*2);
save([baseDir,'trainedDetectionNetwork.mat'],'defcnn','info')
%% Continue Training
% data = load([baseDir,'checkpoints\CHECKPOINT.mat']);
% [defcnn_2, info_2] = trainFasterRCNNObjectDetector(trainDs,data.detector,options,...
%    'NegativeOverlapRange',[0 0.15], ...
%    'PositiveOverlapRange',[0.85 1],...
%    'NumRegionsToSample',128*2);
% save([baseDir,'trainedDetectionNetwork_cont.mat'],'defcnn_2','info_2')
%% Check Training Error
figure(4)
loss = [info.TrainingLoss];%,info_2.TrainingLoss]
valLossAll = [info.ValidationLoss(2:end)];%,info_2.ValidationLoss(2:end)
valLoss = valLossAll(~isnan(valLossAll));
valIter = 50:50:50*length(valLoss);
avgNum = 150;
semilogy(loss,'b')
hold on
semilogy(movmean(loss,avgNum),'r-')
semilogy(valIter,valLoss,'k-')
xlabel('Iteration')
ylabel('Loss')
legend('Mini-batch','Moving Average','Validation')

%% Check Validation Images
bbox = [];
pos = [];
posIdx = 1;
detThreshold = 0.27;
minScore = [];
for valIdx = 1:100
testImg = imread([baseDir,'valImgs\defectImg_',num2str(valIdx),'.png']);
[bbox,score,label] = detect(defcnn,testImg,'Threshold',detThreshold);
if sum(ismember(label,'defect'))>0
    pos(posIdx) = valIdx;
    minScore(posIdx) = min(score);
    posIdx = posIdx +1;
end
valIdx=valIdx+1;

detectedImgLabel = testImg;
for b = 1:size(bbox,1)
    labelStr = cellstr(label(b));
    scoreStr = num2str(score(b),'%.3f');
    
    if label(b) == categorical({'graphene'})
%        detectedImgLabel = insertObjectAnnotation(detectedImgLabel,'rectangle',bbox(b,:),[labelStr{1},'=',scoreStr],'Color','blue');
    else
        detectedImgLabel = insertObjectAnnotation(detectedImgLabel,'rectangle',bbox(b,:),[labelStr{1},'=',scoreStr],'Color','red');
    end
end

figure(3)
imshow(detectedImgLabel)
title('Test Set Example')

end
