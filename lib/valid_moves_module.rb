
module Valid_moves
  DEBUG = true
  @targets = {} # Hash for all possible moves
  @positions = nil

  def self.valid(positions)
    Array(positions).select do |r, c|
      (0...8).include?(r) && (0...8).include?(c)
    end
  end

  def self.targets
    @targets
  end

  def self.valid_moves(figure_class, current_cords)
    if figure_class == King_white || figure_class == King_black
      return @targets["king"][current_cords]
    elsif figure_class == Rook_white || figure_class == Rook_black
      return @targets["rook"][current_cords]
    elsif figure_class == Bishop_white || figure_class == Bishop_black
      return @targets["bishop"][current_cords]
    elsif figure_class == Queen_white || figure_class == Queen_black
      return @targets["queen"][current_cords]
    elsif figure_class == Knight_white || figure_class == Knight_black
      return @targets["knight"][current_cords]
    elsif figure_class == Pawn_white
      p "entered pawn white" if DEBUG
      return @targets["wpawn"][current_cords]
    elsif figure_class == Pawn_black
      return @targets["bpawn"][current_cords]
    else
      p "else in valid moves" if DEBUG
    []
    end
  end

  def self.valid_takes(figure_class, current_cords)
    if figure_class == Pawn_white
      return @targets["wptake"][current_cords]
    elsif figure_class == Pawn_black
      return @targets["bptake"][current_cords]
    else
      return Valid_moves.valid_moves(figure_class, current_cords)
    end
  end

  def self.valid_castle(figure_class, current_cords)
    if figure_class == King_white
      return @targets["wcastle"][current_cords]
    elsif figure_class == King_black
      return @targets["bcastle"][current_cords]
    end
  end

  def self.los(current, target, board) 
    path = []
    ["up","down","left","right","upleft","upright","downleft","downright"].each do |direction|
      temp_path = @targets[direction][current] || []
      if temp_path.include?(target) #geting path between current and target checks for direction
        index = temp_path.index(target)
        path = temp_path[0...index]
        break
      end
    end
    path.all? { |cords| board.grid[cords[0]][cords[1]].figure.nil? } # true, if all free 
  end
  

  def self.build_targets
    @positions = (0...8).flat_map { |r| (0...8).map { |c| [r, c] } }
    @targets = {}
    #generating hashes for all directions
  @targets["up"] = @positions.to_h do |r, c|
    [[r, c], valid((1...8).map { |v| [r + v, c] })]
  end

  @targets["down"] = @positions.to_h do |r, c|
    [[r, c], valid((1...8).map { |v| [r - v, c] })]
  end

  @targets["vertical"] = @positions.to_h do |r, c|
    [[r, c], @targets["up"][[r, c]] + @targets["down"][[r, c]]]
  end

  @targets["left"] = @positions.to_h do |r, c|
    [[r, c], valid((1...8).map { |h| [r, c - h] })]
  end

  @targets["right"] = @positions.to_h do |r, c|
    [[r, c], valid((1...8).map { |h| [r, c + h] })]
  end

  @targets["horizontal"] = @positions.to_h do |r, c|
    [[r, c], @targets["left"][[r, c]] + @targets["right"][[r, c]]]
  end

  @targets["upleft"] = @positions.to_h do |r, c|
    up    = @targets["up"][[r, c]]
    left  = @targets["left"][[r, c]]
    [[r, c], up.zip(left).map { |(ru, _), (_, cl)| [ru, cl] }]
  end

  @targets["upright"] = @positions.to_h do |r, c|
    up     = @targets["up"][[r, c]]
    right  = @targets["right"][[r, c]]
    [[r, c], up.zip(right).map { |(ru, _), (_, cr)| [ru, cr] }]
  end

  @targets["downleft"] = @positions.to_h do |r, c|
    down  = @targets["down"][[r, c]]
    left  = @targets["left"][[r, c]]
    [[r, c], down.zip(left).map { |(rd, _), (_, cl)| [rd, cl] }]
  end

  @targets["downright"] = @positions.to_h do |r, c|
    down  = @targets["down"][[r, c]]
    right = @targets["right"][[r, c]]
    [[r, c], down.zip(right).map { |(rd, _), (_, cr)| [rd, cr] }]
  end

  @targets["diagUL"] = @positions.to_h do |r, c|
    [[r, c], @targets["upleft"][[r, c]] + @targets["downright"][[r, c]]]
  end

  @targets["diagDL"] = @positions.to_h do |r, c|
    [[r, c], @targets["downleft"][[r, c]] + @targets["upright"][[r, c]]]
  end

  ### Legal moves for each Figure ###
  
  @targets["king"] = @positions.to_h do |r, c|
    deltas = [-1, 0, 1].product([-1, 0, 1]) - [[0, 0]]
    moves  = deltas.map { |v, h| [r + v, c + h] }
    [[r, c], valid(moves)]
  end


  @targets["rook"] = @positions.to_h do |r, c|
    [[r, c], @targets["horizontal"][[r, c]] + @targets["vertical"][[r, c]]]
  end


  @targets["bishop"] = @positions.to_h do |r, c|
    [[r, c], @targets["diagUL"][[r, c]] + @targets["diagDL"][[r, c]]]
  end


  @targets["queen"] = @positions.to_h do |r, c|
    [[r, c], @targets["rook"][[r, c]] + @targets["bishop"][[r, c]]]
  end


  @targets["knight"] = @positions.to_h do |r, c|
    jumps = [[2,1],[2,-1],[1,2],[1,-2],[-2,1],[-2,-1],[-1,2],[-1,-2]]
    moves = jumps.map { |v, h| [r + v, c + h] }
    [[r, c], valid(moves)]
  end

  #white pawn can move 1 down unless hes on row 1 then he can move 2 down
  @targets["wpawn"] = @positions.to_h do |r, c|
    moves = []
    moves << [r + 1, c] if r > 0
    moves << [r + 2, c] if r == 1
    [[r, c], valid(moves)]
  end

  #black pawn can move 1 up unless hes on row 6 then he can move 2 up
  @targets["bpawn"] = @positions.to_h do |r, c|
    moves = []
    moves << [r - 1, c] if r < 7
    moves << [r - 2, c] if r == 6
    [[r, c], valid(moves)]
  end

  #white pawn take
  @targets["wptake"] = @positions.to_h do |r, c|
    moves = [[r + 1, c + 1], [r + 1, c - 1]] if r > 0
    [[r, c], valid(moves || [])]
  end

  #black pawn take
  @targets["bptake"] = @positions.to_h do |r, c|
    moves = [[r - 1, c + 1], [r - 1, c - 1]] if r < 7
    [[r, c], valid(moves || [])]
  end

  #castle white
  @targets["wcastle"] = Hash.new { |h, k| h[k] = [] }.merge({
    [0, 4] => [[0, 2], [0, 6]]
  })

  #castle black
  @targets["bcastle"] = Hash.new { |h, k| h[k] = [] }.merge({
    [7, 4] => [[7, 2], [7, 6]]
  })
  end
  
end