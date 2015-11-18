require_relative 'cell'
require 'pry'

class Minefield
  attr_reader :row_count, :column_count, :grid

  def initialize(row_count, column_count, mine_count)
    @column_count = column_count
    @row_count = row_count
    @grid = initialize_grid(mine_count)
  end

  def initialize_grid(mine_count)
    temp_grid = Array.new(@row_count){Array.new(@column_count).map {Cell.new}}
    array_fill = []
    while array_fill.length < mine_count
      array_fill << [rand(@row_count), rand(column_count)]
      array_fill.uniq!
    end
    array_fill.each { |row_col| temp_grid[row_col[0]][row_col[1]].fill = "mine" }
    temp_grid
  end


  # Return true if the cell been uncovered, false otherwise.
  def cell_cleared?(row, col)
    @grid[row][col].uncovered
  end

  # Uncover the given cell. If there are no adjacent mines to this cell
  # it should also clear any adjacent cells as well. This is the action
  # when the player clicks on the cell.
  def clear(row, col)
    unless cell_cleared?(row,col)
      @grid[row][col].uncovered = true
      if adjacent_mines(row,col) == 0
        clear(row, col+1) if col < @column_count-1
        clear(row, col-1) if col > 0
        clear(row+1, col) if row < @row_count-1
        clear(row-1, col) if row > 0
        clear(row+1, col+1) if row < @row_count-1 && col < @column_count-1
        clear(row-1, col-1) if row > 0 && col > 0
        clear(row-1, col+1) if row > 0 && col < @column_count-1
        clear(row+1, col-1) if row < @row_count-1 && col > 0
      end
    end
  end

  # Check if any cells have been uncovered that also contained a mine. This is
  # the condition used to see if the player has lost the game.
  def any_mines_detonated?
    flag = false
    @grid.each do |row|
      flag = true if row.any? { |cell | cell.uncovered == true && !cell.fill.nil? }
    end
    flag
  end

  # Check if all cells that don't have mines have been uncovered. This is the
  # condition used to see if the player has won the game.
  def all_cells_cleared?
    flag = true
    @grid.each do |row|
      flag = false if row.any? { |cell| cell.uncovered == false && cell.fill.nil? }
    end
    flag
  end

  # Returns the number of mines that are surrounding this cell (maximum of 8).
  def adjacent_mines(row, col)
    count = 0
    if col < @column_count-1
      count+=1 unless @grid[row][col+1].fill.nil?
    end
    if col > 0
      count +=1 unless @grid[row][col-1].fill.nil?
    end
    if row < @row_count-1
      count+=1 unless @grid[row+1][col].fill.nil?
    end
    if row > 0
      count+=1 unless @grid[row-1][col].fill.nil?
    end
    if row < @row_count-1 && col < @column_count-1
      count+=1  unless @grid[row+1][col+1].fill.nil?
    end
    if row > 0 && col > 0
      count+=1 unless @grid[row-1][col-1].fill.nil?
    end
    if row > 0 && col < @column_count-1
      count +=1 unless @grid[row-1][col+1].fill.nil?
    end
    if row < @row_count-1 && col > 0
      count +=1 unless @grid[row+1][col-1].fill.nil?
    end
    count
  end

  # Returns true if the given cell contains a mine, false otherwise.
  def contains_mine?(row, col)
    @grid[row][col].fill == "mine"
  end
end
