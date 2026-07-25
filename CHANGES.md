# Changes made (minimal-diff fixes)

Applied on top of the original repo, scoped to: get it actually working,
switch to Postgres, keep it lean/DRY. Nothing else was touched.

## Database: switched to PostgreSQL
- `Gemfile`: `sqlite3` gem -> `pg`
- `config/database.yml`: `adapter: sqlite3` -> `adapter: postgresql` for
  default/development/test/production-primary, with host/username/password
  read from env vars (defaulting to `localhost` / `postgres` / `postgres`).
  The solid_cache/solid_queue/solid_cable sub-databases were left on sqlite
  since they're unrelated to the chess game itself and out of scope here --
  noted in a comment in the file.
- `db/schema.rb` deleted (stale sqlite-shaped schema, missing the new
  `winner` column) -- it's auto-generated, `bin/rails db:migrate` rewrites
  it correctly on Postgres.

## Bug fix: crash on every completed game
`GameRepository#update_game` writes `game.winner = result` whenever someone
wins, but the `games` table never had a `winner` column -- every finished
game raised `ActiveModel::UnknownAttributeError`. Added
`db/migrate/20260724192950_add_winner_to_games.rb` (new migration, not an
edit to the already-existing one) and a prefixed `enum :winner` on `Game`
(prefixed so it doesn't collide with `current_turn`'s `white?`/`black?`
methods).

## Bug fix: move form never appeared on a fresh game
`show.html.erb` gated the move form on `@game.current_turn == "black"`, but
new games start with `current_turn: :white` and the human plays white --
so the form's condition was never true on a new game. Changed to
`== "white"`.

## Bug fix: turn label showed the wrong color
The same view's "Current Turn" text was inverted -- it said "Your Turn
(Black)" while `current_turn == "white"`, and vice versa. Swapped so the
label matches the actual turn.

## Added: winner display
Now that `winner` is a real column, added one line to `show.html.erb`
showing "White wins!" / "Black wins!" / "Draw" once the game is completed
(previously there was no way to see who won even after the crash was
fixed).

## DRY / controller leanness
- `GamesController#move` (158 lines total in the file, `move` itself was
  ~115 lines) had: a full commented-out earlier version of `#move` left in
  place, a literal duplicate `unless pawn ... redirect ... end` block
  (copy-paste), and three private methods (`next_turn`, `winner`, `status`)
  that were defined but never called anywhere.
- Removed all of the above. Extracted the "validate the human's move, apply
  it, check for an immediate win/draw" sequence into a new
  `GameService#play_human_move` method, reusing the same `MoveValidator`/
  `WinnerService` instances the class already builds for the AI's turn --
  no duplicated win/draw-checking logic between the human and AI move
  paths. The controller now just calls `engine.play_human_move(...)` and
  `engine.play_turn`, and a single `notice_for(result)` helper replaces the
  two separate copies of win/draw message text that existed before (one
  inline for the human's win/draw, one for the AI's).
- Net: `games_controller.rb` went from 158 lines (with dead code) to 80
  lines, all of it live code.

## Removed stray/dead files
- `app/re` -- a broken duplicate of `GameRepository` sitting in a
  misnamed, extensionless file (would very likely break Zeitwerk eager
  loading, since it doesn't map to any valid constant path).
- `app/services/symbol_validator.rb` -- leftover from an unrelated
  cryptocurrency-ticker-validation exercise, not used anywhere in this app.
- `app/services/draw_service.rb` -- empty (0 bytes); draw detection
  already lives in `WinnerService#draw?`.

## Not touched (deliberately out of scope)
- `MoveValidator`, `Board`, `Pawn`, `BoardSerializer`, `MoveService` (the
  AI), `WinnerService` -- these were already correct and working; no
  changes needed.
- Rails 8's solid_cache/solid_queue/solid_cable sqlite sub-databases --
  unrelated to the chess game, left as-is (see the comment added in
  `database.yml`).
- No test suite was added -- the original had none (`test/` is empty
  `.keep` files); adding one would go beyond "minimal changes."

## To run
```bash
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails server
```
Requires local Postgres reachable with `PAWN_CHESS_DB_USERNAME`/
`PAWN_CHESS_DB_PASSWORD` (default `postgres`/`postgres`) or a running
Postgres role matching that. This wasn't runnable end-to-end in the sandbox
that produced this diff (Rails 8 gems aren't installable there -- no
rubygems.org access) -- changes were verified by Ruby syntax-checking every
edited `.rb` file and diffing the `.erb` view for tag balance, not by
booting the app. Worth a real boot + click-through on your machine before
treating this as fully verified.
