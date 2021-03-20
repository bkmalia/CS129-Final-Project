clear
close all
%% Defect Test
dir = 'MY\DIR\';
load([dir,'aug_dataset.mat']);
LDOS_1def = aug_dataset.LDOS1def;
clear aug_dataset

trainSize=900;
maxLDOS = max(LDOS_1def,[],'all');
for i = 1:trainSize
    LDOS_1defi = uint8(LDOS_1def(:,:,i)*255/maxLDOS);
    inputImgs1 = reshape(LDOS_1defi,size(LDOS_1defi,1),size(LDOS_1defi,2),1,size(LDOS_1defi,3));
    for k=1:3
        inputImgs(:,:,k,:) = inputImgs1;
    end 
   filedirTrain = [dir,'trainImgs\'];
   filename = 'defectImg_';
   fullfile = [filedirTrain,filename,num2str(i),'.png'];
   imwrite(inputImgs(:,:,:,:),fullfile)
end
valSize = 99;
for i = (trainSize+1):(trainSize+valSize)
LDOS_1defi = uint8(LDOS_1def(:,:,i)*255/maxLDOS);
    inputImgs1 = reshape(LDOS_1defi,size(LDOS_1defi,1),size(LDOS_1defi,2),1,size(LDOS_1defi,3));
    for k=1:3
        inputImgs(:,:,k,:) = inputImgs1;
    end 
   filedirVal = [dir,'valImgs\'];
   filename = 'defectImg_';
   fullfile = [filedirVal,filename,num2str(i),'.png'];
   imwrite(inputImgs(:,:,:,:),fullfile)
end
trainDatastore = imageDatastore(filedirTrain);
valDatastore = imageDatastore(filedirVal);
save([dir,'datastores.mat'],'trainDatastore','valDatastore')