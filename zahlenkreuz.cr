require "./src/zahlenkreuz"

if ARGV.size == 1
  lines = File.read_lines(ARGV.first)

  cols = lines[1].split.map(&.to_i)
  rows = lines[3].split.map(&.to_i)
  board = lines[5...(5 + rows.size)].map(&.split.map(&.to_i))
else
  # ARGV size will be n^2 + 2n.
  n = (((4 + 4 * ARGV.size) ** 0.5 - 2) / 2).to_i

  cols = ARGV[0...n].map(&.to_i)
  rows = ARGV[n...(2 * n)].map(&.to_i)
  board = ARGV[(2 * n)..-1].map(&.to_i).each_slice(n).to_a
end

Zahlenkreuz.new(cols, rows, board, verbose: true).solve
