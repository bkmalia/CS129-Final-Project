clear
close all
load('MY\DIR\uniqueDefectMap.mat');
%% Draw Mask
I = LDOS_1def(:,:,1);
figure
imshow(I,[])
h = images.roi.Rectangle();
draw(h)
mask = createMask(h);
%% Inpainting
J = inpaintExemplar(I,mask);
Jcrop = J(31:91,31:91);
for i = 1:3
Jcroprbg(:,:,i) = Jcrop;
end
magPos = [(h.Position(1:2)-30)*4,h.Position(3:4)*4];
res = imresize(Jcroprbg,4);
K = insertObjectAnnotation(I,'rectangle',h.Position,'Mask');
L = insertObjectAnnotation(res,'rectangle',magPos,'Mask');
%% Plot
figure(1);
montage({K,L});
title(['Original Image','    |    ','Inpainted Image']);