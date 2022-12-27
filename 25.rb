d='=-012';n=$<.sum{|t|t.chop.chars.reduce(0){_1*5+d.index(_2)-2}}
s='';while n>0;n+=2;s=d[n%5]+s;n/=5;end;$><<s
