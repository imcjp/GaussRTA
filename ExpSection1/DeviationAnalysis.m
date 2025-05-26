clear; clc; close all;
addpath('./core');
%% 1. Function handles
fstd = @(x,y) hypergeom([1,x], 1+x, -y);          % Standard function, scalar input only
f1   = @(x,y,m) HybridWithRTAIter(x,y,1,m);       % mode 1
f2   = @(x,y,m) HybridWithRTAIter(x,y,2,m);       % mode 2

%% 2. Parameters
xVals = [0.1, 1, 10];                             % 3 values
yVals = [1.1, (1+sqrt(5))/2, 10, 100];           % 4 values
mVals = 0:1000;                                   % 1001 values

nx = numel(xVals);
ny = numel(yVals);
nm = numel(mVals);

%% 3. Compute reference results Fstd (3×4)
Fstd2D = zeros(nx, ny);
for ix = 1:nx
    for iy = 1:ny
        Fstd2D(ix, iy) = fstd(xVals(ix), yVals(iy));
    end
end
% Expand to 3×4×1001 for error comparison
Fstd = repmat(Fstd2D, 1, 1, nm);

%% 4. Prepare X, Y grid for f1 / f2
[Xgrid, Ygrid] = ndgrid(xVals, yVals);            % 3×4

F1 = zeros(nx, ny, nm);
F2 = zeros(nx, ny, nm);

fprintf('Start computing f1/f2 ... total %d m values\n', nm);

for k = 1:nm
    m = mVals(k);
    % Try-catch to avoid crash in rare numerical issues
    try
        F1k = f1(Xgrid, Ygrid, m); % Supports matrix input, computed at once
    catch ME
        warning('Error in f1 at m=%d: %s', m, ME.message);
        F1k = NaN(nx,ny);
    end
    F1(:,:,k) = F1k;
    try
        F2k = f2(Xgrid, Ygrid, m);
    catch ME
        warning('Error in f2 at m=%d: %s', m, ME.message);
        F2k = NaN(nx,ny);
    end
    F2(:,:,k) = F2k;
end
fprintf('Done!\n');

%% 5. Print results for selected m
sel_m = [1, 10, 100, 1000];
fprintf('\nComparison for selected m values:\n');
for idx = 1:length(sel_m)
    m = sel_m(idx);
    k = find(mVals == m);
    if isempty(k), continue; end
    fprintf('\n--- m = %d ---\n', m);
    for ix = 1:nx
        for iy = 1:ny
            val_fstd = Fstd2D(ix, iy);
            val_f1 = F1(ix, iy, k);
            val_f2 = F2(ix, iy, k);
            err1 = abs(val_f1 - val_fstd) / (abs(val_fstd) + eps);
            err2 = abs(val_f2 - val_fstd) / (abs(val_fstd) + eps);
            fprintf('x=%.2g, y=%.2g | Fstd=%.8g | F1=%.8g (rel.err=%.1e) | F2=%.8g (rel.err=%.1e)\n', ...
                xVals(ix), yVals(iy), val_fstd, val_f1, err1, val_f2, err2);
        end
    end
end

