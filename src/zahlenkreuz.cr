def powerset(items)
  (0...2**items.size).map { |bits|
    items.each_with_index.select { |(e, i)|
      bits & (1 << i) != 0
    }.map { |(e, i)| e }.to_a
  }
end

class InconclusiveException < Exception; end

class ContradictionException < Exception; end

class Zahlenkreuz
  alias Cell = Tuple(UInt32, UInt32)

  @cells_left : UInt32
  @cell_width : UInt32
  @left_width : UInt32
  @vals : Array(Array(Int32))

  def initialize(@cols : Array(Int32), @rows : Array(Int32), @vals = Array(Array(Int32)), @verbose : Bool = false)
    @states = Array(Array(Bool?)).new(@rows.size) { Array(Bool?).new(@cols.size, nil) }
    @change = Array(Array(Bool)).new(@rows.size) { Array(Bool).new(@cols.size, false) }
    @cell_width = @cols.map { |c| c ? c.to_s.size : 1 }.max.to_u32
    @left_width = @rows.map { |c| c ? c.to_s.size : 1 }.max.to_u32
    @cells_left = (@cols.size * @rows.size).to_u32
  end

  def solve(may_guess : Bool = true)
    until @cells_left == 0
      cols = infer(@cols, "Col", ->(n : UInt32) { @states.map { |s| s[n] } }, ->(mine : UInt32, theirs : UInt32) { {theirs, mine} })
      rows = infer(@rows, "Row", ->(n : UInt32) { @states[n] }, ->(mine : UInt32, theirs : UInt32) { {mine, theirs} })
      if !cols && !rows
        if may_guess
          choices = [] of Tuple(Cell, Bool)
          nils = {} of Cell => Int32

          @states.each_with_index { |row, y|
            y = y.to_u32
            row.each_with_index { |state, x|
              x = x.to_u32
              next unless state.nil?
              [true, false].each { |guess|
                begin
                  guess_state = make_guess { @states[y][x] = guess }
                  nils[{y, x}] = guess_state.map(&.count(nil)).sum
                rescue e : ContradictionException
                  choices << { {y, x}, !guess }
                end
              }
            }
          }

          if @verbose
            current_nils = @states.map(&.count(nil)).sum
            choices.each { |(coord, guess)|
              puts "#{coord} -> #{!guess} causes contradiction. #{guess} reveals #{current_nils - nils[coord]} / #{current_nils} cells."
            }
            puts "#{choices.size} / #{@states.map(&.count(nil)).sum} cells cause contradictions."
          end

          most_useful = choices.min_by { |(coord, _)| nils[coord] }
          self[most_useful[0]] = most_useful[1]

          if @verbose
            puts self.to_s
            # Don't need to bother clearing change if not verbose.
            @change.each { |c| c.fill(false) }
          end
        else
          raise InconclusiveException.new
        end
      end
    end

    @states.map(&.dup).to_a
  end

  def to_s
    header = (" " * (@left_width + 1)) + @cols.map { |c| "%#{@cell_width}s" % (c || '-') }.join(" ")
    header + "\n" + @rows.zip(@states).map_with_index { |(n, row), y|
      ("%#{@left_width}s " % (n || '-')) + row.map_with_index { |c, x|
        colour =
          case c
          when true ; 32
          when false; 31
          else        0
          end
        "\e[#{@change[y][x] ? 1 : 0};#{colour}m#{"%#{@cell_width}s" % @vals[y][x]}\e[0m"
      }.join(" ")
    }.join("\n")
  end

  private def make_guess
    was_verbose = @verbose
    @verbose = false
    cells_left = @cells_left

    # It's important we replace @states with a new array
    # (rather than simply save it, let it be overwritten,
    # and then restore it)
    # since solve is iterating over it.
    save_state = @states
    @states = @states.map(&.dup)

    begin
      yield
      solve(may_guess: false)
      @states.map(&.dup)
    rescue e : InconclusiveException
      # On an inconclusive, give the resulting state.
      # On a conflict, let the caller handle it.
      @states.map(&.dup)
    ensure
      @states = save_state
      @cells_left = cells_left
      @verbose = was_verbose
    end
  end

  private def infer(group : Array(Int32), name : String, states : UInt32 -> Array(Bool?), coord : UInt32, UInt32 -> Cell) : Bool
    group.map_with_index { |n, my_index|
      my_index = my_index.to_u32
      my_states = states.call(my_index)

      target = n
      candidates = [] of Tuple(Int32, UInt32)
      my_states.each_with_index { |cs, i|
        i = i.to_u32
        c = coord.call(my_index, i)
        val = @vals[c[0]][c[1]]
        candidates << {val, i} if cs.nil?
        target -= val if cs
      }

      possible = powerset(candidates).select { |p| p.map { |x| x[0] }.sum == target }
      in_every = possible.reduce(candidates) { |a, b| a & b }
      in_none = candidates - possible.reduce([] of Tuple(Int32, UInt32)) { |a, b| a | b }

      next false if in_every.empty? && in_none.empty?

      puts "#{name} #{my_index} (#{n}): possible (#{possible.size}) #{possible}. In every: #{in_every}, in none: #{in_none}" if @verbose

      in_every.each { |x| self[coord.call(my_index, x[1])] = true }
      in_none.each { |x| self[coord.call(my_index, x[1])] = false }

      if @verbose
        puts self.to_s
        # Don't need to bother clearing change if not verbose.
        @change.each { |c| c.fill(false) }
      end

      true
    }.any?
  end

  private def []=(c : Cell, v : Bool)
    y, x = c
    current_value = @states[y][x]
    if current_value.nil?
      @cells_left -= 1
      @change[y][x] = true
    elsif v != current_value
      raise ContradictionException.new("#{v} conflicts with #{current_value} at #{y}, #{x}")
    end
    @states[y][x] = v
  end
end
