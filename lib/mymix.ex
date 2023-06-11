defmodule Mymix do
  use Application

  def start(_type, _args) do
    IO.puts "Starting the application..."
    Mymix.Supervisor.start_link()
  end
end