clear
close all
load('MY\DIR\uniqueDefectMap.mat')
uniqueDefectMap.LDOS_1def=LDOS_1def(:,:,1);
uniqueDefectMap.def_centers=def_centers(1,:);

%% example with single image
exampleIdx = 1;
exampleImg = uniqueDefectMap.LDOS_1def(:,:,exampleIdx);
figure
imshow(exampleImg)
hold on

exampleDef_center = uniqueDefectMap.def_centers(exampleIdx,:);
exampleDef_center(1,1) = exampleDef_center(1,1) + 63; %change x,y coordiates to work with image indexing, where (0,0) is at upper left corner
exampleDef_center(1,2) = exampleDef_center(1,2) + 63;
scatter(exampleDef_center(1,1), exampleDef_center(1,2));

CPos = [44 43; 44 56; 44 69; 44 82; 55 37; 55 50; 55 75; 66 43; 66 56; 66 69; 66 82; 77 37; 77 50; 77 63; 77 75];%; 55 63
scatter(CPos(:,1), CPos(:,2))
hold off
truesize([400 400]);

% image translation
tform = randomAffine2d('XTranslation',[-17 7], 'YTranslation',[-15 15]); %random translation withing specified ranges

outputView = affineOutputView([122 122],tform);
imAugmented1 = imwarp(exampleImg,tform,'OutputView',outputView);  %translate image
imAugmented1 = imAugmented1(31:91, 31:91); %crop to center box
imAugmented1 = imresize(imAugmented1, [244 244]); %magnify

%translate defect center
exampleDef_center = [exampleDef_center 1] * tform.T; 
exampleDef_center(1,1) = (exampleDef_center(1, 1) - 30) * 4; %crop and magnifiy
exampleDef_center(1,2) = (exampleDef_center(1, 2) - 30) * 4;

%translate C atoms
for i=1:length(CPos)
    C_trans = [CPos(i,:) 1] * tform.T;
    CPos(i,:) = C_trans(:, 1:2);
    CPos(i,1) = (CPos(i, 1) - 30) * 4; 
    CPos(i,2) = (CPos(i, 2) - 30) * 4;
end

figure
imshow(imAugmented1); hold on;
scatter(exampleDef_center(1,1), exampleDef_center(1,2)); hold on;
scatter(CPos(:,1), CPos(:,2)); hold off
truesize([400 400]);

%% augment entire dataset
%goes through every image in original dataset, randomly translates it x
%times, and saves original and new LDOS, with corresponding defect centers
%in aug_dataset. X specified by augmentation_factor

CPos_orig = [44 43; 44 56; 44 69; 44 82; 55 37; 55 50; 55 75; 66 43; 66 56; 66 69; 66 82; 77 37; 77 50; 77 63; 77 75];%; 55 63
CPos_orig_crop = (CPos_orig - 30) * 4;

size_orig_dataset = length(uniqueDefectMap.LDOS_1def(1,1,:));
augmentation_factor = 3000; % for each image in the original dataset, do x random translations
augmented_imgs = zeros(244, 244, size_orig_dataset * (augmentation_factor + 1));
augmented_Def_centers = zeros(size_orig_dataset * (augmentation_factor + 1), 2);
augmented_CPos = zeros(15, 2, size_orig_dataset * (augmentation_factor + 1));

for i = 1:size_orig_dataset %iterate over every image in orginal dataset
    orig_Img = uniqueDefectMap.LDOS_1def(:,:,i);
    origDef_center = uniqueDefectMap.def_centers(i,:);
    origDef_center(1,1) = origDef_center(1,1) + 61;
    origDef_center(1,2) = origDef_center(1,2) + 61;
    

    %crop and magnify original image, to store in final dataset
    orig_Img_crop = orig_Img(31:91, 31:91); %crop to center box
    orig_Img_crop = imresize(orig_Img_crop, [244 244]); %magnify
    origDef_center_crop(1,1) = (origDef_center(1, 1) - 30) * 4; 
    origDef_center_crop(1,2) = (origDef_center(1, 2) - 30) * 4; 
    augmented_imgs(:, :, (i-1)*(augmentation_factor+1)+1) = orig_Img_crop;
    augmented_Def_centers((i-1)*(augmentation_factor+1)+1, :) = origDef_center_crop;
    augmented_CPos(:,:,(i-1)*(augmentation_factor+1)+1) = CPos_orig_crop;
    
%     figure
%     imshow(orig_Img_crop);hold on
%     scatter(origDef_center_crop(1,1), origDef_center_crop(1,2)); hold on
%     scatter(CPos_orig_crop(:,1), CPos_orig_crop(:,2)); hold off;
%     truesize([400 400]);
    
    
    for j = 1:augmentation_factor
        % image translation
        tform = randomAffine2d('XTranslation',[-17 7], 'YTranslation',[-15 15]); 
        outputView = affineOutputView([122 122],tform);
        imAugmented = imwarp(orig_Img,tform,'OutputView',outputView);  
        imAugmented = imAugmented(31:91, 31:91); 
        imAugmented = imresize(imAugmented, [244 244]);

        %translate defect center
        aug_Def_center = [origDef_center 1] * tform.T;
        aug_Def_center(1,1) = (aug_Def_center(1, 1) - 30) * 4;
        aug_Def_center(1,2) = (aug_Def_center(1, 2) - 30) * 4;
        
        %translate C atoms
        for k=1:length(CPos_orig)
            C_trans = [CPos_orig(k,:) 1] * tform.T;
            aug_CPos(k,:) = C_trans(:, 1:2);
        end
        aug_CPos = (aug_CPos - 30) * 4;
        
        augmented_imgs(:, :, (i-1)*(augmentation_factor+1)+1+j) = imAugmented;
        augmented_Def_centers((i-1)*(augmentation_factor+1)+1+j, :) = aug_Def_center(1, 1:2);
        augmented_CPos(:,:, (i-1)*(augmentation_factor+1)+1+j) = aug_CPos;
        
%         figure
%         imshow(imAugmented); hold on
%         scatter(aug_Def_center(1,1), aug_Def_center(1,2), 'r*'); hold on
%         scatter(aug_CPos(:, 1), aug_CPos(:,2)); hold off
%         truesize([400 400]);
    end
    
end
% 
% for i = 1:size(augmented_imgs(1,1,:))
%     figure
%     imshow(augmented_imgs(:,:,i));
%     hold on
%     scatter(augmented_Def_centers(i,1), augmented_Def_centers(i,2));
%     hold off
%     truesize([400 400]);
% end

aug_dataset.LDOS1def = augmented_imgs;
aug_dataset.def_centers = augmented_Def_centers;
aug_dataset.CPos =  augmented_CPos;
save('MY\DIR\aug_dataset.mat','aug_dataset')