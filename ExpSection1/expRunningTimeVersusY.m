clear all; clc; close all
addpath('./core');
f1 = @(x,y) hypergeom([1,x],1+x,-y);
f2 = @(x,y) HybridWithRTA(x,y,1);
f3 = @(x,y) HybridWithRTA(x,y,2);
f4 = @(x,y) pyHyp2f1(x,y);

%% 1. Parameter settings
xVals = [0.1 1 10 100];          % 4 values of x
yVals = 10.^(-3:0.05:3);         % 25 values of y
yVals(65) = (1+sqrt(5))/2;
Nrep = 10;                     % Number of repetitions per point

nx = numel(xVals);
ny = numel(yVals);

T1 = zeros(nx, ny);              % Time matrix for f1
T2 = zeros(nx, ny);              % Time matrix for f2
T3 = NaN(nx, ny);                % Time matrix for f3 (default NaN)
T4 = zeros(nx, ny);              % Time matrix for f4

%% 2. Warm-up – Eliminate first call overhead
fprintf('Warm-up phase...\n');
warmX = xVals(1);
warmY = yVals(find(yVals>1,1));  % Find the first y > 1 for f3 warm-up
f1(warmX, warmY);                % Warm up f1
f2(warmX, warmY);                % Warm up f2
if ~isempty(warmY)
    f3(warmX, warmY);            % Warm up f3
end
f4(warmX, warmY);                % Warm up f4


%% 3. Timing
fprintf('Start timing...\n');
wb = waitbar(0, 'Running timing tests...');

totalIter = nx * ny;
iterCount = 0;

for ix = 1:nx
    x = xVals(ix);
    for iy = 1:ny
        y = yVals(iy);

        %% Timing for f1
        tStart = tic;
        for k = 1:Nrep
            r = f1(x, y); %#ok<NASGU>
        end
        T1(ix, iy) = toc(tStart) / Nrep;

        %% Timing for f2
        tStart = tic;
        for k = 1:Nrep
            r = f2(x, y); %#ok<NASGU>
        end
        T2(ix, iy) = toc(tStart) / Nrep;

        %% Timing for f3 (only y > 1)
        if y > 1
            try
                tStart = tic;
                for k = 1:Nrep
                    r = f3(x, y); %#ok<NASGU>
                end
                T3(ix, iy) = toc(tStart) / Nrep;
            catch ME
                warning('f3 computation failed (x=%.3g, y=%.3g): %s', x, y, ME.message);
                T3(ix, iy) = NaN;
            end
        end

        %% Timing for f4
        tStart = tic;
        for k = 1:Nrep
            r = f4(x, y);
        end
        T4(ix, iy) = toc(tStart) / Nrep;

        %% Progress feedback
        iterCount = iterCount + 1;
        waitbar(iterCount/totalIter, wb, ...
            sprintf('Testing x=%.3g, y=%.3g (%d/%d)', x, y, iterCount, totalIter));
        % Prepare T3 string for printing
        if (y > 1) && ~isnan(T3(ix, iy))
            t3str = sprintf('%.4es', T3(ix, iy));
        else
            t3str = 'NaN';
        end
        
        fprintf('x=%6.3g, y=%8.5g  |  T1=%.4es  T2=%.4es  T3=%s  T4=%.4es\n', ...
                x, y, T1(ix, iy), T2(ix, iy), t3str, T4(ix, iy));

    end
end
close(wb);
