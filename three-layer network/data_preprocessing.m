function [X_Train,Y_Train,X_Test,Y_Test] = data_preprocessing(k)
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
    %%------------------------ data partition ----------------------------------
    sz = size(ksp);
    X = zeros([sz(1),sz(2),sz(3)*sz(4)]);
    Y = zeros([sz(1),sz(2),sz(3)*sz(4)]);
    R = randperm(sz(3)*sz(4));
    
    for i = 1:sz(4)
        X(:,:,sz(3)*(i-1)+1:sz(3)*i) = img_sub(:,:,:,i);
        Y(:,:,sz(3)*(i-1)+1:sz(3)*i) = img_full(:,:,:,i);
    end
    
    X_Train(:,:,1,:) = abs(X(:,:,R(1:300)));
    X_Train(:,:,2,:) = imag(X(:,:,R(1:300)));
    Y_Train(:,:,1,:) = abs(Y(:,:,R(1:300)));
    Y_Train(:,:,2,:) = imag(Y(:,:,R(1:300)));
    
    X_Test(:,:,1,:) = mat2gray((abs(X(:,:,R(801:end)))));
    X_Test(:,:,2,:) = mat2gray(imag(X(:,:,R(801:end))));
    Y_Test(:,:,1,:) = mat2gray(abs(X(:,:,R(801:end))));
    Y_Test(:,:,2,:) = mat2gray(imag(X(:,:,R(801:end))));
    
    
    nii = make_nii(abs(X));
    save_nii(nii,'tempX.nii')
    nii = make_nii(abs(Y));
    save_nii(nii,'tempY.nii')
end




