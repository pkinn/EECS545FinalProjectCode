

%{
Code for classifying cells based on nearest neighbors given a distance
matrix

Authors:
Patrick Kinnunen
Natacha Comandante-Lou
%}

clear; clc; close all;
rng(0)
%% import data
%Change the load() arguments to get different distance variables
%load('DTW_Dist_Vem_1uM_every_0-5_hr.mat')
%load('DTW_Dist_Vem_1uM_every_2_hr.mat')
%load('DTW_Dist_Vem_1uM_every_8_hr.mat')
load('DTW_Dist_Vem_1uM_every_12_hr.mat')
labels = load('CellFate_Vem_1_uM.mat');
labels = labels.CellFate;
nCells = length(labels);
nFeat = 1;

%% Split into training and test data
order = randperm(nCells);
orderedLabels = labels(order);
testPct = 0.25;
ntrain = round(nCells*(1-testPct));
yTrain = orderedLabels(1:ntrain);
yTest = orderedLabels(ntrain+1:end);


%% create index for cross-validation
M = 4; %fold  cross-validation
dbin = floor(ntrain/M);
v = 1:dbin:ntrain;
if v(end)~= ntrain
    v(end) = ntrain;
end
for m = 1:M
    cv_idx(m,:) = [v(m),v(m+1)-1];
    if m == M
        cv_idx(m,2) = v(end);
    end
end
% vote = zeros(nFeat,7,length(yTest));
kMax = 72

for m = 1:M
    for ff = 1:nFeat
        %Select the specific type of distance for kNN
        featDtwDist = dtwdist(ff).d;
        orderedDist = featDtwDist(order,:);
        orderedDist = orderedDist(:,order);
        xTrain = orderedDist(1:ntrain,1:ntrain,:);
        cv_test_idx = cv_idx(m,1):cv_idx(m,2);
        cv_train_idx = setdiff(1:ntrain,cv_test_idx);
        xtest_cv = xTrain(cv_test_idx,cv_test_idx,:);
        xtrain_cv = xTrain(cv_train_idx,cv_train_idx,:);
        ytest_cv = yTrain(cv_test_idx); % labels for cross-validation test set from the training data;
        ytrain_cv = yTrain(cv_train_idx); % labels for cross-validation training set from the training data;
        
        % featDtwDist = mean(dtwDist(:,:,1:3),3); % <- This is the distance which is actually considered by the kNN classifier
        %% For new point, calculate distances to other points and determine neighbors to classify
        k = 1:kMax;
        for kk = 1:length(k) %k can be varied to see how it impacts performance
            %Create vars to hold the IDs of the nearest neighbors and the predicted
            %value based on nns.
            nnIds = zeros(length(ytest_cv),k(kk));
            predY = zeros(length(ytest_cv),1);
            nCor = 0;
            for ii = 1:length(cv_test_idx)
                %Find k minimum values and their indices in a list
                [nnVals, nnIds(ii,:)] = mink(orderedDist(cv_train_idx, cv_test_idx(ii)), k(kk));
                %Find the most common label in nearest neighbors
                predY(ii) = mode(ytrain_cv(nnIds(ii,:)));
                vote(ff,kk,ii) = predY(ii);
                if kk == 3
                    nnIds3 = nnIds
                end
            end
        end
    end
    %% Process votes
    %corMat = zeros(nFeat, length(k));
    for kk = 1:length(k)
        for ff = 1:nFeat
            voteMat = vote(1:ff, kk,:);
            predVec = mode(voteMat(1:ff,:),1)';
            corMat(ff,kk,m) = sum(predVec == ytest_cv);
        end
    end
    corMatPct(:,:,m) = corMat(:,:,m)./length(ytest_cv);
    
    %% Calculate Loss
    lossPerPoint = zeros(length(k), length(cv_test_idx));
    for kk = 1:length(k)
        for ff = 1:nFeat
            for ii = 1:length(cv_test_idx)
                corrLabel = labels(cv_test_idx(ii));
                nnID = nnIds(ii, 1:kk);
                labelsOfNNs = labels(nnID);
                p1 = (sum(labelsOfNNs == 1))/(kk);
                if corrLabel == 1
                    loss(ii) = -log(p1);
                else
                    loss(ii) = -log(1-p1);
                end
            end
            lossPerPoint(kk,:) = loss;
            lossMat(ff,kk, m) =1/length(cv_test_idx)*sum(loss);
        end
        disp(kk)
        disp(loss(1))
    end
            
end
mean_lossMat = mean(lossMat,3);
mean_corMatPct = mean(corMatPct,3);
std_corMatPct = std(corMatPct,0,3);
mean_corMatPct = mean(corMatPct,3);

