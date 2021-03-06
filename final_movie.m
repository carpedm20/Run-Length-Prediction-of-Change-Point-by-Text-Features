clear;
companies = {'GOOGL','AAPL','IBM','MSFT','FB'};
companies = {'AAPL'};

%companies = {'EUR','KRW','JPY'};
companies = {'KRW'};

years = [{2010;2010},{2011;2011},{2012;2012},{2013;2013},{2014;2014},{2010;2014}];
%years = [{2011;2012}];
%years = [{2010;2015}];
lambda = 250;

%companies = {'GOOGL'};
%years = [2014];
scale = 4000;
%scale = 4000;


companies = {'knight'}

for idx=companies
    year_total = [];
    date_total = [];
    
    company = idx{1};
    
    if strcmp(company,'FB')
        years = [{2012;2012},{2013;2013},{2014;2014},{2012;2014}];
    else
        years = [{2010;2010},{2011;2011},{2012;2012},{2013;2013},{2014;2014},{2010;2014}];
    end
    
    years = [{2014;2014}];
    years = [{2008;2009}];
    
    for year=years
        year_1 =  num2str(year{1});
        year_2 =  num2str(year{2});
        
        MMAX = 60
        pfile_name = sprintf('%s-%s-%s-%s-%s-P-%d.mat', company, num2str(lambda), num2str(scale), year_1, year_2, MMAX);
        
        if exist(pfile_name, 'file')
            load(pfile_name);
        end
        %load('KRW-250-4000-2014-2014-P-save.mat')
        %save('knight-250-4000-2008-2009-P-save.mat', 'K','P');
        load('knight-250-4000-2008-2009-P-save.mat');
        load(sprintf('./mat/%s-prob-%s-%s.mat', company, year_1, year_2));
        load(sprintf('./mat/%s-weight2-%s-%s.mat', company, year_1, year_2));
        load(sprintf('./mat/%s-dic-%s-%s.mat', company, year_1, year_2));
        load(sprintf('./mat/%s-count-%s-%s.mat', company, year_1, year_2));
        weight = normalize_var(weight,0,1);
        word_count=word_count/sum(word_count);
        
        hazard_func  = @(r) constant_hazard(r, lambda);

        mu0    = 0;
        kappa0 = 1;
        alpha0 = 1;
        beta0  = 1;

        start_date = sprintf('01-jan-%s', year_1);
        end_date = sprintf('31-dec-%s', year_2);
        start_date = sprintf('%s-1-1', year_1);
        end_date = sprintf('%s-12-31', year_1);

        %d1 = get_gf_histdata(company, 'start', start_date, 'end', end_date);
        %d1 = get_currency_histdata(company, start_date, end_date);

        dfin = fopen(sprintf('%s.csv', company), 'r');
        datin = textscan(dfin, '%s%f', 'Delimiter','\t');

        %table = readtable(company,'Delimiter','\t','ReadVariableNames',false)
        date = datestr(datin{1,1});
        X = datin{1,2}'
        
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
        RR(1,1) = 1;
        
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
        maxess  = zeros([T+1]);
        
        if ~exist('P') || ~exist('K')
            %P = zeros([T+1 1]);
            P = zeros([T+1 T]);
            K = zeros([T+1 T]);
        else
             P(end+(T-length(P)),end+(T-length(P)))=0;
        end
        
        % Loop over the data like we're seeing it all for the first time.
        %for t=1:20
        for t=1:T
            %cur_date = datestr(datenum(date{t},'dd-mm-yy'),'yyyymmdd');
            %eval(sprintf('cur_articles=d%s;',strrep(cur_date,'-','')));
            if t>2
                min_t=t-2;
            else
                min_t=t;
            end
            if sum(P(t,min_t:t))==0
                %k=0;
                %l=0;
                
                %d = datestr(datenum(date{t},'dd-mm-yy'),'yyyymmdd');
                %d = datestr(datenum(date{t},'yyyy-mm-dd'),'yyyymmdd');
                %d = datestr(datenum(date(t),'yyyy-mm-dd'),'yyyymmdd');
                d = datestr(datenum(date(t,:),'dd-mmm-yyyy'),'yyyymmdd');
                
                eval(sprintf('cur_articles=d%s;',strrep(d,'-','')));
                
                for x=1:t
                    y = t-x;
                    k=0;
                    l=0;
                    for i_news=1:length(cur_articles);
                        words = cur_articles(i_news);
                        words = words{1:1};
                        for i_word=1:length(words);
                            word = words(i_word)+1;
                            if weight(word) ~= 0
                                %run_prob = prob(word,:)/sum(prob(word,:));
                                run_prob = smoothts(prob(word,:)/sum(prob(word,:)),'g');
                                tmp1 = log(run_prob(1,y+2)) + log(exppdf(x,weight(word))) - log(exppdf(y+1,lambda));
                                tmp2 = log(run_prob(1,1)) + log(exppdf(x,weight(word))) - log(exppdf(y+1,lambda));% + log(1/lambda) ;
                                if tmp1 ~= 0 && isinf(tmp1) ~= 1 && tmp2 ~= 0 && isinf(tmp2) ~= 1
                                    k = k + tmp1 - log(word_count(word));
                                    l = l + tmp2 - log(word_count(word));
                                end
                            end
                        end;
                    end;
                    %z=1/(1+exp(l-k));
                    P(t,x)=k-l;
                    K(t,x)=l-l;
                end;
                %                   for i_news=1:length(cur_articles);
                %                       words = cur_articles(i_news);
                %                       if class(words) ~= 'cell'
                %                           continue
                %                       end
                %                       words = words{1:1};
                %                       for i_word=1:length(words);
                %                           word = words(i_word)+1;
                %                           if weight(word) ~= 0
                %                               run_prob = smoothts(prob(word,:)/sum(prob(word,:)),'g');
                %                               %run_prob = prob(word,:)/sum(prob(word,:));
                %                               %tmp1 = run_prob(1,y+2) * exp(-x/(weight(word))) / exppdf(y+1,lambda);
                %                               %tmp2 = run_prob(1,1) * exp(-x/(weight(word))) / exppdf(y+1,lambda);
                %                               tmp1 = log(run_prob(1,y+2)) ;%+  log(weight(word)-x); %log(exp(-x/(weight(word)))); %- log(exppdf(y+1,lambda));
                %                               tmp2 = log(run_prob(1,1)) ;%+ log(1/lambda); %log(exp(-x/(weight(word)))); %- log(exppdf(y+1,lambda));
                %                               if tmp1 ~= 0 && isinf(tmp1) ~= 1 && tmp2 ~= 0 && isinf(tmp2) ~= 1
                %                                 %k = k + log(tmp1);
                %                                 %l = l + log(tmp2);
                %                                 k = k + (tmp1);
                %                                 l = l + (tmp2);
                %                               end
                %                           end
                %                       end;
                %                   end;
                %                   %disp(sprintf('%f,%f',l,k))
                %                   %disp(z)
                %                   %disp(sprintf('%d,%d,%f,%d',suc,fail, z, l-k))
                %               z=1/(1+exp(l-k));
                %               P(t)=z;
            end;
            
            % Evaluate the predictive distribution for the new datum under each of
            % the parameters.  This is the standard thing from Bayesian inference.
            predprobs = studentpdf(X(t), muT, ...
                betaT.*(kappaT+1)./(alphaT.*kappaT)/scale, ...
                2 * alphaT);
            
            % Evaluate the hazard function for this interval.
            %xxx = sum(exp(P),1)./(sum(exp(P),1)+sum(exp(K),1));
            xxx = 1./(sum(P(1:t,:),1));
            if t>2
                xxx = normalize_var(xxx(1,1:t),0,1);
            end
            xxx = xxx';
            H = hazard_func([1:t]');
            
            
            % Evaluate the growth probabilities - shift the probabilities down and to
            % the right, scaled by the hazard function and the predictive
            % probabilities.
            %R(2:t+1,t+1) = R(1:t,t) .* predprobs .* (1-H);
            R(2:t+1,t+1) = R(1:t,t) .* (1-xxx(1:t,1)) .* predprobs  ;
            RR(2:t+1,t+1) = RR(1:t,t) .* predprobs .* (1-H);
            
            % Evaluate the probability that there *was* a changepoint and we're
            % accumulating the mass back down at r = 0.
            R(1,t+1) = sum( R(1:t,t) .* xxx(1:t,1) .* predprobs );
            RR(1,t+1) = sum( RR(1:t,t) .* predprobs .* H );
            
            % Renormalize the run length probabilities for improved numerical
            % stability.
            R(:,t+1) = R(:,t+1) ./ sum(R(:,t+1));
            RR(:,t+1) = RR(:,t+1) ./ sum(RR(:,t+1));
            
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
            maxess(t) = find(RR(:,t)==max(RR(:,t)));
            
        end
        
        % Show the log smears and the maximums.
        subplot(2,1,1);
        hold off;
        plot(NaN);
        
        colormap(gray());
        %colormap('black');
        map = zeros(T , 3);
        %colormap(map)
        imagesc(-log(RR-min(min(RR))));
        %d=colorbar;
        %d.Position = [0.96 0.58 0.01 0.34];
        hold on;
        
        [ax,p1,p2] = plotyy([1:T+1], maxess, [1:T], X, 'semilogy', 'plot');
        set(p1,'Color','r');
        set(p2,'Color',[0.5 0.5 0.5]);
        set(p1,'LineWidth',2);
        
        %fill([maxes,fliplr(maxes)],[maxes-5,fliplr(maxes-5)],'b');  
        ylabel(ax(1), 'Run Length (days)'); % label left y-axis
        %set(ax(1),'ylim',[min(maxes(:,1)) max(maxes(:,1))])
        set(ax(2),'ylim',[min(X) max(X)+100000000]);
        set(ax,{'ycolor'},{'k';'k'})
        y=ylabel(ax(2), 'Cumulative revenue', 'Color','black'); % label left y-axis
        %ylabel
        xlabel(ax(1), 'Day'); % label left y-axis
        %set(ax(1),'YDir','reverse');
        
        for point=2:T
            if maxess(point-1) > maxess(point)
                hold(ax(2), 'on');
                plot(ax(2), point-1, X(point-1), 'O',...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor','w',...
                    'MarkerSize',5);
            end
        end
        file_name = sprintf('%s-%s-%s-%s-%s.mat', company, num2str(lambda), num2str(scale), year_1, year_2);
        disp(file_name)
        
        % Show the log smears and the maximums.
        subplot(2,1,2);
        hold off;
        plot(NaN);
        
        colormap(gray());
        %colormap('black');
        map = zeros(T , 3);
        %colormap(map)

        imagesc(-log(R-min(min(R))));
        %c=colorbar;
        %c.Position = [0.96 0.11 0.01 0.34];
        hold on;
        
        [ax,p1,p2] = plotyy([1:T+1], maxes, [1:T], X, 'semilogy', 'plot');
        set(p1,'Color','r');
        set(p2,'Color',[0.5 0.5 0.5]);
        set(p1,'LineWidth',2);
        
        %fill([maxes,fliplr(maxes)],[maxes-5,fliplr(maxes-5)],'b');  
        ylabel(ax(1), 'Run Length (days)'); % label left y-axis
        set(ax(2),'ylim',[min(X) max(X)+100000000]);
        %set(ax(1),'ylim',[min(maxes(:,1)) max(maxes(:,1))])
        set(ax,{'ycolor'},{'k';'k'})
        y=ylabel(ax(2), 'Cumulative revenue', 'Color','black')
        xlabel(ax(1), 'Day'); % label left y-axis
        %set(ax(1),'YDir','reverse');
        
        for point=2:T
            if maxes(point-1) > maxes(point);
                hold(ax(2), 'on');
                plot(ax(2), point-1, X(point-1), 'O',...
                    'MarkerEdgeColor','k',...
                    'MarkerFaceColor','w',...
                    'MarkerSize',5);
            end
        end
        file_name = sprintf('%s-%s-%s-%s-%s.mat', company, num2str(lambda), num2str(scale), year_1, year_2);
        disp(file_name)
        
        
        
        if ~exist(pfile_name, 'file')
            save(pfile_name, 'P','K');
        end
        save(file_name, 'maxes', 'R', 'X', 'date');
    end
end
