%{
Code to read in features from data and calculate distance between features.

Author:

Patrick Kinnunen
%}


clc; clear; close all;
%% Get feature map by division
load('FeatureMap_By_Division_Vem_1uM.mat'
%Get some initial paramters
f = FeatureMap; %rename for convenience
nCells = length(f);
nTimes = 12;
nTimes = 1;
offset = 12;
offset = 0;
d = zeros(nCells,nCells);
dEuc = zeros(nCells, nCells);
dt = zeros(nCells, nCells, nTimes);
dEucT = zeros(nCells, nCells, nTimes);
nInf = 0;
%Double for loop to get distances
for kk = 1:nTimes
    f = FeatureMap(:,kk+offset);
    for ii = 1:nCells
        %Change any inf values to 0
        nInf = nInf + sum(~isfinite(f{ii,1}));
        f{ii,1}(~isfinite(f{ii,1})) = 0;
        for jj = 1:nCells
            fprintf('ii = %d\t jj = %d\n', ii,jj)
            if ii == 1
                %Change any inf values to 0 - only run during the first
                %iteration.
                f{jj,1}(~isfinite(f{jj,1})) = 0;
                nInf = nInf + sum(~isfinite(f{jj,1}));
            end
%             d(ii,jj) = dtwAlg(f{ii,1}, f{jj,1});
            dEuc(ii,jj) = norm(f{ii,1} - f{jj,1});
        end
    end
%     dt(:,:,kk) = d;
    dEucT(:,:,kk) = dEuc;
end









