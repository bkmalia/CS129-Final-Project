Files:
[Files over 25MB are stored at https://drive.google.com/drive/folders/1sVfv_28pgS1f-Ud7ZeTtPK3fGEFCxFaG?usp=sharing]
uniqueDefectMap.mat: Contains a 122x122x32 array of 32 grayscale images containing each unique relative position of a single defect and a 32x2 array containing locations of those defects for each image
aug_dataset.mat: Contains a 244x244x1001 array of 1001 grayscale images, a 1001x2 arrray of defect locations for each image, and a 15x2x1001 array of 15 graphene locations for each image.
trainedDetectionNetwork.mat: Contains the trained network object with weights for the adapted vgg16 network and also a structure containing the loss information for each iteration.
evaluation.mat: Contains a structure holding all evaluation metrics and data required to generate figure 5 in the report
datastores.mat: (will be created by generate_PNG.m based on your directories)

Scripts:
aug_dataset.m: Takes uniqueDefectMap and generates the augmented (shifted and cropped) data aug_dataset.mat
generate_PNG.m: Takes aug_dataset.mat and creates individual .png images for each member of the set. Also generates datastores.mat which contain pointers to those images.
trainDetectDefects_multiclass.m: Makes the bounding boxes from the data in aug_dataset, prepares the data using information from datastores.mat, and then Trains the Faster R-CNN detector and saves trainedDetectionNetwork.mat.
error_analysis.m: Uses trainedDetectionNetwork.mat to calculate analysis metrics from the validation data set. Metrics saved in evaluation.mat
inpainting.m: Upon running, the user selects the mask region with the mouse on the figure.