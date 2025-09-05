require_relative "board"
require_relative "valid_moves"
require_relative "config"
require_relative "check"

module Ai
  DEBUG = false
  FIGURE_VALUES = {
    pawn:   100,
    knight: 300,
    bishop: 300,
    rook:   500,
    queen:  900,
    king:     0
  }.freeze

  # ---------------------------
  # Public API
  # ---------------------------

  # color: "white" | "black"
  def self.best_move(board, color = "black", depth: 3, time_limit_ms: nil)
    alpha      = -Float::INFINITY
    beta       =  Float::INFINITY
    start_time = now_ms

    moves = generate_legal_moves(board, color)
    return nil if moves.nil? || moves.empty?

    moves = order_moves(moves)

    best       = nil
    best_score = (color == "white" ? -Float::INFINITY : Float::INFINITY)
    next_side  = opposite(color)

    moves.each do |m|
      undo = board.move_simulation(m[:figure], to_rc(m[:to]))
      score = alphabeta(board, depth - 1, alpha, beta, next_side, time_limit_ms, start_time)
      board.undo_simulation(undo)

      if color == "white"
        if score > best_score
          best_score = score
          best = m
        end
        alpha = [alpha, best_score].max  # Root-α monoton
      else
        if score < best_score
          best_score = score
          best = m
        end
        beta  = [beta,  best_score].min  # Root-β monoton
      end

      break if alpha >= beta
    end

    best
  end

  def self.make_move!(board, move)
    fig         = move[:figure]
    from_r,from_c = to_rc(move[:from])
    to_r, to_c  = to_rc(move[:to])
    to_tile     = board.grid[to_r][to_c]

    # ---- echten Zug ausführen (wie im UI) ----
    if fig.is_a?(King) && Valid_moves.valid_castle(fig.class, fig.current_tile.cords).include?([to_r, to_c])
      if defined?(Game_states) && Game_states.respond_to?(:perform_castling)
        Game_states.perform_castling(fig, [to_r, to_c], board)
      else
        fig.move(to_tile, board)
      end
    else
      if !to_tile.empty?
        fig.take(to_tile, board)
      else
        fig.move(to_tile, board)
      end
    end

    # ---- EP-Housekeeping (zuerst ALLES weg, dann ggf. neuen Clone setzen) ----
    # Wichtig: Jetzt erst löschen, damit eine evtl. gerade ausgeführte EP-Capture
    # die alten Marker noch nutzen konnte.
    board.grid.each do |row|
      row.each do |tile|
        tile.en_passant_clone = false if tile.respond_to?(:en_passant_clone=)
        tile.en_passant_color = nil   if tile.respond_to?(:en_passant_color=)
      end
    end
    board.figures.each do |f|
      f.en_passant = false if f.is_a?(Pawn) && f.respond_to?(:en_passant=)
    end

    # Doppelzug? -> neuen Clone/Flag setzen
    if fig.is_a?(Pawn) && (to_r - from_r).abs == 2
      fig.en_passant = true if fig.respond_to?(:en_passant=)
      mid_r = (from_r + to_r) / 2
      mid_c = to_c
      mid_tile = board.grid[mid_r][mid_c]
      mid_tile.en_passant_clone = true if mid_tile.respond_to?(:en_passant_clone=)
      if mid_tile.respond_to?(:en_passant_color=)
        mid_tile.en_passant_color = (fig.color == "white" ? "black" : "white")
      end
    end

    move
  end


  # ---------------------------
  # Search
  # ---------------------------

  def self.alphabeta(board, depth, alpha, beta, side_to_move, time_limit_ms, start_time)
    if time_limit_ms && (now_ms - start_time) >= time_limit_ms
      return evaluate(board)
    end

    term = terminal_score(board, side_to_move)
    return term unless term.nil?
    return evaluate(board) if depth <= 0

    moves = generate_legal_moves(board, side_to_move)
    return evaluate(board) if moves.nil? || moves.empty?

    moves = order_moves(moves)

    maximizing = (side_to_move == "white")
    next_side  = opposite(side_to_move)

    if maximizing
      value = -Float::INFINITY
      moves.each do |m|
        undo = board.move_simulation(m[:figure], to_rc(m[:to]))
        value = [value, alphabeta(board, depth - 1, alpha, beta, next_side, time_limit_ms, start_time)].max
        board.undo_simulation(undo)
        alpha = [alpha, value].max
        break if alpha >= beta
      end
      value
    else
      value =  Float::INFINITY
      moves.each do |m|
        undo = board.move_simulation(m[:figure], to_rc(m[:to]))
        value = [value, alphabeta(board, depth - 1, alpha, beta, next_side, time_limit_ms, start_time)].min
        board.undo_simulation(undo)
        beta = [beta, value].min
        break if alpha >= beta
      end
      value
    end
  end

  def self.terminal_score(board, side)
    moves = generate_legal_moves(board, side)
    if moves.nil? || moves.empty?
      if in_check?(board, side)
        # Seite am Zug ist matt -> aus White-Sicht schlecht, Black gut
        return (side == "white") ? -10_000 : 10_000
      else
        return 0 # Patt
      end
    end
    nil
  end

  # ---------------------------
  # Evaluation
  # ---------------------------

  def self.evaluate(board)
    material(board) + mobility(board) * 5
  end

  def self.material(board)
    sum = 0
    each_figure(board) do |fig|
      value = FIGURE_VALUES[figure_kind(fig)] || 0
      sum  += (fig.color == "white" ? value : -value)
    end
    sum
  end

  def self.mobility(board)
    (generate_legal_moves(board, "white").length rescue 0) -
    (generate_legal_moves(board, "black").length rescue 0)
  end

  # ---------------------------
  # Move generation (legal)
  # ---------------------------

  def self.generate_legal_moves(board, color)
    opp   = opposite(color)
    moves = []
    h = board.grid.length
    w = board.grid[0].length

    each_figure_with_cords(board) do |fig, from_rc|
      next unless fig.color == color
      from_rc = to_rc(from_rc)
      next if from_rc.nil?

      # --- Zielmengen holen (geometrisch) ---
      begin
        raw_takes = Valid_moves.valid_takes(fig.class, from_rc)
      rescue
        raw_takes = []
      end
      begin
        raw_nonc = Valid_moves.valid_moves(fig.class, from_rc)
      rescue
        raw_nonc = []
      end

      takes = Array(raw_takes).map { |t| to_rc(t) }.compact
      nonc  = Array(raw_nonc).map  { |t| to_rc(t) }.compact
      pseudo_targets = (takes + nonc).uniq

      pseudo_targets.each do |to_rc_|
        next if to_rc_.nil?
        to_r, to_c = to_rc_
        # Bounds-Check bevor wir grid indexieren
        next unless to_r.between?(0, h - 1) && to_c.between?(0, w - 1)

        tile     = board.grid[to_r][to_c]
        in_takes = takes.include?(to_rc_)
        in_nonc  = nonc.include?(to_rc_)

        # 1) Belegungsregeln
        next if in_nonc  && !tile.empty?
        next if in_takes && (tile.empty? || tile.figure.color == fig.color)

        # 2) LoS (Springer dürfen immer)
        los_ok = fig.is_a?(Knight) ? true : Valid_moves.los(from_rc, to_rc_, board)
        next unless los_ok

        # 3) Königssicherheit via Probesimulation
        undo  = board.move_simulation(fig, to_rc_)

        # WICHTIG: König nach dem Zug korrekt prüfen
        k_rc =
          if fig.is_a?(King)
            to_rc_                       # König steht nun auf dem Ziel
          else
            to_rc(board.public_send("#{color}_king_pos")) || to_rc(figures_king_pos_fallback(board, color))
          end

        legal = !Check.check?(k_rc, board, color)

        gives_check = false
        if legal
          opp_k_rc = to_rc(board.public_send("#{opp}_king_pos")) || to_rc(figures_king_pos_fallback(board, opp))
          gives_check = opp_k_rc ? Check.check?(opp_k_rc, board, opp) : false
        end

        board.undo_simulation(undo)
        next unless legal

        # 4) Metadaten
        promotion = fig.is_a?(Pawn) &&
                    ((color == "white" && to_r == 7) ||
                    (color == "black" && to_r == 0))

        captured_kind = (!tile.empty? && in_takes) ? figure_kind(tile.figure) : nil

        moves << {
          from: from_rc,
          to:   to_rc_,
          figure: fig,
          capture: !tile.empty? && in_takes,
          captured_kind: captured_kind,
          promotion: promotion,
          gives_check: gives_check
        }
      end
    end

    moves
  end



  # ---------------------------
  # Move ordering
  # ---------------------------

  def self.order_moves(moves)
    moves.sort_by { |m| -score_move(m) }
  end

  def self.score_move(m)
    score = 0

    if m[:capture]
      victim   = FIGURE_VALUES[m[:captured_kind]] || 0
      attacker = FIGURE_VALUES[figure_kind(m[:figure])] || 0
      score += 10_000 + victim - (attacker / 10.0)  # MVV-LVA-ähnlich
    end

    score += 8_000 if m[:promotion]
    score += 5_000 if m[:gives_check]

    # kleiner Bonus für Zentrumsfelder (r,c in 2..5)
    if m[:to].is_a?(Array)
      r, c = m[:to]
      score += 5 if r.between?(2,5) && c.between?(2,5)
    end

    score
  end

  # ---------------------------
  # Helpers
  # ---------------------------

  def self.in_check?(board, color)
    king_rc = to_rc(board.public_send("#{color}_king_pos"))
    return false if king_rc.nil?
    Check.check?(king_rc, board, color)
  end

  def self.now_ms
    (Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000).to_i
  end

  def self.each_figure(board)
    board.figures.each { |fig| yield fig }
  end

  def self.each_figure_with_cords(board)
    board.figures.each { |fig| yield fig, fig.current_tile.cords }
  end

  def self.figure_kind(fig)
    return :pawn   if fig.is_a?(Pawn)
    return :knight if fig.is_a?(Knight)
    return :bishop if fig.is_a?(Bishop)
    return :rook   if fig.is_a?(Rook)
    return :queen  if fig.is_a?(Queen)
    return :king   if fig.is_a?(King)
    :pawn
  end

  def self.opposite(color) = (color == "white" ? "black" : "white")

  def self.to_rc(pos)
    return nil if pos.nil?  # << neu: nil durchreichen

    if pos.is_a?(Array)
      return [pos[0], pos[1]] if pos.size >= 2 && pos[0].is_a?(Integer) && pos[1].is_a?(Integer)
      return to_rc(pos.first) # z. B. [tile, ...]
    end

    if pos.is_a?(Hash)        # {x:,y:} -> [row, col] = [y, x]
      x = pos[:x] || pos['x']
      y = pos[:y] || pos['y']
      return [y, x]
    end

    return to_rc(pos.cords)  if pos.respond_to?(:cords)
    return to_rc(pos.coords) if pos.respond_to?(:coords)

    if pos.respond_to?(:current_tile) && pos.current_tile
      return to_rc(pos.current_tile.cords) if pos.current_tile.respond_to?(:cords)
      if pos.current_tile.respond_to?(:x) && pos.current_tile.respond_to?(:y)
        return [pos.current_tile.y, pos.current_tile.x]
      end
    end

    if pos.respond_to?(:x) && pos.respond_to?(:y)
      return [pos.y, pos.x]
    end

    nil
  end
end
