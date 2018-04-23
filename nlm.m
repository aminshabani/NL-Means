%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% An implementation of the NL-means algorithm from the paper (A review of 
% image denoising algorithms with a new one - nonlocal means NLM)
% For more information, visit the following paper
% https://hal.archives-ouvertes.fr/hal-00271141/document
% Mohammad Amin Shabani (2017-28825)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear;
h = 0.15;
ww = 2; % window width
sw = 10; % search_window width
G = fspecial('gaussian',ww*2+1,1);
img = im2double(imread('lena.jpg'));
img = img(500:900,470:770,:);
img = imresize(img,[256,256]);
imwrite(img,'results/input_image.jpg');
org_img = img;
img = padarray(img,[sw, sw],'symmetric','both');
image_size = size(img);
noise = randn([image_size(1), image_size(2), image_size(3)]);
noise = noise/10;
img = img + noise;
imwrite(img(sw+1:end-sw,sw+1:end-sw,:),'results/noisy_image.jpg');
final_result = zeros(image_size);
for channel = 1:3
    result = zeros([image_size(1) image_size(2)]);
    for i = sw+1:image_size(1)-sw
        for j = sw+1:image_size(2)-sw
            z = 0;
            b = im2col(img(max(i-sw,1):min(i+sw,image_size(1)), ...
                max(j-sw,1):min(j+sw,image_size(2)),channel),...
                [ww*2+1 ww*2+1],'sliding');
            w = zeros([size(b,2) 1]);
            ref = img(i-ww:i+ww,j-ww:j+ww,channel);
            for k = 1:size(b,2)
                tmp = ref(:) - b(:,k);
                tmp = (tmp.^2).*G(:);
                w(k) = exp(-sum(tmp(:))/(h^2));
                z = z + w(k);
            end
            w = w/z;
            for k = 1:size(b,2)
                x = mod(k-1,17) + max(i-sw,1) + ww;
                y = floor((k-1)/17) + max(j-sw,1) + ww;
                result(i,j) = result(i,j) + w(k)*img(x,y,channel);
            end
        end
    end
    final_result(:,:,channel) = result;
end
img = img(sw+1:end-sw,sw+1:end-sw,:);
final_result = final_result(sw+1:end-sw,sw+1:end-sw,:);
imwrite(final_result,'results/final_result.jpg');
noisy_psnr = psnr(img,org_img);
output_psnr = psnr(final_result, org_img);
disp(['the noisy_psnr is ',num2str(noisy_psnr), ...
    ' and the output_psnr is ', num2str(output_psnr)])