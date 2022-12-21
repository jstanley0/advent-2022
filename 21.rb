Exp = Struct.new(:l, :op, :r)

vars = {}
ARGF.map do |line|
  var, exp = line.split(': ')
  exp = exp.split
  vars[var] = if exp.size == 1
    exp.first.to_i
  else
    Exp.new(exp[0], exp[1].to_sym, exp[2])
  end
end

def evaluate(vars, var)
  v = vars[var]
  if v.is_a?(Numeric)
    v
  else
    l = evaluate(vars, v.l)
    r = evaluate(vars, v.r)
    l.method(v.op).call(r)
  end
end

p evaluate(vars, 'root')

def symbolic_evaluate(vars, var)
  return var if var == 'humn'

  v = vars[var]
  if v.is_a?(Numeric)
    v
  else
    l = symbolic_evaluate(vars, v.l)
    r = symbolic_evaluate(vars, v.r)
    if l.is_a?(Numeric) && r.is_a?(Numeric)
      l.method(v.op).call(r)
    else
      Exp.new(l, v.op, r)
    end
  end
end

exp = vars['root']
l = symbolic_evaluate(vars, exp.l)
r = symbolic_evaluate(vars, exp.r)
l, r = r, l unless r.is_a?(Numeric)

until l == 'humn'
  if l.l.is_a?(Numeric)
    r = case l.op
    when :+
      # 3 + (...) = r => (...) = r - 3
      r - l.l
    when :-
      # 3 - (...) = r => -(...) = r + 3 => (...) = -(r + 3) = 3 - r
      l.l - r
    when :*
      # 3 * (...) = r => (...) = r / 3
      r / l.l
    when :/
      # 3 / (...) = r => 3 = (...) * r => (...) = 3 / r
      l.l / r
    end
    l = l.r
  elsif l.r.is_a?(Numeric)
    r = case l.op
    when :+
      # (...) + 3 = r => (...) = r - 3
      r - l.r
    when :-
      # (...) - 3 = r => (...) = r + 3
      r + l.r
    when :*
      # (...) * 3 = r => (...) = r / 3
      r / l.r
    when :/
      # (...) / 3 = r => (...) = r * 3
      r * l.r
    end
    l = l.l
  end
end

puts r
