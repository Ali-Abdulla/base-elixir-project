defmodule DocTest do
  use ExUnit.Case
  doctest Mymix.Parser
  doctest Mymix.Handler
  doctest Mymix.Plugins
end