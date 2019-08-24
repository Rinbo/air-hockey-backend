defmodule AirHockeyBackend.GameState do
  defstruct striker1: nil, striker2: nil, puck: nil, player1: nil, player2: nil, score: %{player1: 0, player2: 0}
end