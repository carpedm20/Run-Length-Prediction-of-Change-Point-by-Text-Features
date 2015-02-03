% function [stock_data] = get_gf_histdata(stock,varargin)
%
% Description: This function gets the historical data of a stock from the
% Google Finance nice website.
%
% Usage:   [stock_data] = get_gf_histdata(stock,varargin);
%           stock       = string containing the market and the stock symbol together:
%                         For example:'NASDAQ:GOOG' or 'NYSE:GE'.
%           varargin    = 'start', startdate with format 29-Sep-2009 or 29/Sep/2009 (dafault is 1 year ago)
%                       = 'end', enddate of format 29-Sep-2009 or 29/Sep/2009(default is today)
%                       = 'weekly'/'daily' (default='daily')
%                       = 'format', 'standard', 'ts', 'hist_stock_data',
%                         use standard format, financial time series format or as in hist_stock_data from Josiah Renfree.
%
% History:  29-Sep-09: Created by Alejandro Arrizabalaga (Matlab 2008 version)

function [stock_data] = get_gf_histdata(stock,varargin)

%% Defaults
period='daily';
hist_stock_data=0;
fts=0;
enddate=[datestr(today,3) '+' datestr(today,7) '%2C+' datestr(today,10)];
startdate=[datestr(today,3) '+' datestr(today,7) '%2C+' num2str(str2num(datestr(today,10))-1)];

%% Process arguments
if nargin < 1
    error('No stock symbol provided, please provide one');
else
    if ~isstr(stock)
            error('No valid stock symbol provided, please provide one (string)');
    end
end

iarg = 0;
while (iarg<nargin-1)
    iarg = iarg +1;
    arg  = varargin{iarg};
    if isstr(arg)
        switch arg
            case 'daily'
                period='daily'
            case 'weekly'
                period='weekly'
            case 'start'
                iarg = iarg + 1;
                if(iarg>nargin-1)
                    error('no start date supplied');
                else
                    ipar = varargin{iarg};
                    if (isstr(ipar))
                        startstr=strrep(ipar,'/','-');
                        startdate=[startstr(1:2) '+' startstr(4:6) ',+' startstr(8:11)];
                    else
                        error('no valid start date supplied (use a string)');
                    end;
                end;
            case 'end'
                iarg = iarg + 1;
                if(iarg>nargin-1)
                    error('no end date supplied');
                else
                    ipar = varargin{iarg};
                    if (isstr(ipar))
                        endstr=strrep(ipar,'/','-');
                        enddate=[startstr(1:2) '+' startstr(4:6) ',+' startstr(8:11)];
                    else
                        error('no valid end date supplied (use a string)');
                    end;
                end;
            case 'format'
                iarg = iarg + 1;
                if(iarg>nargin-1)
                    error('no format supplied');
                else
                    ipar = varargin{iarg};
                    if (isstr(ipar))
                        if strcmp(ipar,'ts')
                            fts=1;
                        elseif strcmp(ipar,'hist_stock_data')
                            hist_stock_data=1;  
                        elseif strcmp(ipar,'standard')
                        else
                                                    error('no valid format supplied (use a string)');
                        end
                    else
                        error('no valid format supplied (use a string)');
                    end;
                end;
            otherwise
                error('no valid argument supplied. Type ''help get_gf_histdata'' for info.');
        end
    end
end

%% Get stock historical data

%make URL
url=['http://www.google.com/finance/historical?q=' stock '&histperiod' period '&startdate=' startdate '&enddate' enddate '&output=csv']; 

%get data
[gfdata, gfstatus] = urlread(url);

if gfstatus
    % organize data by using the comma delimiter
    scandata = textscan(gfdata(34:end),'%s%s%s%s%s%s','delimiter',',');

    stock_data.date = scandata{1};
    stock_data.open = str2double(scandata{2});
    stock_data.high =  str2double(scandata{3});
    stock_data.low =  str2double(scandata{4});
    stock_data.close = str2double(scandata{5});
    stock_data.volume =  str2double(scandata{6});
   
    if hist_stock_data
        stock_data_old=stock_data;
        clear stock_data;
        for idx=1:length(stock_data_old.date)
            stock_data(idx).Ticker = stock;
            stock_data(idx).Open = stock_data_old.date(idx);
            stock_data(idx).High = stock_data_old.high(idx);
            stock_data(idx).Low = stock_data_old.low(idx);
            stock_data(idx).Close = stock_data_old.close(idx);
            stock_data(idx).Volume = stock_data_old.volume(idx);
        end
    elseif fts
        stock_data=fints(datenum(stock_data.date),[stock_data.open stock_data.high stock_data.low stock_data.close stock_data.volume],{'OPEN' 'HIGH' 'LOW' 'CLOSE' 'VOLUME'},period);    
     end
else
    error('Unable to retrieve data from Google Finance');
end
