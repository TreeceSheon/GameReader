function [X_Train,Y_Train,X_Test,Y_Test] = multi_data_preprocessing(k)   
%% ---------------------- resize k-space data -------------------------
    [x,y,slices,echos] = size(k);
    ksp = k(x/4 : 3*x/4-1, y/4 : 3*y/4-1,:,:);
    img_full = zeros(x/2,y/2,slices,echos);
    img_sub = zeros(x/2,y/2,slices,echos);
    %% -------------------------- create mask -----------------------------
    mask = zeros(x/2,y/2);
    i = 1;
    while (i < x/2)
        j = 1;
        while (j < y/2)
            mask(i,j) = 1;
            j = j + 3;
        end
        i = i + 2;
    end
    mask(32:96,32:96) = ones(65,65);
    %%----------------------- image preparation --------------------------------
    for i = 1:8
        label_temp = ksp(:,:,:,i); 
        sub_temp = ksp(:,:,:,i) .* mask;

        label_temp = label_temp / max(abs(label_temp(:)));
        sub_temp = sub_temp / max(abs(sub_temp(:)));

        img_full_single_echo = fftn(fftshift(label_temp));
        img_sub_single_echo = fftn(fftshift(sub_temp));
        img_full_single_echo = img_full_single_echo / max(abs(img_full_single_echo(:)));
        img_sub_single_echo = img_sub_single_echo / max(abs(img_sub_single_echo(:)));

        img_full(:,:,:,i) = img_full_single_echo;
        img_sub(:,:,:,i) = img_sub_single_echo;
    end
    full = zeros(x/2,y/2,2*echos,slices);
    sub = zeros(x/2,y/2,2*echos,slices);
    for i = 1:slices
        for j = 1:echos
            sub(:,:,2*j-1,i) = abs(img_sub(:,:,i,j));
            sub(:,:,2*j,i) = angle(img_sub(:,:,i,j));
           
        end
    end
    R = randperm(slices);
    X_Train = sub(:,:,:,R(1:100));
    Y_Train(:,:,1,:) = abs(img_full(:,:,R(1:100),1));
    Y_Train(:,:,2,:) = imag(img_full(:,:,R(1:100),1));
    X_Test = sub(:,:,:,R(101:end));
    Y_Test(:,:,1,:) = abs(img_full(:,:,R(100:132),1));
    Y_Test(:,:,2,:) = imag(img_full(:,:,R(100:132),1));
end





