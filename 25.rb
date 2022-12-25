n=$<.sum{|t|t.chop.chars.reduce(0){_1*5+'=-012'.index(_2)-2}}
s='';while n>0;r=n%5;n=n/5+(r>2?1:0);s=r.to_s+s;end;puts s.tr'34','=-'
