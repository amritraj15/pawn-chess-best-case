module Computer
  class HeuristicEvaluator
    WIN_SCORE = 100_000
    CAPTURE_SCORE = 300
    ADVANCE_SCORE = 20
    CENTER_SCORE = 15
    UNSAFE_CAPTURE_PENALTY = 500

    def initialize(board)
      @board = board
    end

    def score(move)
      score = 0

      score += WIN_SCORE if move.winning_move?
      score += CAPTURE_SCORE if move.capture?
      score += advancement_score(move)
      score += center_score(move)

      score -= UNSAFE_CAPTURE_PENALTY if unsafe_capture?(move)

      score
    end

    private

    def advancement_score(move)
      if move.pawn.color.to_sym == :black
        move.to_row * ADVANCE_SCORE
      else
        (7 - move.to_row) * ADVANCE_SCORE
      end
    end

    def center_score(move)
      case move.to_col
      when 3, 4
        CENTER_SCORE
      when 2, 5
        CENTER_SCORE / 2
      else
        0
      end
    end

    def unsafe_capture?(move)
      return false unless move.capture?

      clone = @board.deep_clone

      validator = MoveValidator.new(clone)

      cloned_move = move.clone_for(clone)

      validator.execute(cloned_move)

      enemy =
        move.pawn.color.to_sym == :white ? :black : :white

      validator.valid_moves_for_color(enemy).any? do |enemy_move|
        enemy_move.capture? &&
          enemy_move.to_row == cloned_move.to_row &&
          enemy_move.to_col == cloned_move.to_col
      end
    end

    def board_score(color)
      own = @board.pawns(color)

      enemy = @board.pawns(opponent(color))

      score = 0

      own.each do |pawn|
        score += 100

        if color == :black
          score += pawn.row * 20
        else
          score += (7 - pawn.row) * 20
        end
      end

      enemy.each do |pawn|
        score -= 100

        if color == :black
          score -= (7 - pawn.row) * 20
        else
          score -= pawn.row * 20
        end
      end

      score
    end

    private

    def opponent(color)
      color == :white ? :black : :white
    end
  end
end
