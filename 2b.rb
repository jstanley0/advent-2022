SHAPE = {
  'A' => {'X'=>3,'Y'=>1,'Z'=>2},
  'B' => {'X'=>1,'Y'=>2,'Z'=>3},
  'C' => {'X'=>2,'Y'=>3,'Z'=>1}
}

p ARGF.map { |line|
  play, outcome = line.split
  SHAPE[play][outcome] + 3 * (outcome.ord - 'X'.ord)
}.sum
