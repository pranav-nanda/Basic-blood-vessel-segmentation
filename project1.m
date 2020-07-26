% BEGIN
clc;clear all;close all;
var=imread('l41ajay.bmp');
imshow(var);
var1=rgb2gray(var);
figure
imshow(var1);
hold on
rectangle('Position',[240,0,300,480]);
R=rectangle('Position',[240,0,300,480]);
get(R);
subimage=imcrop(var1,[240,0,279,480]);
figure;
imshow(subimage);


% CONTRAST ENHANCEMENT
stretched_Image = adapthisteq(subimage,'clipLimit',0.015,'Distribution','rayleigh');
SSIMVAL = ssim(stretched_Image,subimage)
PSNR = psnr(stretched_Image,subimage)
subplot(2,2,1), imshow(subimage), title('cropped image');
subplot(2,2,2), imshow(stretched_Image), title('Stretched Image');
subplot(2,2,3), imhist(subimage), title('Histogram of Original Image');
subplot(2,2,4), imhist(stretched_Image), title('Histogram of Stretched Image');



% DISCRETE WAVELET TRANSFORM
[cA,cH,cV,cD] = dwt2(stretched_Image,'haar');
cA=uint8(cA);
figure;imshow(cA,[]);title('First Level Decomposition')



% EDGE DETECTION
figure; imshow(cA,[]), title('Without noise')
z=imnoise(cA,'gaussian');
figure;
imshow(z,[]), title('Gaussian noise')
Ea = edge(cA,'canny',[0.15,0.28])
Ed = edge(z,'canny',[0.15,0.32])
figure;imshow(Ea), title('canny without noise')
figure;imshow(Ed), title('canny with noise')

% PRATT'S FIGURE OF MERIT FOR PERFORMANCE OF EDGE DETECTION
Ea=double(Ea);
Ed=double(Ed);
[N,M]=size(Ea);
if [N,M]~=size(Ed) 
  error('Actual and detected edge image sizes must be same');
end;
a=0.1; % edge shift penalty constant;
Na=sum(sum(Ea));Nd=sum(sum(Ed));
c=1/max(Na,Nd);
[ia,ja]=find(Ea==1);
for l=1:Na
  Aes(l)=Ed(ia(l),ja(l));
end;
mi=ia(find(Aes==0));
mj=ja(find(Aes==0));
F=c*sum(Aes);
for k=1:length(mi) 
  n1=0;n2=0;m1=0;m2=0; 
  while sum(sum(Ed(mi(k)-n1:mi(k)+n2,mj(k)-m1:mj(k)+m2)))<1
    if mi(k)-n1>1 n1=n1+1;end;  
    if mi(k)+n2<N n2=n2+1;end;  
    if mj(k)-m1>1 m1=m1+1;end;  
    if mj(k)+m2<M m2=m2+1;end;  
  end;
  di=max([n1 n2 m1 m2]);
  F=F+c/(1+a*di^2);
end;



