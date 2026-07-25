class Game < ApplicationRecord
  enum :status, {
    in_progress: 0,
    completed: 1
  }

  enum :current_turn, {
    white: 0,
    black: 1
  }

  # Prefixed so `white?`/`black?` (from current_turn) and `winner_white?`/
  # `winner_black?` don't collide -- Rails enum methods are unprefixed by
  # default and two enums on the same values would otherwise clash.
  enum :winner, { white: 0, black: 1 }, prefix: true

  validates :board_state, presence: true
end
