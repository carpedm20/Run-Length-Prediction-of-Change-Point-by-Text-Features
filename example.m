function example


table.idTableBy.plaintextInFirstTD = 'Day';
htmlTableToCell('example.html',table)
%htmlTableToCell('http://www.boxofficemojo.com/movies/?page=daily&view=chart&id=inception.htm','Day')

table.idTableBy.plaintextInFirstTD = 'Trondheim';
htmlTableToCell('example.html',table)

clear table;
%table.idTableBy.plaintextInFirstTD = 'Norway';
%htmlTableToCell('example.html',table)


