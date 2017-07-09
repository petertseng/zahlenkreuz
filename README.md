# Zahlenkreuz

[![Build Status](https://travis-ci.org/petertseng/zahlenkreuz.svg?branch=master)](https://travis-ci.org/petertseng/zahlenkreuz)

A simple Zahlenkreuz solver.

Just iterates all columns/rows looking for subsets.

I got tired of doing these by hand.

A good source of Zahlenkreuz puzzles is http://www.janko.at/Raetsel/Zahlenkreuz.

# Usage

`zahlenkreuz.cr` assumes the board is square (this assumption is not present in the code) and takes the first N of ARGV as the column sums, the second N of ARGV as the row sums, and the rest of ARGV as the board, row by row.

```
$ crystal build --release zahlenkreuz.cr
$ ./zahlenkreuz 16 11 13 9 10 18 6 15 4 5 7 6 5 7 8 3 5 6 1 1 7 4 4 6
Col 0 (16): possible (2) [[{4, 0}, {5, 1}, {7, 3}], [{4, 0}, {5, 2}, {7, 3}]]. In every: [{4, 0}, {7, 3}], in none: []
   16 11 13  9
10  4  5  7  6
18  5  7  8  3
 6  5  6  1  1
15  7  4  4  6
Col 2 (13): possible (1) [[{8, 1}, {1, 2}, {4, 3}]]. In every: [{8, 1}, {1, 2}, {4, 3}], in none: [{7, 0}]
   16 11 13  9
10  4  5  7  6
18  5  7  8  3
 6  5  6  1  1
15  7  4  4  6
Col 3 (9): possible (2) [[{6, 0}, {3, 1}], [{3, 1}, {6, 3}]]. In every: [{3, 1}], in none: [{1, 2}]
   16 11 13  9
10  4  5  7  6
18  5  7  8  3
 6  5  6  1  1
15  7  4  4  6
Row 0 (10): possible (1) [[{6, 3}]]. In every: [{6, 3}], in none: [{5, 1}]
   16 11 13  9
10  4  5  7  6
18  5  7  8  3
 6  5  6  1  1
15  7  4  4  6
Row 1 (18): possible (1) [[{7, 1}]]. In every: [{7, 1}], in none: [{5, 0}]
   16 11 13  9
10  4  5  7  6
18  5  7  8  3
 6  5  6  1  1
15  7  4  4  6
Row 2 (6): possible (1) [[{5, 0}]]. In every: [{5, 0}], in none: [{6, 1}]
   16 11 13  9
10  4  5  7  6
18  5  7  8  3
 6  5  6  1  1
15  7  4  4  6
Row 3 (15): possible (1) [[{4, 1}]]. In every: [{4, 1}], in none: [{6, 3}]
   16 11 13  9
10  4  5  7  6
18  5  7  8  3
 6  5  6  1  1
15  7  4  4  6
```

# Future directions

* Instead of scanning all rows + all columns each time, only scan where anything changed in the last pass (is speedup worth the extra code?).
* Allow non-square boards in ARGV (the code probably already allows it).
