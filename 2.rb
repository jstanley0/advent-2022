OUTCOME = {
  'A' => {'X'=>3,'Y'=>6,'Z'=>0},
  'B' => {'X'=>0,'Y'=>3,'Z'=>6},
  'C' => {'X'=>6,'Y'=>0,'Z'=>3}
}

p ARGF.map { |line|
  play, response = line.split
  (response.ord - 'X'.ord + 1) + OUTCOME[play][response]
}.sum
