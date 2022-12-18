d=$<.map{_1.split(?,).map(&:to_i)}
p 6*d.size-2*d.combination(2).count{|a,b|a.zip(b).sum{(_2-_1).abs}==1}

