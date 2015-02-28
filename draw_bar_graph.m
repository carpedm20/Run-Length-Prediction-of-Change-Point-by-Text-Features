clear;
clear plot;

aa = repmat([1 2 10 5 15 3], 5,1)

company = ['GOOGL','AAPL','FB','MSFT','IBM'];
company = ['EUR','KRW','JPY','CNY'];
company = ['KNIGHT','INCEPTION','AVENGERS','FROZEN'];

company = [1,2,3,4,5];
conc = [511.248861396,509.177365152,495.875340599,570.670352319,583.852845368];

temp=[7276,6592,5471,4787,5296;
      6988,6031,5534,5192,5714;
      8929,7716,6539,6861,8123;
      8705,8204,6938,6150,5908;
      9878,9844,9388,8887,7744;]
  
  
%temp = [8689,8118,7694,7947,8259;2830,4800,7508,8197,8184;2374,3752,5986,7468,7679;7578,7367,6318,6291,6285]
temp = [8836,8273,7856,7978,8394;2841,4847,7544,8264,8403;2385,3817,6024,7636,7816;7740,7469,6596,6357,6530]

temp = [8236+8638;
7922+9233;
    6476;
7915+7106;
7124+722;]

temp=[15041964,29422,511;
14999856,29459,509;
18926570,38168,495;
20489919,35905,570;
26706013,45741,583;
22556830,41337,545;
20955349,34692,604;
18555429,31899,581;
14392487,16874,852;
12100513,17155,705;
3483918,6476,537;
6826508,15021,454;
4223683,7846,538;]

hBar = bar(temp);
%ylabel('# of documents','FontSize',12) 
%str = {'GOOGL','AAPL','FB','MSFT','IBM'};
%str = {'EURO','YEN','YUAN','WON'};
%str = {'KNIGHT 2012-2013','INCEPTION','AVENGERS','FROZEN'};

%set(gca, 'XTickLabel',str, 'XTick',1:numel(str))

%set(gca, 'XTick', [1:5], 'XTickLabel', cell(5,1));
%text(1, -1500, {'KNIGHT', '2008-2009'}, 'FontSize', 8,'HorizontalAlignment', 'Center');
%text(2, -1500, {'INCEPTION', '2010-2011'}, 'FontSize', 8,'HorizontalAlignment', 'Center');
%text(3, -1500, {'AVENGERS', '2011-2012'}, 'FontSize', 8,'HorizontalAlignment', 'Center');
%text(4, -1500, {'FROZEN', '2012-2013'}, 'FontSize', 8,'HorizontalAlignment', 'Center');
%text(5, -1500, {'INTERSTELLAR', '2014-2015'}, 'FontSize', 8,'HorizontalAlignment', 'Center');
%set(gca,'YTickLabel',str2mat('5000','10000','15000','20000','25000'))

%hleg1 = legend('2010','2011','2012','2013','2014')
%set(hleg1, 'Location','SouthEast');
%tightfig;
%[ax,hBar,hLine] = plotyy(company,temp,company,conc,'bar','plot');
%set(get(ax(1),'Ylabel'),'String','# of documents','FontSize',12) 
%set(get(ax(2),'Ylabel'),'String','words/documents','FontSize',12)
%set(ax(1),'YLim',[0 360])
%set(ax(2),'YLim',[0 590])
%set(ax(2),'YTick',[0:100:590])
%set(hLine,'Marker','o')
%set(hLine,'LineStyle','-')
%set(hLine,'Color','black')
%set(hLine,'LineWidth',1.5)

%set(ax,'xticklabel',{'GOOGL','AAPL','FB','MSFT','IBM'});
%set(ax,'xticklabel',{'google','apple','facebook','microsoft','ibm'});


%bar(rand(10,1));
%set(gca, 'XTick', [1:10], 'XTickLabel', cell(10,1), 'YLim', [0 1]);
%text(1, -.05, {'Label # 1'}, 'FontSize', 8, 'HorizontalAlignment','Center');
%text(5, -.05, {'Label #5', 'has two lines'}, 'FontSize', 8,'HorizontalAlignment', 'Center');
