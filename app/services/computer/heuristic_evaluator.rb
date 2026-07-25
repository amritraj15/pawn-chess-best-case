module Computer
  class HeuristicEvaluator
    WIN_SCORE = 100_000
    CAPTURE_SCORE = 300
    ADVANCE_SCORE = 20
    CENTER_SCORE = 15


    def score(move)
      score = 0

      score += WIN_SCORE if move.winning_move?
      score += CAPTURE_SCORE if move.capture?
      score += advancement_score(move)
      score += center_score(move)

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
  end
end
