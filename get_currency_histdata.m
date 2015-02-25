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

function [stock_data] = get_currency_histdata(stock, start_date, end_date)

%% Get stock historical data

%make URL
% http://www.google.com/finance/historical?q=EUR&histperiod=daily&startdate=01+jan,+2010&enddate=31+dec,+2011&output=csv
% http://www.google.com/finance/historical?cid=64295284217774&startdate=Feb+2%2C+2014&enddate=Feb+28%2C+2015&num=30&ei=5eXtVPDXHNSFuQTQ0oHYDA&output=csv
% http://www.google.com/finance/historical?cid=64295284217774&startdate=Feb+2%2C+2013&enddate=Feb+28%2C+2015&output=csv
%companies = {'EUR','KRW','JPY','CNY'};
%currency.('EUR') = '2460771';
%currency.('KRW') = '64295284217774';
%currency.('JPY') = '1'
%currency.('CNY') = '3215025';

% 'http://www.google.com/finance/historical?cid=?&startdate=01+jan,+2010&enddate=31+dec,+2011&output=csv'
%'http://www.google.com/finance/historical?cid=2460771&startdate=01+jan,+2010&enddate=31+dec,+2011&output=csv'
% http://www.oanda.com/lang/ko/currency/historical-rates/download?quote_currency=EUR&end_date=2015-2-25&start_date=2010-1-8&period=daily&display=absolute&rate=0&data_range=c&price=bid&view=graph&base_currency_0=USD&download=csv
url=['http://www.oanda.com/lang/en/currency/historical-rates/download?quote_currency=USD&start_date=' start_date '&end_date=' end_date '&period=daily&display=absolute&rate=0&data_range=c&price=bid&view=graph&base_currency_0=' stock '&download=csv']; 

%get data
[gfdata, gfstatus] = urlread(url);

if gfstatus
    % organize data by using the comma delimiter
    %scandata = textscan(strrep(gfdata(110:end-111),'"',''),'%s%s%s%s%s%s','delimiter',',');
    scandata = textscan(gfdata(110:end-123),'%s%s%s%s%s%s','delimiter','"');

    stock_data.date = scandata{2};
    stock_data.open = str2double(scandata{4});
   
else
    error('Unable to retrieve data from Google Finance');
end
