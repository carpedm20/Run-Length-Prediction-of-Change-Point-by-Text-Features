function p = textfrequncy(company, year)
%
% p = studentpdf(x, mu, var, nu)
%
    BASE = './data/';
    
    files = dir(sprintf('%s%s-%s*-bow.json', BASE, company, year));
    for idx = 1:length(files)
        articles = loadjson(sprintf('%s%s', BASE, files(idx).name));
        
        for idx=1:2
            article = articles{1,idx};
            
            text = article.text;
            freq_unique_data = countmember(unique(text),text);
        end
    end
    data=loadjson('example1.json')