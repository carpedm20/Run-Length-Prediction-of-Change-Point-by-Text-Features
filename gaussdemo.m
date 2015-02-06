clear;

%lambdas = [10,20,30,40,50,60,70,80,90,100];
%lambdas = [1:5]*3*1;
lambdas = [100];
%lambdas = [100];

N = floor(sqrt(numel(lambdas)+1));
M = ceil((numel(lambdas)+1)/N);

mu0    = 0;
kappa0 = 1;
alpha0 = 1;
beta0  = 1;

d1 = get_gf_histdata('GOOGL','start','01-jan-2014');

X = fliplr(d1.open');
X = X(2:end);
[n, T] = size(X);

% Plot the data and we'll have a look.
subplot(N,M,1);
plot([1:T]', X);
grid;

for idx = 1:numel(lambdas)
    disp(idx);
    
    lambda = lambdas(idx);
    hazard_func  = @(r) constant_hazard(r, lambda);
    
    % Now we have some data in X and it's time to perform inference.
    % First, setup the matrix that will hold our beliefs about the current
    % run lengths.  We'll initialize it all to zero at first.  Obviously
    % we're assuming here that we know how long we're going to do the
    % inference.  You can imagine other data structures that don't make that
    % assumption (e.g. linked lists).  We're doing this because it's easy.
    R = zeros([T+1 T]);

    % At time t=1, we actually have complete knowledge about the run
    % length.  It is definitely zero.  See the paper for other possible
    % boundary conditions.
    R(1,1) = 1;

    % Track the current set of parameters.  These start out at the prior and
    % accumulate data as we proceed.
    muT    = mu0;
    kappaT = kappa0;
    alphaT = alpha0;
    betaT  = beta0;

    % Keep track of the maximums.
    maxes  = zeros([T+1]);

    % Loop over the data like we're seeing it all for the first time.
    for t=1:T
      
      % Evaluate the predictive distribution for the new datum under each of
      % the parameters.  This is the standard thing from Bayesian inference.
      variance = betaT.*(kappaT+1)./(alphaT.*kappaT)/1000;
      predprobs = studentpdf(X(t), muT, ...
                             variance, ...
                             2 * alphaT);

      % Evaluate the hazard function for this interval.
      H = hazard_func([1:t]');

      % Evaluate the growth probabilities - shift the probabilities down and to
      % the right, scaled by the hazard function and the predictive
      % probabilities.
      R(2:t+1,t+1) = R(1:t,t) .* predprobs .* (1-H);

      % Evaluate the probability that there *was* a changepoint and we're
      % accumulating the mass back down at r = 0.
      R(1,t+1) = sum( R(1:t,t) .* predprobs .* H );

      % Renormalize the run length probabilities for improved numerical
      % stability.
      R(:,t+1) = R(:,t+1) ./ sum(R(:,t+1));

      % Update the parameter sets for each possible run length.
      muT0    = [ mu0    ; (kappaT.*muT + X(t)) ./ (kappaT+1) ];
      kappaT0 = [ kappa0 ; kappaT + 1 ];
      alphaT0 = [ alpha0 ; alphaT + 0.5 ];
      betaT0  = [ beta0  ; betaT + (kappaT .*(X(t)-muT).^2)./(2*(kappaT+1)) ];
      muT     = muT0;
      kappaT  = kappaT0;
      alphaT  = alphaT0;
      betaT   = betaT0;

      % Store the maximum, to plot later.
      maxes(t) = find(R(:,t)==max(R(:,t)));

    end

    % Show the log smears and the maximums.
    subplot(N,M,1+idx);
    hold off;
    plot(NaN);

    colormap(gray());
    imagesc(-log(R));
    hold on;
    
    [ax,p1,p2] = plotyy([1:T+1], maxes, [1:T], X, 'semilogy', 'plot');
    %ylabel(ax(1), strcat('Lambda : ', int2str(lambda))); % label left y-axis

    for point=2:T
        if maxes(point-1) > maxes(point)
            hold(ax(2), 'on'); 
            plot(ax(2), point,X(point),'O');
        end
    end
    
    hold off;
end

% Use exportfig to save the image.  You might not have this installed.
if 0
  exportfig(gcf, 'gaussdemo.png', ...
            'Format',     'png', ...
            'Width',      8,   ...
            'Height',     8,   ...
            'FontMode',   'fixed', ...
            'FontSize',   10, ...
            'LineMode',   'fixed', ...
            'LineWidth',  0.5, ...
            'Color',      'rgb', ...
            'Bounds',     'loose');
end
