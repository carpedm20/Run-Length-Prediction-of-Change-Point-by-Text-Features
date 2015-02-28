clear;
companies = {'GOOGL','AAPL','IBM','MSFT','FB'};
companies = {'AAPL'};

%companies = {'EUR','KRW','JPY'};
%companies = {'KRW'};

years = [{2010;2010},{2011;2011},{2012;2012},{2013;2013},{2014;2014},{2010;2014}];
%years = [{2011;2012}];
%years = [{2010;2015}];
lambda = 250;

%companies = {'GOOGL'};
%years = [2014];
scale = 4000;
%scale = 4000;

for idx=companies
    year_total = [];
    date_total = [];
    
    company = idx{1};
    
    if strcmp(company,'FB')
        years = [{2012;2012},{2013;2013},{2014;2014},{2012;2014}];
    else
        years = [{2010;2010},{2011;2011},{2012;2012},{2013;2013},{2014;2014},{2010;2014}];
    end
    
    %years = [{2010;2010}];
    years = [{2014;2014}];
    
    for year=years
        year_1 =  num2str(year{1});
        year_2 =  num2str(year{2});
        
        load(sprintf('./mat/%s-prob-%s-%s.mat', company, year_1, year_2));
        load(sprintf('./mat/%s-weight-%s-%s.mat', company, year_1, year_2));
        load(sprintf('./mat/%s-dic-%s-%s.mat', company, year_1, year_2));
        load(sprintf('./mat/%s-count-%s-%s.mat', company, year_1, year_2));
        %weight = normalize_var(weight,-1,1);
        %word_count=word_count/sum(word_count);
        
        
        if year{1}==2010 && year{2}==2014
            X = year_total;
            date = date_total;
        else
            hazard_func  = @(r) constant_hazard(r, lambda);

            mu0    = 0;
            kappa0 = 1;
            alpha0 = 1;
            beta0  = 1;

            start_date = sprintf('01-jan-%s', year_1);
            end_date = sprintf('31-dec-%s', year_2);
            %start_date = sprintf('%s-1-1', year_1);
            %end_date = sprintf('%s-12-31', year_1);

            d1 = get_gf_histdata(company, 'start', start_date, 'end', end_date);
            %d1 = get_currency_histdata(company, start_date, end_date);

            date = fliplr(d1.date');
            X = fliplr(d1.open');
            X = X(1:end);

            if isnan(X(1))
                X = X(2:end);
            end

            if isnan(X(end))
                X = X(1:end-1);
            end
            
            if strcmp(company, 'JPY')
                X = X*10;
            end
            if strcmp(company, 'CNY')
                X = X*100;
            end
            if strcmp(company, 'EUR')
                X = X*100;
            end
            
            year_total = [year_total,X];
            date_total = [date_total,date];
        end
        
        MMAX=198;
        X = X(:,1:MMAX);

        [n, T] = size(X);
        prob(:,end+T)=1;
        prob(prob==0)=1;

        % Plot the data and we'll have a look.
        subplot(2,1,1);
        plot([1:T]', X, 'b-');
        grid;

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

        P = zeros([T+1 T]);
        % Loop over the data like we're seeing it all for the first time.
        %for t=1:10
        for t=1:T
          %cur_date = datestr(datenum(date{t},'dd-mm-yy'),'yyyymmdd');
          %eval(sprintf('cur_articles=d%s;',strrep(cur_date,'-','')));
          
%           for x=0:t
%               y = t-x;
%               d = datestr(datenum(date{t},'dd-mm-yy')-x,'yyyymmdd');
%               eval(sprintf('cur_articles=d%s;',strrep(d,'-','')));
%               
%               k=0;
%               l=0;
%               suc=0;
%               fail=0;
%               for i_news=1:length(cur_articles);
%                   words = cur_articles(i_news);
%                   words = words{1:1};
%                   for i_word=1:length(words);
%                       word = words(i_word)+1;
%                       if weight(word) ~= 0
%                           run_prob = prob(word,:)/sum(prob(word,:));
%                           tmp1 = run_prob(1,y+2) * exp(-x/(weight(word))) / exppdf(y+1,lambda);
%                           tmp2 = run_prob(1,1) * exp(-x/(weight(word))) / exppdf(y+1,lambda);
%                           if tmp1 ~= 0 && isinf(tmp1) ~= 1 && tmp2 ~= 0 && isinf(tmp2) ~= 1
%                             k = k + log(tmp1);
%                             l = l + log(tmp2);
%                           end
%                       end
%                   end;
%               end;
%               %disp(sprintf('%f,%f',l,k))
%               z=1/(1+exp(l-k));
%               P(t,x+1)=z;
%               %disp(z)
%               %disp(sprintf('%d,%d,%f,%d',suc,fail, z, l-k))
%           end;
          
          % Evaluate the predictive distribution for the new datum under each of
          % the parameters.  This is the standard thing from Bayesian inference.
          predprobs = studentpdf(X(t), muT, ...
                                 betaT.*(kappaT+1)./(alphaT.*kappaT)/scale, ...
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
        subplot(1,1,1);
        hold off;
        plot(NaN);

        colormap(gray());
        imagesc(-log(R));
        hold on;

        [ax,p1,p2] = plotyy([1:T+1], maxes, [1:T], X, 'semilogy', 'plot');
        set(p1,'Color','r');

        %ylabel(ax(1), strcat('Lambda : ', int2str(lambda))); % label left y-axis

        for point=2:T
            if maxes(point-1) > maxes(point)
                hold(ax(2), 'on'); 
                plot(ax(2), point-1, X(point-1), 'O',...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor','w',...
                    'MarkerSize',5);
            end
        end
        file_name = sprintf('%s-%s-%s-%s-%s.mat', company, num2str(lambda), num2str(scale), year_1, year_2);
        file_name = sprintf('%s-%s-%s-%s-%s-P.mat', company, num2str(lambda), num2str(scale), year_1, year_2);
        disp(file_name)
        
        if ~exist(pfile_name, 'file')
            save(pfile_name, 'P','K');
        end
        save(file_name, 'maxes', 'R', 'X', 'date');
    end
end
