require "spec"
require "../src/zahlenkreuz"

CASES = [
  {
    [29, 22, 15, 17, 26, 22, 17],
    [25, 24, 33, 23, 11, 20, 12],
    [
      [9, 6, 4, 1, 8, 3, 6],
      [9, 1, 1, 8, 8, 8, 6],
      [9, 9, 9, 5, 4, 5, 6],
      [6, 5, 1, 3, 2, 8, 4],
      [2, 4, 8, 5, 6, 2, 6],
      [5, 1, 6, 7, 3, 4, 1],
      [6, 2, 3, 9, 3, 9, 4],
    ],
    [
      [true, false, true, true, true, true, false],
      [false, true, true, true, true, false, true],
      [true, true, false, false, true, true, true],
      [true, true, true, true, false, true, false],
      [false, true, false, true, false, true, false],
      [true, true, true, false, true, true, true],
      [false, true, true, false, true, false, true],
    ],
  },
]

describe Zahlenkreuz do
  CASES.each { |cols, rows, values, expected|
    it "#{cols}, #{rows}" do
      Zahlenkreuz.new(cols, rows, values).solve.should eq (expected)
    end
  }
end
