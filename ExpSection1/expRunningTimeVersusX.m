clear; clc; close all;
addpath('./core');
%% 0) Function handles
f1 = @(x,y) hypergeom([1,x], 1+x, -y);
f2 = @(x,y) HybridWithRTA(x, y, 1);
f3 = @(x,y) HybridWithRTA(x, y, 2);
f4 = @(x,y) pyHyp2f1(x,y);

%% 1) Parameters
xVals = 10.^(-3:0.25:3);      % 25 values of x (10^-3 ... 10^3)
yVals = [1.1 (1+sqrt(5))/2 10 100];   % 6 values of y
Nrep  = 10;                 % Number of repetitions per sample

nx = numel(xVals);
ny = numel(yVals);

T1 = zeros(nx, ny);           % Time matrix for f1
T2 = zeros(nx, ny);           % Time matrix for f2
T3 = NaN(nx, ny);             % Time matrix for f3 (default NaN)
T4 = zeros(nx, ny);           % Time matrix for f4

%% 2) Warm-up – eliminate JIT initial overhead by running once
warmX = xVals(1);
warmY = yVals(find(yVals>1,1));    % Use the first y>1 to also warm up f3
f1(warmX, warmY);
f2(warmX, warmY);
f3(warmX, warmY);
f4(warmX, warmY);

%% 3) Main timing loop (outer loop on y)
fprintf('Start timing, total samples %d × %d = %d\n', ny, nx, nx*ny);
wb  = waitbar(0, 'Timing f1/f2/f3 ...');
cnt = 0; total = nx * ny;

for iy = 1:ny                    % -- Outer loop over y
    y = yVals(iy);
    for ix = 1:nx                % -- Inner loop over x
        x = xVals(ix);

        % ---- f1 ----
        t0 = tic;
        for k = 1:Nrep, f1(x,y); end
        T1(ix,iy) = toc(t0) / Nrep;

        % ---- f2 ----
        t0 = tic;
        for k = 1:Nrep, f2(x,y); end
        T2(ix,iy) = toc(t0) / Nrep;

        % ---- f3 ---- (only for y > 1)
        if y > 1
            try
                t0 = tic;
                for k = 1:Nrep, f3(x,y); end
                T3(ix,iy) = toc(t0) / Nrep;
            catch ME
                warning('f3 failed: x=%g, y=%g -> %s', x, y, ME.message);
                T3(ix,iy) = NaN;
            end
        end

        % ---- f4 ----
        t0 = tic;
        for k = 1:Nrep, f4(x,y); end
        T4(ix,iy) = toc(t0) / Nrep;

        % Progress bar
        cnt = cnt + 1;
        waitbar(cnt/total, wb);

        % Print current results
        if (y > 1) && ~isnan(T3(ix,iy))
            t3str = sprintf('%.3es', T3(ix,iy));
        else
            t3str = 'NaN';
        end
        fprintf('Sample %4d/%d | y=%6.1f, x=%9.2e  →  T1=%.3es  T2=%.3es  T3=%s  T4=%.3es\n', ...
                cnt, total, y, x, T1(ix,iy), T2(ix,iy), t3str, T4(ix,iy));
    end
end
close(wb);
