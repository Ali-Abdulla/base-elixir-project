defmodule Mymix.Supervisor do
	use Supervisor

	def start_link do
		IO.puts "Starting THE supesrvisor..."
		Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
	end

	def init(:ok) do
		children = [
			Mymix.KickStarter,
			Mymix.ServicesSupervisor
		]

		Supervisor.init(children, strategy: :one_for_one)
	end
end