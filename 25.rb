n=$<.sum{_1.chop.chars.reduce(0){|m,c|m*5+'=-012'.index(c)-2}}
s='';while n>0;r=n%5;n=n/5+(r>2?1:0);s=r.to_s.tr('34','=-')+s;end;$><<s
