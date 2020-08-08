layers = [
%   imageInputLayer([128 128 16],'Name','Input') for 2 channels
    imageInputLayer([128 128 16],'Name','Input')
    
    convolution2dLayer(3,16,'Padding','same','Name','conv_1')
    batchNormalizationLayer('Name','BN_1')
    reluLayer('Name','relu_1')
    convolution2dLayer(3,16,'Padding','same','Name','conv_2')
    batchNormalizationLayer('Name','BN_2')
    reluLayer('Name','relu_2')
    
    maxPooling2dLayer(2,'stride',2,'Name','mxpooling')
    
    convolution2dLayer(3,32,'Padding','same','Name','conv_3')
    batchNormalizationLayer('Name','BN_3')
    reluLayer('Name','relu_3')
    
    convolution2dLayer(3,32,'Padding','same','Name','conv_4')
    batchNormalizationLayer('Name','BN_4')
    reluLayer('Name','relu_4')
    
    maxPooling2dLayer(2,'stride',2,'Name','mxpooling_1')
    
    convolution2dLayer(3,64,'Padding','same','Name','conv_5')
    batchNormalizationLayer('Name','BN_5')
    reluLayer('Name','relu_5')
    
    convolution2dLayer(3,64,'Padding','same','Name','conv_6')
    batchNormalizationLayer('Name','BN_6')
    reluLayer('Name','relu_6')
    
    maxPooling2dLayer(2,'stride',2,'Name','maxpooling_2')
    
    convolution2dLayer(3,128,'Padding','same','Name','conv_15')
    batchNormalizationLayer('Name','BN_15')
    reluLayer('Name','relu_15')
    
    convolution2dLayer(3,128,'Padding','same','Name','conv_16')
    batchNormalizationLayer('Name','BN_16')
    reluLayer('Name','relu_16')
    
    
    transposedConv2dLayer(2,128,'stride',2,'Name','TC_1')
    batchNormalizationLayer('Name','BN_11')
    reluLayer('Name','relu_11')
    
    concatenationLayer(3,2,'Name','concat')
    
    convolution2dLayer(3,32,'Padding','same','Name','conv_7')
    batchNormalizationLayer('Name','BN_7')
    reluLayer('Name','relu_7')
    convolution2dLayer(3,32,'Padding','same','Name','conv_8')
    batchNormalizationLayer('Name','BN_8')
    reluLayer('Name','relu_8')
    
    transposedConv2dLayer(2,64,'stride',2,'Name','TC_2')
    batchNormalizationLayer('Name','BN_12')
    reluLayer('Name','relu_12')
    
    concatenationLayer(3,2,'Name','concat_1')
    
    convolution2dLayer(3,32,'Padding','same','Name','conv_9')
    batchNormalizationLayer('Name','BN_9')
    reluLayer('Name','relu_9')
    convolution2dLayer(3,32,'Padding','same','Name','conv_10')
    batchNormalizationLayer('Name','BN_10')
    reluLayer('Name','relu_10')
    
    transposedConv2dLayer(2,32,'stride',2,'Name','TC_3')
    batchNormalizationLayer('Name','BN_13')
    reluLayer('Name','relu_13')
    
    concatenationLayer(3,2,'Name','concat_2')
    
    convolution2dLayer(3,16,'Padding','same','Name','conv_18')
    batchNormalizationLayer('Name','BN_18')
    reluLayer('Name','relu_18')
    
    convolution2dLayer(3,16,'Padding','same','Name','conv_19')
    batchNormalizationLayer('Name','BN_19')
    reluLayer('Name','relu_19')
    
    convolution2dLayer(1,2,'stride',1,'Name','conv_17')
    % add connection for 2 channel network
%     additionLayer(2,'Name','add');
    
    regressionLayer('Name','Output')];

    lgraph = layerGraph(layers);
    lgraph = connectLayers(lgraph,'relu_6','concat/in2');
    lgraph = connectLayers(lgraph,'relu_4','concat_1/in2');
    lgraph = connectLayers(lgraph,'relu_2','concat_2/in2');
    %add connection for 2 channel network
%     lgraph = connectLayers(lgraph,'Input','add/in2');
    
miniBatchSize = 2;
learnRate = 0.0001;
[X_Train,Y_Train,X_Test,Y_Test] = multi_data_preprocessing(k);
idx = randperm(size(X_Train,4),30);
XValidation = X_Train(:,:,:,idx);
YValidation = Y_Train(:,:,:,idx);
nii = make_nii(abs(X_Train(:,:,1,:)));
save_nii(nii,'Temp_X.nii');
nii = make_nii(abs(Y_Train(:,:,1,:)));
save_nii(nii,'Temp_Y.nii');
valFrequency = floor(size(X_Train,4)/miniBatchSize);
options = trainingOptions('adam', ...
    'InitialLearnRate',learnRate, ...
    'MaxEpochs',30, ...
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',100, ...
    'MiniBatchSize',miniBatchSize, ...
    'VerboseFrequency',valFrequency, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'LearnRateDropFactor', 0.2, ...
    'LearnRateDropPeriod', 50, ...
    'Verbose',false);
net = trainNetwork(X_Train,Y_Train,lgraph,options);